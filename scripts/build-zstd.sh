#!/usr/bin/env bash
set -euo pipefail

cmake -S zstd/build/cmake -B build/zstd-cmake \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM="android-$MIN_SDK_VERSION" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DZSTD_BUILD_SHARED=OFF \
    -DZSTD_BUILD_STATIC=ON \
    -DZSTD_BUILD_PROGRAMS=OFF \
    -DZSTD_BUILD_TESTS=OFF \
    -DZSTD_BUILD_CONTRIB=OFF \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX="$PWD/build/zstd/arm64-v8a"
cmake --build build/zstd-cmake -j"${JOBS:-16}"
cmake --install build/zstd-cmake
