#!/bin/bash

set -euo pipefail

JOBS=${JOBS:-$(getconf _NPROCESSORS_ONLN)}

export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG

mkdir -p build/brotli
cd brotli

# brotli >= 1.2 dropped autotools, it is CMake only now

# arm64
PATH=$TOOLCHAIN/bin:$PATH
export ANDROID_ARCH=arm64-v8a

rm -rf cmake_build/$ANDROID_ARCH

cmake -S . -B cmake_build/$ANDROID_ARCH \
      -DCMAKE_C_FLAGS="$CFLAGS" \
      -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake \
      -DANDROID_ABI=$ANDROID_ARCH \
      -DANDROID_PLATFORM=android-$MIN_SDK_VERSION \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=OFF \
      -DBROTLI_BUILD_TOOLS=OFF \
      -DBROTLI_DISABLE_TESTS=ON \
      -DCMAKE_INSTALL_PREFIX=$PWD/build_out/$ANDROID_ARCH \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_INCLUDEDIR=include \

cmake --build cmake_build/$ANDROID_ARCH -j$JOBS
cmake --install cmake_build/$ANDROID_ARCH
mkdir -p ../build/brotli/$ANDROID_ARCH
cp -R $PWD/build_out/$ANDROID_ARCH ../build/brotli/

cd ..
