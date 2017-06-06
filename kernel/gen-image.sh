#!/bin/bash

export ROOT=`pwd`

# prepare goldfish
[[ ! -d goldfish ]] && git clone https://android.googlesource.com/kernel/goldfish
cd goldfish
git pull && git checkout android-goldfish-3.18
cd $ROOT

[[ ! -d arm-prebuilt ]] && git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8 arm-prebuilt
export CROSS_COMPILE=arm-eabi-
export PATH=$ROOT/arm-prebuilt/bin:$PATH
cp criu_defconfig goldfish/arch/arm/configs/
cd goldfish
make clean
make ARCH=arm CC="${CROSS_COMPILE}gcc" criu_defconfig
make ARCH=arm CC="${CROSS_COMPILE}gcc" -j$(nproc)

