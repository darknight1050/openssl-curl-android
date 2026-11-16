#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
QPM=${QPM:-qpm2}
export QPM_DISABLE_GLOBAL_CONFIG=1
package=$(python3 -c 'import json; p=json.load(open("qpm2.json")); print(p["id"] + "-" + p["version"] + ".qpkg")')
mkdir -p dist
"$QPM" qpkg --offline --no-build "$PWD/dist/$package"
"$QPM" qmod zip --offline --skip_build "$PWD/dist/libcurl.qmod"
cp build/libcurl.so dist/libcurl.so
cp build/debug/libcurl-debug.so dist/libcurl-debug.so
cp build/build-id.txt dist/build-id.txt
cp build/shared/build-info.json dist/build-info.json
(cd dist && sha256sum "$package" libcurl.qmod libcurl.so libcurl-debug.so build-id.txt build-info.json > SHA256SUMS)
