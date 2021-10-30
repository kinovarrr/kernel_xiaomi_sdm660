#!/bin/bash

#
# Color UI
#
grn=$(tput setaf 2)             # green
yellow=$(tput setaf 3)          # yellow
bldgrn=${txtbld}$(tput setaf 2) # bold green
red=$(tput setaf 1)             # red
txtbld=$(tput bold)             # bold
bldblu=${txtbld}$(tput setaf 4) # bold blue
blu=$(tput setaf 4)             # blue
txtrst=$(tput sgr0)             # reset
blink=$(tput blink)             # blink

#
# Clean stuff
#
if [ -d "out/arch/arm64/boot/Image.gz-dtb" ]; then
    rm -rf "out/arch/arm64/boot/Image.gz-dtb"
fi


#
# build from
#
export KBUILD_BUILD_USER="Peppe289"
export KBUILD_BUILD_HOST="RaveRules"

#
# start build date
#
DATE=$(date +"%Y%m%d-%H%M")

#
# Compiler type
#
TOOLCHAIN_DIRECTORY="../toolchain"
TOOLCHAIN_ARM32="gcc-arm"
TOOLCHAIN_ARM64="gcc-arm64"

#
# Build defconfig
#
DEFCONFIG="lavender-perf_defconfig"

#
# Check for compiler
#
if [ ! -d "$TOOLCHAIN_DIRECTORY" ]; then
    mkdir $TOOLCHAIN_DIRECTORY
fi

if [ -d "$TOOLCHAIN_DIRECTORY/$TOOLCHAIN_ARM32" ]; then
    echo -e "${bldgrn}"
    echo "Toolchain arm32 ready"
    echo -e "${txtrst}"
else
    echo -e "${red}"
    echo "Need to download toolchain arm32"
    echo -e "${txtrst}"
    git clone --depth=1 https://github.com/Rave-Project/arm-linux-androideabi-4.9.git $TOOLCHAIN_DIRECTORY/$TOOLCHAIN_ARM32
fi

if [ -d "$TOOLCHAIN_DIRECTORY/$TOOLCHAIN_ARM64" ]; then
    echo -e "${bldgrn}"
    echo "Toolchain arm64 ready"
    echo -e "${txtrst}"
else
    echo -e "${red}"
    echo "Need to download toolchain arm64"
    echo -e "${txtrst}"
    git clone --depth=1 https://github.com/Rave-Project/aarch64-linux-android-4.9.git $TOOLCHAIN_DIRECTORY/$TOOLCHAIN_ARM64
fi

#
# Build start
#
export CROSS_COMPILE=$(pwd)/$TOOLCHAIN_DIRECTORY/$TOOLCHAIN_ARM64/bin/aarch64-linux-androidkernel-
export CROSS_COMPILE_ARM32=$(pwd)/$TOOLCHAIN_DIRECTORY/$TOOLCHAIN_ARM32/bin/arm-linux-androideabi-

export ARCH=arm64
export SUBARCH=arm64

make O=out $DEFCONFIG
make O=out -j$(nproc --all)

if [ ! -f "out/arch/arm64/boot/Image.gz-dtb" ]; then
    echo -e "${red}"
    echo "Error"
    echo -e "${txtrst}"
    exit
fi

git clone --depth=1 https://github.com/Peppe289/AnyKernel3.git -b lavender anykernel
cp out/arch/arm64/boot/Image.gz-dtb anykernel
cd anykernel
zip -r9 ../Rave-$DATE.zip * -x .git README.md *placeholder
cd ..
rm -rf anykernel
echo "kernel is: $(pwd)/Rave-$DATE.zip"
