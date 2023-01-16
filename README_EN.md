# KernelSU Action
Action for Non-GKI Kernel has some common and requires knowledge of kernel and Android to be used.

## Support Kernel
- `4.19`
## Usage
First fork this repo, then click on action, you will see the `Build Kernel` option, click on the option and you will see a dialog box on the right hand side with `Run workflows` in it, there are configurations that you need to type, see the section below to understand how to type them in.
### Kernel Source
Type your kernel link

e.g. https://github.com/Diva-Room/Miku_kernel_xiaomi_wayne
### Branch
Type your kernel branch

e.g. TDA
### Kernel Build Config
Type your kernel build config link

e.g. https://raw.githubusercontent.com/xiaoleGun/KernelSU_action/main/configs/build.config.wayne

There is not much you need to change in there, here is a comparison between the build config and the BoardConfig/BoardConfigCommon in the device tree.
| build config              | BoardConfig/BoardConfigCommon |
| ------------------------- | ----------------------------- |
| DEFCONFIG                 | TARGET_KERNEL_CONFIG          |
| BOOT_IMAGE_HEADER_VERSION | BOARD_BOOT_HEADER_VERSION     |
| BASE_ADDRESS              | BOARD_KERNEL_BASE             |
| PAGE_SIZE                 | BOARD_KERNEL_PAGESIZE         |
| KERNEL_CMDLINE            | BOARD_KERNEL_CMDLINE          |
| MKBOOTIMG_EXTRA_ARGS      | BOARD_MKBOOTIMG_ARGS          |
| KERNEL_BINARY             | BOARD_KERNEL_IMAGE_NAME       |

Here's what some of the options in the build config do
| build config          | do                                 |
| --------------------- | -----------------------------------|
| VENDOR_RAMDISK_BINARY | ramdisk path                       |
| ARCH                  | Architecture arm/arm64/x86_64      |
| BUILD_BOOT_IMG        | Create boot image for 1            |
| SKIP_VENDOR_BOOT      | Skip create vendor_boot for 1      |
| FILES                 | Need out files                     |
| CLANG_VERSION         | Define clang version               |

More to visits [build/build.sh](https://android.googlesource.com/kernel/build/+/refs/heads/master-kernel-build-2022/build.sh)
### Boot image to get ramdisk
Provide a boot image that will boot successfully, with the same kernel source code and the same device tree as your current system built from aosp, the ramdisk contains the partition table and init, without which it may reboot to fastboot.

e.g. https://raw.githubusercontent.com/xiaoleGun/KernelSU_action/main/boot/boot-wayne-from-Miku-UI-latest.img
