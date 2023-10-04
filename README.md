**中文** | [English](README_EN.md)

# LXC-KernelSU Action

一般来说只需要按实际需要修改5－20行的相关内容就可以。包含18个工作流可同时工作可最大化提高编译内核的成功率，助力LXC,KernelSU 。
#工具链集包含AOSP clang ,LLVM, ARM gcc ,SD-clang(高通的llvm工具链）,Proton-clang, ZyC clang,linaro gcc ,Eva gcc ,Google gcc_4.9 ,Android NDK ,arter97_gcc等
#内核源地址
KERNEL_SOURCE=https://github.com/xiaoleGun/android_kernel_xiaomi_wayne-4.19
#分支
KERNEL_SOURCE_BRANCH=twrp-12
#内核配置文件
KERNEL_CONFIG=vendor/wayne_defconfig


#LXC_Docker启用，默认启用。对此项对build-kernel.yml无效，因为build-kernel.yml是官方版，未作任何修改。
ENABLE_LXC=true
#KernelSU相关，默认关闭。若需要KernelSU，则修改前3项值为true
ENABLE_KERNELSU=false
ADD_KPROBES_CONFIG=false 
ADD_OVERLAYFS_CONFIG=false
KERNELSU_TAG=main

#这块几乎可以不动
KERNEL_IMAGE_NAME=Image
ARCH=arm64

#安卓12以上可启用LLVM=1 LLVM_IAS=1配置,默认留空
#EXTRA_CMDS:LD=ld.lld
#EXTRA_CMDS:LLVM=1 LLVM_IAS=1 

#Ccache,可加速二次构建
ENABLE_CCACHE=false 

#关闭fstack-protector-strong(clang-r383902b)
DISABLE_FST=false

#(0)使用Android NDK编译内核，NDK_VERSION可选的值有26,25,24,23,22,21,20,19,18,17,16,15
NDK_VERSION=21

#(1)谷歌官方的AOSP clang，对Build kernel Google git.yml生效
#AOSP 工具链参考选择可从70～106行的内容中进行选择
#更多可从这找 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/
#请以此为准，进行修改，
CLANG_BRANCH=android12-release
CLANG_VERSION=r416183b

#(2)第三方源的AOSP clang
#此配置对 Build Kernel on ubuntu 20.04（build-kernel_ubuntu20.04.yml)和Build Kernel on ubuntu 22.04（build-kernel_ubuntu22.04.yml)都生效
TCLANG_BRANCH=clang-r450784e

#目前存在的clang分支如下,即TCLANG_BRANCH的可取值（50～63行的内容）
#clang-r498229
#clang-r487747c
#clang-r487747b
#clang-r487747
#clang-r475365b
#clang-r475365
#clang-r468909b
#clang-r468909
#clang-r450784e
#clang-r450784d
#clang-r458507
#clang-r399163b
#clang-r383902
#clang-r353983c
#
# 

#(3)使用SD-clang构建内核，高通的clang编译器。默认启用启用分支10,目前存在的分支有 10,12,14,14.03
SD_CLANG_BRANCH=10

#比较合适的几类配置
#适合于老内核，安卓11及以下最稳的配置,默认此配置。运行构建时请使用 Build Kernel on ubuntu 20.04 (build-kernel.yml）此配置使用ubuntu 20.04。对于非常老的内核使用Google gcc-4.9构建，自行改一下。
#  android11-release
#  r383902b

#安卓12及以上，运行构建时请使用Build Kernel on ubuntu 22.04（build-kernel_ubuntu22.04.yml）
#  android12-release
#  r416183b


# 安卓 13
#  android13-release
#  r450784d

#主线,高版本内核使用
#  main
#  r475365b



                    ####CLANG_BRANCH###CLANG_VERSION###

#    main            android13-release    android12-release       android11-release        android10-release
#
#clang-3289846       clang-r450784d       clang-3289846           clang-3289846            clang-3289846
#clang-r450784e      clang-3289846        clang-r383902           clang-r353983c           clang-r328903
#clang-r475365b                           clang-r416183b          clang-r353983c1          clang-r339409b
#clang-r487747c                           clang-r416183b1         clang-r365631c           clang-r344140b 
#clang-r498229                                                    clang-r370808            clang-r346389b
#clang-r498229b                                                   clang-r370808b           clang-r346389c
#                                                                 clang-r377782b           clang-r349610
#                                                                 clang-r377782c           clang-r349610b
#                                                                 clang-r377782d           clang-r353983b
#                                                                 clang-r383902            clang-r353983c
#                                                                 clang-r383902b
#



