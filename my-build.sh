#!/bin/bash

export NDK=/mnt/Development/Tools/android-ndk-r22b-linux
export HOST_TAG=linux-x86_64
export MIN_SDK_VERSION=21

export CFLAGS="-Os -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables"
export LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections"

./build.sh
