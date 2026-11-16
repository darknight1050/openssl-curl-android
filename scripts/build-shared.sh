#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

# Link the PIC dependency archives into one shared library with private backends.
if [[ -f ndkpath.txt ]]; then
    NDK=$(tr -d '\r\n' < ndkpath.txt)
else
    NDK=${NDK:-${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-}}}
fi
: "${NDK:?Run qpm2 ndk resolve -d or set ANDROID_NDK_HOME}"
export TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/${HOST_TAG:-linux-x86_64}"
[[ -f build/libcurl.a ]] || { echo 'Run qpm2 build first' >&2; exit 1; }

# Only curl's declared public API is exported; every bundled dependency is private.
python3 - <<'PY'
import os, re, subprocess
from pathlib import Path
nm = subprocess.check_output([os.environ['TOOLCHAIN'] + '/bin/llvm-nm',
                              '--defined-only', '--extern-only', '--format=posix',
                              'build/libcurl.a'], text=True)
defined = {m[0] for line in nm.splitlines() if (m := line.split()) and
           len(m) > 1 and re.fullmatch('[A-Za-z]', m[1])}
public = set()
for header in Path('build/shared/curl').glob('*.h'):
    source = re.sub(r'/\*.*?\*/', '', header.read_text(), flags=re.S)
    source = re.sub(r'^\s*#.*$', '', source, flags=re.M)
    source = re.sub(r'"(?:[^"\\]|\\.)*"', '""', source)
    public.update(re.findall(r'\bCURL_EXTERN\b[^;{}]*?\b(curl_\w+)\s*\(', source))
public &= defined
for required in ('curl_easy_init', 'curl_easy_perform', 'curl_global_init',
                 'curl_global_cleanup', 'curl_multi_init', 'curl_version_info'):
    assert required in public, f'Missing public API: {required}'
assert all(re.fullmatch(r'[A-Za-z_]\w*', name) for name in public)
Path('build/libcurl.exports').write_text('{\n  global:\n' +
    ''.join('    ' + name + ';\n' for name in sorted(public)) + '  local: *;\n};\n')
print(f'Exporting {len(public)} public API symbols')
PY

mkdir -p build/debug extern/build/build
"$TOOLCHAIN/bin/aarch64-linux-android27-clang" -shared \
    -Wl,--whole-archive build/libcurl.a -Wl,--no-whole-archive \
    -Wl,-soname,libcurl.so -Wl,--version-script=build/libcurl.exports \
    -Wl,-Bsymbolic -Wl,--gc-sections -Wl,--no-undefined \
    -Wl,-z,max-page-size=16384 -Wl,--build-id=sha1 \
    -ldl -lm -o build/debug/libcurl-debug.so
cp build/debug/libcurl-debug.so build/libcurl.so
"$TOOLCHAIN/bin/llvm-strip" --strip-unneeded build/libcurl.so
"$TOOLCHAIN/bin/llvm-objcopy" --add-gnu-debuglink=build/debug/libcurl-debug.so build/libcurl.so

# Fail the build if the final dynamic symbol table differs from the allowlist.
python3 - <<'PY'
import os, re, subprocess
from pathlib import Path
expected = set(re.findall(r'^    (curl_\w+);$',
                          Path('build/libcurl.exports').read_text(), re.M))
nm = subprocess.check_output([os.environ['TOOLCHAIN'] + '/bin/llvm-nm',
                              '--dynamic', '--defined-only', '--extern-only',
                              '--format=posix', 'build/libcurl.so'], text=True)
actual = {line.split()[0] for line in nm.splitlines() if line.strip()}
assert actual == expected, f'Unexpected exports: {actual - expected}; missing: {expected - actual}'
print(f'Verified {len(actual)} curl-only exports; no bundled dependency exports')
def elf(args, file):
    return subprocess.check_output([os.environ['TOOLCHAIN'] + '/bin/llvm-readelf',
                                    *args, file], text=True)
release, debug = 'build/libcurl.so', 'build/debug/libcurl-debug.so'
build_ids = [re.search(r'Build ID: ([0-9a-f]+)', elf(['-n'], file)).group(1)
             for file in (release, debug)]
assert build_ids[0] == build_ids[1], 'Release/debug build IDs differ'
assert '.debug_info' in elf(['-S'], debug), 'Debug artifact has no DWARF information; rebuild with -g'
assert '.debug_info' not in elf(['-S'], release), 'Release artifact is not stripped'
Path('build/build-id.txt').write_text(build_ids[0] + '\n')
import json
info = json.loads(Path('build/shared/build-info.json').read_text())
info.update(buildId=build_ids[0], exportedSymbols=sorted(actual))
Path('build/shared/build-info.json').write_text(json.dumps(info, indent=2) + '\n')
Path('build/THIRD_PARTY_LICENSES.txt').write_text('\n\n'.join(
    f'=== {file.name} ===\n{file.read_text()}'
    for file in sorted(Path('build/shared/licenses').glob('*.txt'))))
print(f'Release/debug build ID: {build_ids[0]}')
PY
cp build/libcurl.so extern/build/build/libcurl.so
