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

mkdir -p build/zlib
cd zlib

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
export NM=$TOOLCHAIN/bin/$TARGET_HOST-nm

./configure --prefix=$PWD/build/$ANDROID_ARCH --static \

make -j$JOBS
make install
mkdir -p ../build/zlib/$ANDROID_ARCH
cp -R $PWD/build/$ANDROID_ARCH ../build/zlib/