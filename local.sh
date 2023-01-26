#! /bin/bash

set -x

setup_export() {
    export KERNEL_PATH=$PWD
    export KERNEL_DEFCONFIG=vendor/wayne_defconfig
    export KERNEL_FILE=Image.gz-dtb
    export CLANG_VERSION=r450784d
    export BUILD_EXTRA_COMMAND='LD=ld.lld'
    export USE_KERNELSU=true
    export USE_KPROBES=true
    export LTO_DISABLE=true
}

setup_build_kernel_env() {
    cd $KERNEL_PATH
    BUILD_TIME=$(TZ=Asia/Shanghai date "+%Y%m%d%H%M")
    if test ! -e ~/gcc-aosp/env_is_setup; then
        sudo apt-get update
        sudo apt-get install git ccache automake flex lzop bison gperf build-essential zip curl zlib1g-dev g++-multilib libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng maven libssl-dev pwgen libswitch-perl policycoreutils minicom libxml-sax-base-perl libxml-simple-perl bc libc6-dev-i386 lib32ncurses5-dev libx11-dev lib32z-dev libgl1-mesa-dev xsltproc unzip device-tree-compiler python2 python3
    fi
}

aosp_clang_and_gcc() {
    if test ! -e ~/clang-aosp/$CLANG_VERSION; then
        rm -rf ~/clang-aosp && mkdir ~/clang-aosp && cd ~/clang-aosp
        wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master-kernel-build-2022/clang-$CLANG_VERSION.tar.gz
        tar -C ~/clang-aosp/ -zxvf clang-$CLANG_VERSION.tar.gz
        touch ~/clang-aosp/$CLANG_VERSION
    fi
    if test ! -d ~/gcc-aosp; then
        cd ~/gcc-aosp
        mkdir ~/gcc-aosp && cd ~/gcc-aosp
        wget https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/refs/tags/android-11.0.0_r35.tar.gz
        tar -C ~/gcc-aosp/ -zxvf android-11.0.0_r35.tar.gz
        touch ~/gcc-aosp/env_is_setup
    fi
}

setup_kernelsu() {
    cd $KERNEL_PATH
    curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
    if test "$USE_KPROBES" == "true"; then
        echo "CONFIG_MODULES=y" >> $KERNEL_PATH/arch/arm64/configs/$KERNEL_DEFCONFIG
        echo "CONFIG_KPROBES=y" >> $KERNEL_PATH/arch/arm64/configs/$KERNEL_DEFCONFIG
        echo "CONFIG_HAVE_KPROBES=y" >> $KERNEL_PATH/arch/arm64/configs/$KERNEL_DEFCONFIG
        echo "CONFIG_KPROBE_EVENTS=y" >> $KERNEL_PATH/arch/arm64/configs/$KERNEL_DEFCONFIG
    fi
    if test "$LTO_DISABLE" == "true"; then
        sed -i 's/CONFIG_LTO=y/CONFIG_LTO=n/' $KERNEL_PATH/arch/arm64/configs/$KERNEL_DEFCONFIG
        sed -i 's/CONFIG_LTO_CLANG=y/CONFIG_LTO_CLANG=n/' $KERNEL_PATH/arch/arm64/configs/$KERNEL_DEFCONFIG
        sed -i 's/CONFIG_THINLTO=y/CONFIG_THINLTO=n/' $KERNEL_PATH/arch/arm64/configs/$KERNEL_DEFCONFIG
        echo "CONFIG_LTO_NONE=y" >> $KERNEL_PATH/arch/arm64/configs/$KERNEL_DEFCONFIG
    fi
}

build_kernel() {
    cd $KERNEL_PATH
    export PATH=~/clang-aosp/bin:$PATH
    make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=~/gcc-aosp/bin/aarch64-linux-android- CC="ccache clang" CXX="ccache clang++" $BUILD_EXTRA_COMMAND $KERNEL_DEFCONFIG
    make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=~/gcc-aosp/bin/aarch64-linux-android- CC="ccache clang" CXX="ccache clang++" $BUILD_EXTRA_COMMAND
}

make_anykernel3() {
    cd $KERNEL_PATH
    test -d $KERNEL_PATH/AnyKernel3 || git clone https://github.com/osm0sis/AnyKernel3
    if test -e $KERNEL_PATH/out/arch/arm64/boot/$KERNEL_FILE && test -d $KERNEL_PATH/AnyKernel3; then
        sed -i 's/do.devicecheck=1/do.devicecheck=0/g' AnyKernel3/anykernel.sh
        sed -i 's!block=/dev/block/platform/omap/omap_hsmmc.0/by-name/boot;!block=auto;!g' AnyKernel3/anykernel.sh
        sed -i 's/is_slot_device=0;/is_slot_device=auto;/g' AnyKernel3/anykernel.sh
        cp $KERNEL_PATH/out/arch/arm64/boot/$KERNEL_FILE $KERNEL_PATH/AnyKernel3/$KERNEL_FILE
        rm -rf AnyKernel3/.git* AnyKernel3/README.md
        cd $KERNEL_PATH/AnyKernel3
        zip -r Anykernel3.zip *
        mv $KERNEL_PATH/AnyKernel3/Anykernel3.zip $KERNEL_PATH/out/arch/arm64/boot
        rm -r $KERNEL_PATH/AnyKernel3/$KERNEL_FILE
        cd $KERNEL_PATH
        echo [INFO] Products are put in $KERNEL_PATH/out/arch/arm64/boot
        echo [INFO] Done.
    fi
}

setup_export
setup_build_kernel_env
aosp_clang_and_gcc
setup_kernelsu
build_kernel
make_anykernel3