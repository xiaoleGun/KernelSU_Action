#!/bin/bash
make clean && make mrproper && rm -rf out 
mkdir -p out
export ARCH=arm64
export SUBARCH=arm64
PATH="/root/clang+llvm-14.0.6-aarch64-linux-gnu/bin/:$PATH"
make O=out CC=clang begonia_user_defconfig ARCH=arm64
make mrproper
make -j$(nproc --all) O=out \ CROSS_COMPILE=aarch64-linux-gnu- \ CROSS_COMPILE_ARM32=arm-linux-gnueabi- \ 
CC=clang \
AR=llvm-ar \
OBJDUMP=llvm-objdump \
STRIP=llvm-strip \
NM=llvm-nm \
OBJCOPY=llvm-objcopy \
LD=ld.lld \
2>&1 | tee error.log 