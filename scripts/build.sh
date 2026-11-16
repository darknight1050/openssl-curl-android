#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

bash ./scripts/build-openssl.sh
bash ./scripts/build-zlib.sh
bash ./scripts/build-brotli.sh
bash ./scripts/build-zstd.sh
bash ./scripts/build-nghttp2.sh
bash ./scripts/build-nghttp3.sh
bash ./scripts/build-ngtcp2.sh
bash ./scripts/build-curl.sh

export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
export ANDROID_ARCH=arm64-v8a
export AR=$TOOLCHAIN/bin/llvm-ar
cd build

# Preserve duplicate object filenames from different libraries.
"$AR" -M <<EOF
CREATE libcurl.a
ADDLIB curl/$ANDROID_ARCH/lib/libcurl.a
ADDLIB nghttp2/$ANDROID_ARCH/lib/libnghttp2.a
ADDLIB nghttp3/$ANDROID_ARCH/lib/libnghttp3.a
ADDLIB ngtcp2/$ANDROID_ARCH/lib/libngtcp2.a
ADDLIB ngtcp2/$ANDROID_ARCH/lib/libngtcp2_crypto_ossl.a
ADDLIB openssl/$ANDROID_ARCH/lib/libssl.a
ADDLIB openssl/$ANDROID_ARCH/lib/libcrypto.a
ADDLIB zlib/$ANDROID_ARCH/lib/libz.a
ADDLIB zstd/$ANDROID_ARCH/lib/libzstd.a
ADDLIB brotli/$ANDROID_ARCH/lib/libbrotlicommon.a
ADDLIB brotli/$ANDROID_ARCH/lib/libbrotlidec.a
ADDLIB brotli/$ANDROID_ARCH/lib/libbrotlienc.a
SAVE
END
EOF

rm -rf -- shared
mkdir -p shared/licenses
cp -R curl/$ANDROID_ARCH/include/. shared/
cp curl/$ANDROID_ARCH/include/curl/*.h shared/
cp ../LICENSE shared/licenses/wrapper-MIT.txt
cp ../curl/COPYING shared/licenses/curl.txt
cp ../openssl/LICENSE.txt shared/licenses/OpenSSL.txt
cp ../zlib/LICENSE shared/licenses/zlib.txt
cp ../brotli/LICENSE shared/licenses/Brotli.txt
cp ../zstd/LICENSE shared/licenses/zstd-BSD.txt
cp ../nghttp2/COPYING shared/licenses/nghttp2.txt
cp ../nghttp3/COPYING shared/licenses/nghttp3.txt
cp ../ngtcp2/COPYING shared/licenses/ngtcp2.txt
cp ../nghttp3/lib/sfparse/COPYING shared/licenses/sfparse.txt
cd ..

python3 - <<'PY'
import json, os, re, subprocess
from pathlib import Path
sources = {name: subprocess.check_output(['git', '-C', name, 'rev-parse', 'HEAD'], text=True).strip()
           for name in ('curl', 'openssl', 'zlib', 'brotli', 'zstd', 'nghttp2', 'nghttp3', 'ngtcp2')}
revision = json.loads(Path('qpm2.json').read_text())['workspace']['ndk'].lstrip('=')
sources['sfparse'] = subprocess.check_output(['git', '-C', 'nghttp3/lib/sfparse', 'rev-parse', 'HEAD'], text=True).strip()
config = Path('curl/lib/curl_config.h').read_text()
for feature in ('USE_IPV6', 'USE_NGHTTP2', 'USE_NGHTTP3', 'USE_NGTCP2', 'USE_RESOLV_THREADED', 'HAVE_ZSTD'):
    assert re.search(r'^#define ' + feature + r' 1$', config, re.M), f'Missing curl feature: {feature}'
assert not re.search(r'^#define CURL_DISABLE_PROXY\b', config, re.M), 'Proxy support is disabled'
Path('build/shared/build-info.json').write_text(json.dumps({
    'sources': sources, 'ndk': revision, 'androidApi': int(os.environ['MIN_SDK_VERSION']),
    'abi': os.environ['ANDROID_ARCH'], 'linkage': 'shared', 'exportedApi': 'curl only',
    'features': ['IPv6', 'HTTP/2', 'HTTP/3', 'threaded DNS', 'proxy', 'zstd']}, indent=2) + '\n')
PY
