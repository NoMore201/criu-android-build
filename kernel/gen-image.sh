#!/bin/bash

export ROOT=`pwd`

# prepare goldfish
[[ ! -d goldfish ]] && git clone https://android.googlesource.com/kernel/goldfish
cd goldfish
git pull && git checkout android-goldfish-3.18
cd $ROOT

[[ ! -d arm-prebuilt ]] && git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8 arm-prebuilt
cd $ROOT
export PATH=$ROOT/arm-prebuilt/bin:$PATH
cp criu_arm_defconfig goldfish/arch/arm/configs/
cd goldfish
make clean
make ARCH=arm  criu_arm_defconfig
make ARCH=arm SUBARCH=arm  CROSS_COMPILE=arm-eabi-
cp arch/arm/boot/zImage $ROOT
