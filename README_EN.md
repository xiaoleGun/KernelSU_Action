# KernelSU Action
Action for Non-GKI Kernel has some common and requires knowledge of kernel and Android to be used.

## Support Kernel
- `4.19`
- `4.14`
## Usage
First fork this repo, then click on action, you will see the `Build Kernel` option, click on the option and you will see a dialog box on the right hand side with `Run workflows` in it, there are configurations that you need to type, see the section below to understand how to type them in.
### Build Kernel Common
After successful build, it will upload AnyKernel3 in `Action`, which has turned off device check, please flash to phone in Twrp.
#### Kernel Source
Type your kernel link

e.g. https://github.com/Diva-Room/Miku_kernel_xiaomi_wayne
#### Branch
Type your kernel branch

e.g. TDA
#### Kernel defconfig
Type your kernel defconfig

e.g. vendor/wayne_defconfig
#### Kernel file
Type in the image you need, usually the same as BOARD_KERNEL_IMAGE_NAME in your aosp-device tree.

e.g. Image-gz-dtb
#### Clang-version
Type the version of Clang you need to use
| Clang version | Corresponding Android version | AOSP-Clang version |
| ------------- | ----------------------------- | ------------------ |
| 12.0.5        | Android S                     | r416183b1          |
| 14.0.6        | Android T                     | r450784d           |
| 14.0.7        |                               | r450784e           |
| 15.0.1        |                               | r458507            |

Usually Clang12 will pass most kernel builds of 4.14 and above.
My own MI 6X 4.19 is using r450784d.
#### Kprobes
If your kernel Kprobes is working properly, changing this to "true" will automatically add the parameter to defconfig.
### Build boot image
After a successful build, boot-su.img will be uploaded in `Action` and flashed to the phone using fastboot.
#### Kernel Source
Type your kernel link

e.g. https://github.com/Diva-Room/Miku_kernel_xiaomi_wayne
#### Branch
Type your kernel branch

e.g. TDA
#### Kernel Build Config
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

## Credits
- [KernelSU](https://github.com/tiann/KernelSU)
