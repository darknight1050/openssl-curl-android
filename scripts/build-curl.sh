#!/bin/bash

set -euo pipefail

JOBS=${JOBS:-$(getconf _NPROCESSORS_ONLN)}

export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG

# curl common configuration arguments
ARGUMENTS=" \
    --disable-shared \
    --enable-static \
	--disable-verbose \
    --disable-manual \
	--disable-unix-sockets \
    --disable-ares \
    --enable-threaded-resolver \
    --disable-rtsp \
    --enable-ipv6 \
    --enable-proxy \
    --disable-versioned-symbols \
    --without-libidn2 \
    --without-libssh2 \
    --without-libssh \
    --without-quiche \
    --without-libpsl \
    --disable-dict \
    --disable-file \
    --disable-ftp \
    --disable-gopher \
    --disable-imap \
    --disable-pop3 \
    --disable-smtp \
    --disable-telnet \
    --disable-tftp \
    --disable-debug \
    --disable-symbol-hiding \
    "

mkdir -p build/curl
cd curl

# Release tags retain -DEV headers; stamp them using curl's release tooling.
SOURCE_DATE_EPOCH=$(git log -1 --format=%ct) sh ./scripts/maketgz 8.23.0 only
autoreconf -fi

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
export SSL_DIR=$PWD/../openssl/build/$ANDROID_ARCH
export ZLIB_DIR=$PWD/../zlib/build/$ANDROID_ARCH
export BROTLI_DIR=$PWD/../brotli/build_out/$ANDROID_ARCH
export ZSTD_DIR=$PWD/../build/zstd/$ANDROID_ARCH
export NGHTTP2_DIR=$PWD/../build/nghttp2/$ANDROID_ARCH
export NGHTTP3_DIR=$PWD/../build/nghttp3/$ANDROID_ARCH
export NGTCP2_DIR=$PWD/../build/ngtcp2/$ANDROID_ARCH
export PKG_CONFIG_PATH=
export PKG_CONFIG_LIBDIR="$SSL_DIR/lib/pkgconfig:$ZLIB_DIR/lib/pkgconfig:$BROTLI_DIR/lib/pkgconfig:$ZSTD_DIR/lib/pkgconfig:$NGHTTP2_DIR/lib/pkgconfig:$NGHTTP3_DIR/lib/pkgconfig:$NGTCP2_DIR/lib/pkgconfig"

./configure --host=$TARGET_HOST \
            --target=$ANDROID_ARCH \
            --prefix=$PWD/build/$ANDROID_ARCH \
            --with-openssl=$SSL_DIR \
            --with-zlib=$ZLIB_DIR \
            --with-brotli=$BROTLI_DIR \
            --with-zstd=$ZSTD_DIR \
            --with-nghttp2=$NGHTTP2_DIR \
            --with-nghttp3=$NGHTTP3_DIR \
            --with-ngtcp2=$NGTCP2_DIR \
            --with-ca-path=/system/etc/security/cacerts \
            --without-ca-bundle \
            $ARGUMENTS \

make -j$JOBS
make install
mkdir -p ../build/curl/$ANDROID_ARCH
cp -R $PWD/build/$ANDROID_ARCH ../build/curl/

cd ..
