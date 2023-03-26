# KernelSU Action For Begonia

Action for Non-GKI Kernel has some common and requires knowledge of kernel and Android to be used.

## Warning:warning: :warning: :warning:

If you are not a kernel author and use someone else's source code to build KernelSU, please use it for your own use only and do not share it with others, it is respectful to the author.

## Support Kernel

- `4.19`
- `4.14`

## Usage

> After successful build, it will upload AnyKernel3 in `Action`, which has turned off device check, please flash to phone in Twrp.

First fork this repository to your repository and edit config.env as follows, then click `Star` or `Action`, you will see `Build Kernel` option on the left side, click it and you will see `Run workflows` on the top of the big dialog box on the right side, click it and it will start the build.

### Kernel Source

Type your kernel link

e.g. https://github.com/begonia-dev/android_kernel_xiaomi_mt6785

### Kernel Source Branch

Type your kernel branch

e.g. 13.0

### Kernel defconfig

Type your kernel defconfig

e.g. begonia_user_defconfig

### Target arch

e.g. arm64

### Kernel file

Type in the image you need, usually the same as BOARD_KERNEL_IMAGE_NAME in your aosp-device tree.

e.g. Image.gz-dtb

### Clang version

Type the version of Clang you need to use
| Clang version | Corresponding Android version | AOSP-Clang version |
| ------------- | ----------------------------- | ------------------ |
| 14.0.7 | | r450784e |
| 15.0.1 | | r458507 |
| 15.0.3 | | r468909b |
| 16.0.2 | | r475365b |
| 17.0.0 | | r487747 |

Usually Clang14 will pass most kernel builds of 4.14 and above.
My own Redmi Note 8 Pro 4.14 is using r487747.

### Extra build commands

Some kernels require some build commands to be typed in manually in order to build properly, so please don't type them in if you don't need to.
Separate commands with spaces.

e.g. LLVM=1 LLVM_IAS=1

### Disable LTO

This is used to optimize the kernel, but sometimes it causes errors, so it is provided that it can be disabled, set to true to disable.

### Use KernelSU

For debug kernel or build it separately

### Use Kprobes

If your kernel Kprobes is working properly, changing this to "true" will automatically add the parameter to defconfig.

### Use overlayfs

Please enable this parameter if the kernel does not have it, the module requires

### Need DTBO

If your kernel also needs to be flashed with DTBO image, set it to true.

### Make boot image
> Merge from build_boot_image.yml

Set to true, boot.img will be Make, you need to provide `Source boot image`

### Source boot image

Provide a boot image that will boot successfully, with the same kernel source code and the same device tree as your current system built from aosp, the ramdisk contains the partition table and init, without which it may reboot to fastboot.

e.g. https://raw.githubusercontent.com/xiaoleGun/KernelSU_action/main/boot/boot-wayne-from-Miku-UI-latest.img

## Credits

- [AnyKernel3](https://github.com/osm0sis/AnyKernel3)
- [AOSP](https://android.googlesource.com)
- [KernelSU](https://github.com/tiann/KernelSU)
- [xiaoxindada](https://github.com/xiaoxindada)
