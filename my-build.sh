#!/bin/bash

export NDK=/mnt/c/Development/Tools/android-ndk-r27-beta1-linux
export HOST_TAG=linux-x86_64
export MIN_SDK_VERSION=27

export CFLAGS="-Os -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables"
export LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections"

./build.sh
