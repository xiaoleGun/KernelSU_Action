# KernelSU Action

This action is for Non-GKI Kernels and has some universality and requires knowledge of the kernel and Android.

## Warning:warning::warning::warning:

If you are not the author of the Kernel, and are using someone else's labor to build KernelSU, please use it for personal use only and do not share it with others. This is to show respect for the author's labor achievements.

## Supported Kernel Versions

- `5.4`
- `4.19`
- `4.14`
- `4.9`

## Usage

> All variables in the `config.env` file are only checked for `true`.

> Once the compilation is successful, AnyKernel3 will be uploaded in the `Action` and the device check has been disabled. Please flash it in TWRP.

Fork this repository to your storage account and edit the `config.env` file with the following content. Afterward, click `Star` or `Action`. On the left side, you can see the `Build Kernel` option. Click on it, and you will find the `Run workflows` option above the dialog. Click on it to start the build.

### Kernel Source

Change this to your Kernel repository address.

For example - https://github.com/Diva-Room/Miku_kernel_xiaomi_wayne

### Kernel Source Branch

Change this to your Kernel branch.

For example - TDA

### Kernel Config

Change this to your kernel configuration file name.

For example: `vendor/wayne_defconfig`

### Arch

For example: arm64

### Kernel Image Name

Change this to the kernel binary that needs to be flashed, generally consistent with `BOARD_KERNEL_IMAGE_NAME` in your AOSP device tree.

For example: `Image.gz-dtb`

Common names include `Image`, `Image.gz`.

### Clang

#### Use custom clang

You can use a non-official clang such as [proton-clang](https://github.com/kdrag0n/proton-clang).

#### Custom Clang Source

> Fill in a link that includes `.git` if it is a git repository.

Git repository or direct chain of compressed zip files is supported.

#### Custom cmds

If you're using custom clang, you should be able to modify these settings on your own. :)

#### Clang Branch

Due to [#23](https://github.com/xiaoleGun/KernelSU_Action/issues/23), we provide an option to customize the Google main branch. The main ones include:
| Clang Branch |
| ------------ |
| master |
| master-kernel-build-2021 |
| master-kernel-build-2022 |

Or other branches, please search for them according to your own needs at https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86.

#### Clang Version

Enter the Clang version to use.

| Clang Version | Corresponding Android Version | AOSP-Clang Version |
| ------------- | ----------------------------- | ------------------ |
| 12.0.5 | Android S | r416183b |
| 14.0.6 | Android T | r450784d |
| 14.0.7 | | r450784e |
| 15.0.1 | | r458507 |

Generally, Clang12 can compile most of the 4.14 and above kernels. My MI 6X 4.19 uses r450784d.

### GCC

#### Enable GCC 64

Enable GCC 64C cross-compiler.

#### Enable GCC 32

Enable GCC 32C cross-compiler.

### Extra cmds

Some kernels require additional compilation commands to compile correctly. Generally, no other commands are needed, so please search for information about your kernel. Please separate the command and the command with a space.

For example: `LLVM=1 LLVM_IAS=1`

### Disable LTO

LTO is used to optimize the kernel but sometimes causes errors.

### Enable KernelSU

Enable KernelSU for troubleshooting kernel failures or compiling the kernel separately.

#### KernelSU Branch or Tag

Select the branch or tag of KernelSU:

- main branch (development version): `KERNELSU_TAG=main`
- Latest TAG (stable version): `KERNELSU_TAG=`
- Specify the TAG (such as `v0.5.2`): `KERNELSU_TAG=v0.5.2`

### Add Kprobes Config

Inject parameters into the defconfig automatically.

### Add overlayfs Config

This parameter provides support for the KernelSU module and system partition read and write. Inject parameters into Defconfig automatically.

### Enable ccache

Enable the cache to make the second kernel compile faster. It can reduce the time by at least 2/5.

### Need DTBO

Upload DTBO. Some devices require it.

### Build Boot IMG

> Added from previous workflows, view historical commits

Build boot.img, and you need to provide a `Source boot image`.

### Source Boot Image

As the name suggests, it provides a boot image source system that can boot normally and requires a direct chain, preferably from the same kernel source and AOSP device tree as your current system. Ramdisk contains the partition table and init, without which the compiled image will not boot up properly.

For example: https://raw.githubusercontent.com/xiaoleGun/KernelSU_action/main/boot/boot-wayne-from-Miku-UI-latest.img

## Thanks

- [AnyKernel3](https://github.com/osm0sis/AnyKernel3)
- [AOSP](https://android.googlesource.com)
- [KernelSU](https://github.com/tiann/KernelSU)
- [xiaoxindada](https://github.com/xiaoxindada)
