#!/bin/bash

#Change this env variable to the number of processors you have
if [ -f /proc/cpuinfo ]; then
	JOBS=$(grep flags /proc/cpuinfo |wc -l)
elif [ ! -z $(which sysctl) ]; then
	JOBS=$(sysctl -n hw.ncpu)
else
	JOBS=2
fi

export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG

# curl common configuration arguments
ARGUMENTS=" \
    --disable-shared \
    --enable-static \
	--disable-verbose \
    --disable-manual \
	--disable-unix-sockets \
    --disable-ares \
    --disable-rtsp \
    --disable-ipv6 \
    --disable-proxy \
    --disable-versioned-symbols \
    --without-librtmp \
    --disable-dict \
    --disable-file \
    --disable-ftp \
    --disable-gopher \
    --disable-imap \
    --disable-pop3 \
    --disable-smb \
    --disable-smtp \
    --disable-telnet \
    --disable-tftp \
    --disable-debug \
    --disable-symbol-hiding \
    "

mkdir -p build/curl
cd curl

autoreconf -fi

# arm64
export TARGET_HOST=aarch64-linux-android
PATH=$TOOLCHAIN/bin:$PATH
export ANDROID_ARCH=arm64-v8a
export AR=$TOOLCHAIN/bin/$TARGET_HOST-ar
export AS=$TOOLCHAIN/bin/$TARGET_HOST-as
export CC=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang
export CXX=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang++
export LD=$TOOLCHAIN/bin/$TARGET_HOST-ld
export RANLIB=$TOOLCHAIN/bin/$TARGET_HOST-ranlib
export STRIP=$TOOLCHAIN/bin/$TARGET_HOST-strip
export SSL_DIR=$PWD/../openssl/build/$ANDROID_ARCH
export ZLIB_DIR=$PWD/../zlib/build/$ANDROID_ARCH
export BROTLI_DIR=$PWD/../brotli/build_out/$ANDROID_ARCH

./configure --host=$TARGET_HOST \
            --target=$ANDROID_ARCH \
            --prefix=$PWD/build/$ANDROID_ARCH \
            --with-ssl=$SSL_DIR \
            --with-zlib=$ZLIB_DIR \
            --with-brotli=$BROTLI_DIR \
            $ARGUMENTS \

make -j$JOBS
make install
mkdir -p ../build/curl/$ANDROID_ARCH
cp -R $PWD/build/$ANDROID_ARCH ../build/curl/

cd ..
