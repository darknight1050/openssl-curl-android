#!/bin/bash

set -euo pipefail

JOBS=${JOBS:-$(getconf _NPROCESSORS_ONLN)}

# openssl 3.x refers to the host specific toolchain as "ANDROID_NDK_ROOT"
export ANDROID_NDK_ROOT=$NDK
export ANDROID_ARCH=arm64-v8a
PATH=$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin:$PATH

mkdir -p build/openssl
cd openssl

# openssl does not handle api suffix well
perl ./Configure android-arm64 no-shared no-tests no-module \
 -D__ANDROID_API__=$MIN_SDK_VERSION \
 --prefix=$PWD/build/$ANDROID_ARCH \

make -j$JOBS
make install_sw
mkdir -p ../build/openssl/$ANDROID_ARCH
cp -R $PWD/build/$ANDROID_ARCH ../build/openssl/

cd ..