#自定义工具链选择，选择proton-clang,该工具链针对AArch32、AArch64 和 x86 架构。它是用 LTO 和 PGO 构建的，以尽可能减少编译时间。
#官方版(已停止维护),最新到clang-13 https://github.com/kdrag0n/proton-clang
#若需要更旧的clang13以下 可到这找到https://github.com/kdrag0n/proton-clang/releases,自行改相关内容
#第三方维护版，最新到clang-17 ，默认使用此版。https://gitlab.com/LeCmnGend/proton-clang
#第三方维护版，目前存在的分支有 clang-13 , clang-14, clang-15, clang-16, clang-17

#(4)若要使用proton-clang，请使用build kernel by protonclang (build-kernel_by_proton-clang.yml)
ENABLE_PROTON_CLANG=true
PROTON_CLANG_SOURCE=https://gitlab.com/LeCmnGend/proton-clang
#PROTON_CLANG_BRANCH可选的值有 clang-13 ,clang-14, clang-15, clang-16, clang-17
PROTON_CLANG_BRANCH=clang-13



#(5)与proton-clang类似项目Neutron-clang,官网https://github.com/Neutron-Toolchains/
#目前存在版本 16,17,18
NEUTRON_CLANG_VERSION=16
#目前存在问题・_・?，为不可用状态。不想肝了，有得用就行了。主要是glibc问题，么么




#（6）使用LLVM，构建内核。
#目前存在版本 16,15,14,13,12,11,10
LLVM_CLANG_VERSION=10



#（7）使用ZyC clang，构建内核。该配置对build-kernel_by_ZyC-clang.yml生效
#目前存在版本 18,17,16.05,16
ZYC_CLANG_VERSION=16


#（8）使用ARM gcc，构建内核。该配置对build-kernel_by_ARM-gcc.yml生效
#目前存在版本 12.3  11.3  10.3  10.2 9.2 8.32  8.31  8.22  8.21
ARM_GCC_VERSION=8.21


#（9）还有一些固定配置，未列出的编译器，总之一句话，够用了，此编译器集足够编译2018年到现在的所有的内核版本，当然一些细节需要自己处理，自行研究吧。









~~~~~~~分割线～～～～～～～




用于 Non-GKI Kernel 的 Action，具有一定的普遍性，需要了解内核及 Android 的相关知识得以运用。

## 警告:warning: :warning: :warning:

如果你不是内核作者，使用他人的劳动成果构建 KernelSU，请仅供自己使用，不要分享给别人，这是对原作者的劳动成果的尊重。

## 支持内核

- `5.4`
- `4.19`
- `4.14`
- `4.9`

## 使用

> 所有 config.env 内的变量均只判断`true`

> 编译成功后，会在`Action`上传 AnyKernel3，已经关闭设备检查，请在 Twrp 刷入。

Fork 本仓库到你的储存库然后按照以下内容编辑 config.env，之后点击`Star`或`Action`，在左侧可看见`Build Kernel`选项，点击选项会看见右边的大对话框的上面会有`Run workflows`点击它会启动构建。

### Kernel Source

修改为你的内核仓库地址

例如: https://github.com/Diva-Room/Miku_kernel_xiaomi_wayne

### Kernel Source Branch

修改为你的内核分支

例如: TDA

### Kernel Config

修改为你的内核配置文件名

例如: vendor/wayne_defconfig

### Arch

例如: arm64

### Kernel Image Name

修改为需要刷写的 kernel binary，一般与你的 aosp-device tree 里的 BOARD_KERNEL_IMAGE_NAME 是一致的

例如: Image.gz-dtb

常见还有 Image、Image.gz

### Clang

#### Use custom clang

可以使用除 google 官方的 clang，如[proton-clang](https://github.com/kdrag0n/proton-clang)

#### Custom Clang Source

> 如果是 git 仓库，请填写包含`.git`的链接

支持 git 仓库或者 zip 压缩包的直链

#### Custom cmds

都用自定义 clang 了，自己改改这些配置应该都会吧 :)

#### Clang Branch

