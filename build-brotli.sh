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

mkdir -p build/brotli
cd brotli

./bootstrap

# arm64
export TARGET_HOST=aarch64-linux-android
PATH=$TOOLCHAIN/bin:$PATH
export ANDROID_ARCH=arm64-v8a
export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export NM=$TOOLCHAIN/bin/llvm-nm
export STRIP=$TOOLCHAIN/bin/llvm-strip

./configure --host=$TARGET_HOST --prefix=$PWD/build_out/$ANDROID_ARCH --disable-shared --enable-static \

make -j$JOBS
make install
mkdir -p ../build/brotli/$ANDROID_ARCH
cp -R $PWD/build_out/$ANDROID_ARCH ../build/brotli/