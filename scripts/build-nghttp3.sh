#!/usr/bin/env bash
set -euo pipefail

cmake -S nghttp3 -B build/nghttp3-cmake \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM="android-$MIN_SDK_VERSION" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DENABLE_LIB_ONLY=ON \
    -DENABLE_SHARED_LIB=OFF \
    -DENABLE_STATIC_LIB=ON \
    -DBUILD_TESTING=OFF \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX="$PWD/build/nghttp3/arm64-v8a"
cmake --build build/nghttp3-cmake -j"${JOBS:-16}"
cmake --install build/nghttp3-cmake
