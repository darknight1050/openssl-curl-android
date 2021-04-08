#!/bin/bash

chmod +x ./build-openssl.sh
chmod +x ./build-curl.sh

./build-openssl.sh
./build-curl.sh

export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
export TARGET_HOST=aarch64-linux-android
PATH=$TOOLCHAIN/bin:$PATH
export ANDROID_ARCH=arm64-v8a
export AR=$TOOLCHAIN/bin/$TARGET_HOST-ar

cd build

mkdir tmp
cd tmp

$AR -x $PWD/../curl/$ANDROID_ARCH/lib/libcurl.a
$AR -x $PWD/../openssl/$ANDROID_ARCH/lib/libcrypto.a
$AR -x $PWD/../openssl/$ANDROID_ARCH/lib/libssl.a

$AR rc ../libcurl.a *.o

cd ..
rm -r tmp

cd ..