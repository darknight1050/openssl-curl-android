#!/bin/bash

chmod +x ./build-openssl.sh
chmod +x ./build-zlib.sh
chmod +x ./build-brotli.sh
chmod +x ./build-curl.sh

./build-openssl.sh
./build-zlib.sh
./build-brotli.sh
./build-curl.sh

export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
PATH=$TOOLCHAIN/bin:$PATH
export ANDROID_ARCH=arm64-v8a
export AR=$TOOLCHAIN/bin/llvm-ar

cd build

mkdir tmp
cd tmp

$AR -x $PWD/../curl/$ANDROID_ARCH/lib/libcurl.a
$AR -x $PWD/../openssl/$ANDROID_ARCH/lib/libcrypto.a
$AR -x $PWD/../openssl/$ANDROID_ARCH/lib/libssl.a
$AR -x $PWD/../zlib/$ANDROID_ARCH/lib/libz.a
$AR -x $PWD/../brotli/$ANDROID_ARCH/lib/libbrotlicommon.a
$AR -x $PWD/../brotli/$ANDROID_ARCH/lib/libbrotlidec.a
$AR -x $PWD/../brotli/$ANDROID_ARCH/lib/libbrotlienc.a

$AR rc ../libcurl.a *.o

cd ..
rm -r tmp

mkdir -p shared/zlib

cp -R openssl/$ANDROID_ARCH/include/* shared/
cp -R zlib/$ANDROID_ARCH/include/* shared/zlib/
cp -R brotli/$ANDROID_ARCH/include/* shared/
cp -R curl/$ANDROID_ARCH/include/* shared/

cd ..