由于 [#23](https://github.com/xiaoleGun/KernelSU_Action/issues/23) 的需要，我们提供可自定义 Google 上游分支的选项，主要的有分支有
| Clang 分支 |
| ---------- |
| master |
| master-kernel-build-2021 |
| master-kernel-build-2022 |

或者其它分支，请根据自己的需求在 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 中寻找

#### Clang version

填写需要使用的 Clang 版本
| Clang 版本 | 对应 Android 版本 | AOSP-Clang 版本 |
| ---------- | ----------------- | --------------- |
| 12.0.5 | Android S | r416183b |
| 14.0.6 | Android T | r450784d |
| 14.0.7 | | r450784e |
| 15.0.1 | | r458507 |

一般 Clang12 就能通过大部分 4.14 及以上的内核的编译
我自己的 MI 6X 4.19 使用的是 r450784d

### GCC

#### Enable GCC 64

启用 GCC 64 交叉编译

#### Enable GCC 32

启用 GCC 32 交叉编译

### Extra cmds

有的内核需要加入一些其它编译命令，才能正常编译，一般不需要其它的命令，请自行搜索自己内核的资料
请在命令与命令之间用空格隔开

例如: LLVM=1 LLVM_IAS=1

### Enable KernelSU

启用 KernelSU，用于排查内核故障或单独编译内核

#### KernelSU Branch or Tag

选择 KernelSU 的分支或 tag:

- main 分支(开发版): `KERNELSU_TAG=main`
- 最新 TAG(稳定版): `KERNELSU_TAG=`
- 指定 TAG(如`v0.5.2`): `KERNELSU_TAG=v0.5.2`

#### KernelSU Manager signature size and hash

自定义KernelSU管理器签名的size值和hash值，如果不需要自定义管理器则请留空或填入官方默认值：

`KSU_EXPECTED_SIZE=0x033b`

`KSU_EXPECTED_HASH=0xb0b91415`

可键入`ksud debug get-sign <apk_path>`获取apk签名的size值和hash值

### Disable LTO

LTO 用于优化内核，但有些时候会导致错误

### Disable CC_WERROR

用于修复某些不支持或关闭了Kprobes的内核，修复KernelSU未检测到开启Kprobes的变量抛出警告导致错误

### Add Kprobes Config

自动在 defconfig 注入参数

### Add overlayfs Config

此参数为 KernelSU 模块和 system 分区读写提供支持
自动在 defconfig 注入参数

### Enable ccache

启用缓存，让第二次编译内核更快，最少可以减少 2/5 的时间

### Need DTBO

上传 DTBO
部分设备需要

### Build Boot IMG

> 从之前的 Workflows 合并进来的，可以查看历史提交

编译 boot.img，需要你提供`Source boot image`

### Source Boot Image

故名思义，提供一个源系统可以正常开机的 boot 镜像，需要直链，最好是同一套内核源码以及与你当前系统同一套设备树从 aosp 构建出来的。ramdisk 里面包含分区表以及 init，没有的话构建出来的镜像会无法正常引导。

例如: https://raw.githubusercontent.com/xiaoleGun/KernelSU_action/main/boot/boot-wayne-from-Miku-UI-latest.img

## 感谢

- [AnyKernel3](https://github.com/osm0sis/AnyKernel3)
- [AOSP](https://android.googlesource.com)
- [KernelSU](https://github.com/tiann/KernelSU)
- [xiaoxindada](https://github.com/xiaoxindada)
- [xiaoleGun](https://github.com/xiaoleGun/KernelSU_Action) 
- [qiuqiu](https://blog.qiuqiu233.top/)
- [grilix](https://github.com/grilix/kernel-docker-support)
- [wu17481748](https://github.com/wu17481748/LXC-DOCKER-KernelSU_Action)
- [kdrag0n](https://github.com/kdrag0n/proton-clang)
- [JonasCardoso](https://github.com/JonasCardoso/Toolchain)
- [Neebe3289](https://gitlab.com/Neebe3289/android_prebuilts_clang_host_linux-x86)
- [ZyCromerZ](https://github.com/ZyCromerZ/Clang)
- [ARM](https://developer.arm.com/-/media/Files/downloads/gnu)
- [LLVM](https://github.com/llvm/llvm-project/)
- [mvaisakh](https://github.com/mvaisakh/gcc-build)
- [HDTC](https://gitlab.com/HDTC/sdclang)
- [Neutron-Toolchains](https://github.com/Neutron-Toolchains)
- 
