#!/usr/bin/env bash
set -euo pipefail

# Use the same pinned OpenSSL as curl, including its QUIC TLS API.
SSL_DIR="$PWD/openssl/build/arm64-v8a"
cmake -S ngtcp2 -B build/ngtcp2-cmake \
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
    -DENABLE_OPENSSL=ON \
    -DOPENSSL_USE_STATIC_LIBS=ON \
    -DOPENSSL_INCLUDE_DIR="$SSL_DIR/include" \
    -DOPENSSL_SSL_LIBRARY="$SSL_DIR/lib/libssl.a" \
    -DOPENSSL_CRYPTO_LIBRARY="$SSL_DIR/lib/libcrypto.a" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX="$PWD/build/ngtcp2/arm64-v8a"
cmake --build build/ngtcp2-cmake -j"${JOBS:-16}"
cmake --install build/ngtcp2-cmake
