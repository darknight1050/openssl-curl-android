#!/bin/bash

set -euo pipefail

JOBS=${JOBS:-$(getconf _NPROCESSORS_ONLN)}

export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG

mkdir -p build/zlib
cd zlib

# arm64
export TARGET_HOST=aarch64-linux-android
PATH=$TOOLCHAIN/bin:$PATH
export ANDROID_ARCH=arm64-v8a
export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang++
export LD=$TOOLCHAIN/bin/ld.lld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export NM=$TOOLCHAIN/bin/llvm-nm
export STRIP=$TOOLCHAIN/bin/llvm-strip

bash ./configure --prefix=$PWD/build/$ANDROID_ARCH --static \

make -j$JOBS
make install
mkdir -p ../build/zlib/$ANDROID_ARCH
cp -R $PWD/build/$ANDROID_ARCH ../build/zlib/
