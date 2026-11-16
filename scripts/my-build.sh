#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

if [[ -f ndkpath.txt ]]; then
    NDK=$(tr -d '\r\n' < ndkpath.txt)
else
    NDK=${NDK:-${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-}}}
fi
: "${NDK:?Run qpm2 ndk resolve -d or set ANDROID_NDK_HOME}"
required=$(python3 -c 'import json; print(json.load(open("qpm2.json"))["workspace"]["ndk"].lstrip("="))')
revision=$(sed -n 's/^Pkg.Revision *= *//p' "$NDK/source.properties" | tr -d '\r')
[[ "$revision" == "$required" ]] || { echo "Expected NDK $required, found $revision" >&2; exit 1; }

export NDK
export HOST_TAG=${HOST_TAG:-linux-x86_64}
export MIN_SDK_VERSION=27
if [[ -z ${JOBS:-} ]]; then
    JOBS=$(getconf _NPROCESSORS_ONLN)
    (( JOBS <= 16 )) || JOBS=16
fi
export JOBS
export CFLAGS="-Os -g -fPIC -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-Wl,-Bsymbolic -Wl,--gc-sections"

bash ./scripts/build.sh
bash ./scripts/build-shared.sh
