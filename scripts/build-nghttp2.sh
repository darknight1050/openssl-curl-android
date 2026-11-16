#!/usr/bin/env bash
set -euo pipefail

ANDROID_ARCH=arm64-v8a
# nghttp2 and nghttp3 each embed sfparse. Keep their private copies distinct
# so consumers can link the merged archive with --whole-archive safely.
sfparse_flags=""
for symbol in parser_param parser_inner_list parser_dict parser_list parser_item parser_init unescape base64decode pctdecode; do
    sfparse_flags+=" -Dsfparse_${symbol}=qpm_nghttp2_sfparse_${symbol}"
done
cmake -S nghttp2 -B build/nghttp2-cmake \
    -DCMAKE_C_FLAGS="${CFLAGS:-} $sfparse_flags" \
    -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI="$ANDROID_ARCH" \
    -DANDROID_PLATFORM="android-$MIN_SDK_VERSION" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DENABLE_LIB_ONLY=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_STATIC_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DENABLE_DOC=OFF \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX="$PWD/build/nghttp2/$ANDROID_ARCH"
cmake --build build/nghttp2-cmake -j"${JOBS:-16}"
cmake --install build/nghttp2-cmake
