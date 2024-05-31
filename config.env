BULID_KERNEL_DIR=`pwd`
# 内核开源仓库地址
KERNEL_SOURCE=https://github.com/dsunnerer/kernel_apollo
# 仓库分支
KERNEL_SOURCE_BRANCH=ten
# CPU类型
export ARCH=arm64
# 配置文件
KERNEL_CONFIG=vendor/apollo_user_defconfig
KERNEL_NAME=${KERNEL_SOURCE##*/}

# 由GoogleSource提供的Clang编译器（到这里查找：https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+refs）
CLANG_BRANCH=android11-release
CLANG_VERSION=r365631c
# 由GoogleSource提供的64位Gcc编译器（到这里查找：https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+refs）
GCC64=android10-release
# 由GoogleSource提供的32位Gcc编译器（到这里查找：https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/+refs）
GCC32=

# 编译时使用的指令
BUILDKERNEL_CMDS="
CC=clang
CLANG_TRIPLE=aarch64-linux-gnu-
CROSS_COMPILE=aarch64-linux-androidkernel-
"

# 原始boot.img文件下载地址（可以从卡刷包或线刷包里提取，重命名为boot-source.img放到本脚本所在目录下）
SOURCE_BOOT_IMAGE_NEED_DOWNLOAD=false
SOURCE_BOOT_IMAGE=ftp://192.168.1.1/boot.img

# kprobe集成方案需要修改的参数（每个内核仓库需要开启的选项不统一，有的机型可能全都不用开，请自行逐个测试，第一个和第二个一般需要开）：
ADD_OVERLAYFS_CONFIG=true
ADD_KPROBES_CONFIG=true
DISABLE_CC_WERROR=false
DISABLE_LTO=false

CLANG_DIR=$BULID_KERNEL_DIR/clang/$CLANG_BRANCH-$CLANG_VERSION/bin
GCC64_DIR=$BULID_KERNEL_DIR/gcc/$GCC64-64/bin
GCC32_DIR=$BULID_KERNEL_DIR/gcc/$GCC32-32/bin

# 使用自定义Clang编译器
CLANG_CUSTOM=false
[ "$CLANG_CUSTOM" = true ] && {
	CLANG_DIR=/这里填写编译器文件夹的绝对路径/bin
	[ ! -d $CLANG_DIR ] && {
		echo "================================================================================"
		echo "本次编译中止！原因：自定义 Clang 编译器文件夹 $CLANG_DIR 不存在"
		echo "================================================================================" && return 2> /dev/null || exit
	}
}
# 使用自定义64位Gcc编译器
GCC64_CUSTOM=false
[ "$GCC64_CUSTOM" = true ] && {
	GCC64_DIR=/这里填写编译器文件夹的绝对路径/bin
	[ ! -d $GCC64_DIR ] && {
		echo "================================================================================"
		echo "本次编译中止！原因：自定义 64 位交叉编译器文件夹 $GCC64_DIR 不存在"
		echo "================================================================================" && return 2> /dev/null || exit
	}
}
# 使用自定义32位Gcc编译器
GCC32_CUSTOM=false
[ "$GCC32_CUSTOM" = true ] && {
	GCC32_DIR=/这里填写编译器文件夹的绝对路径/bin
	[ ! -d $GCC32_DIR ] && {
		echo "================================================================================"
		echo "本次编译中止！原因：自定义 32 位交叉编译器文件夹 $GCC32_DIR 不存在"
		echo "================================================================================" && return 2> /dev/null || exit
	}
}

[ ! -f /.Checked ] && {
	echo "================================================================================"
	echo "准备检查并安装基本依赖包（不一定齐全，不同内核开源仓库所需依赖包可能不同）"
	echo "================================================================================" && read -t 3
	apt update
	[ -n "$(uname -v | grep -o 16.04)" ] && {
		apt install git bison flex libssl-dev -y
		[ "$(python3 --version | grep -o 3.... | sed 's/\.//g')" -lt 380 ] && {
			wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tar.xz
			xz -dv Python-3.8.0.tar.xz
			tar -xvf Python-3.8.0.tar
			cd Python-3.8.0
			./configure
			make -j$(nproc --all)
			make install
			cd ..
			rm -rf Python-3.8.0 Python-3.8.0.tar
		}
	}
	[ -n "$(uname -v | grep -o 18.04)" ] && {
		apt install git make gcc bison flex libssl-dev zlib1g-dev -y
		[ "$(python3 --version | grep -o 3.... | sed 's/\.//g')" -lt 380 ] && {
			wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tar.xz
			xz -dv Python-3.8.0.tar.xz
			tar -xvf Python-3.8.0.tar
			cd Python-3.8.0
			./configure
			make -j$(nproc --all)
			make install
			cd ..
			rm -rf Python-3.8.0 Python-3.8.0.tar
		}
	}
	[ -n "$(uname -v | grep -o 20.04)" ] && apt install git make python-is-python2 gcc bison flex libssl-dev -y
	[ -n "$(uname -v | grep -o 22.04)" ] && ln -s /usr/bin/python3 /usr/bin/python && apt install git make gcc bison flex libssl-dev -y
	touch /.Checked
}

[ ! -d img_repack_tools ] && {
	echo "================================================================================"
	echo "准备下载 IMG 解包、打包工具"
	echo "================================================================================" && read -t 1
	git clone https://android.googlesource.com/platform/system/tools/mkbootimg img_repack_tools -b master-kernel-build-2022 --depth=1
	[ "$?" != 0 ] && {
		echo "================================================================================"
		echo "本次编译中止！原因：IMG 解包、打包工具下载失败"
		echo "================================================================================" && return 2> /dev/null || exit
	}
}

[ $SOURCE_BOOT_IMAGE_NEED_DOWNLOAD = true ] && {
	echo "================================================================================"
	echo "准备下载 IMG 备份文件"
	echo "================================================================================" && read -t 1
	wget -O boot-source.img $SOURCE_BOOT_IMAGE
}
[ ! -f boot-source.img -o "$SOURCE_BOOT_IMAGE_NEED_DOWNLOAD" = true -a "$?" != 0 ] && {
	echo "================================================================================" && rm -f boot-source.img
	echo "本次编译中止！原因：IMG 备份文件不存在，请确认配置的下载地址可以用于正常直链下载，或手动将备份文件重命名为 boot-source.img 后放置到 $BULID_KERNEL_DIR 文件夹中"
	echo "================================================================================" && return 2> /dev/null || exit
}

[ ! -d $KERNEL_NAME-$KERNEL_SOURCE_BRANCH ] && {
	echo "================================================================================"
	echo "准备获取安卓内核开源仓库"
	echo "================================================================================" && read -t 1
	git clone $KERNEL_SOURCE -b $KERNEL_SOURCE_BRANCH $KERNEL_NAME-$KERNEL_SOURCE_BRANCH --depth=1
	[ "$?" != 0 ] && {
		echo "================================================================================" && rm -rf $KERNEL_NAME-$KERNEL_SOURCE_BRANCH
		echo "本次编译中止！原因：安卓内核开源仓库获取失败"
		echo "================================================================================" && return 2> /dev/null || exit
	}
}

[ ! -d $CLANG_DIR ] && {
	echo "================================================================================"
	echo "准备下载 Clang 编译器"
	echo "================================================================================" && read -t 1
	wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/$CLANG_BRANCH/clang-$CLANG_VERSION.tar.gz
	[ "$?" != 0 ] && {
		wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/$CLANG_BRANCH/clang-$CLANG_VERSION.tar.gz
		[ "$?" != 0 ] && {
			echo "================================================================================" && rm -f clang-$CLANG_VERSION.tar.gz
			echo "本次编译中止！原因：Clang 编译器下载失败"
			echo "================================================================================" && return 2> /dev/null || exit
		}
	}
	mkdir -p clang/$CLANG_BRANCH-$CLANG_VERSION
	tar -C clang/$CLANG_BRANCH-$CLANG_VERSION/ -zxvf clang-$CLANG_VERSION.tar.gz
	rm -f clang-$CLANG_VERSION.tar.gz 
}

[ -n "$GCC64" -a ! -d $GCC64_DIR -a "$GCC64_CUSTOM" != true ] && {
	echo "================================================================================"
	echo "准备下载 64 位 GCC 交叉编译器"
	echo "================================================================================" && read -t 1
	wget -O gcc-$GCC64-64.tar.gz https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/refs/heads/$GCC64.tar.gz
	[ "$?" != 0 ] && {
		wget -O gcc-$GCC64-64.tar.gz https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/refs/tags/$GCC64.tar.gz
		[ "$?" != 0 ] && {
			echo "================================================================================" && rm -f gcc-$GCC64-64.tar.gz
			echo "本次编译中止！原因：64 位 GCC 交叉编译器下载失败"
			echo "================================================================================" && return 2> /dev/null || exit
		}
	}
	mkdir -p gcc/$GCC64-64
	tar -C gcc/$GCC64-64/ -zxvf gcc-$GCC64-64.tar.gz
	rm -f gcc-$GCC64-64.tar.gz
}
[ -n "$GCC32" -a ! -d $GCC32_DIR -a "$GCC32_CUSTOM" != true ] && {
	echo "================================================================================"
	echo "准备下载 32 位 GCC 交叉编译器"
	echo "================================================================================" && read -t 1
	wget -O gcc-$GCC32-32.tar.gz https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/+archive/refs/heads/$GCC32.tar.gz
	[ "$?" != 0 ] && {
		wget -O gcc-$GCC32-32.tar.gz https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/+archive/refs/tags/$GCC32.tar.gz
		[ "$?" != 0 ] && {
			echo "================================================================================" && rm -f gcc-$GCC32-32.tar.gz
			echo "本次编译中止！原因：32 位 GCC 交叉编译器下载失败"
			echo "================================================================================" && return 2> /dev/null || exit
		}
	}
	mkdir -p gcc/$GCC32-32
	tar -C gcc/$GCC32-32/ -zxvf gcc-$GCC32-32.tar.gz
	rm -f gcc-$GCC32-32.tar.gz
}

cd $KERNEL_NAME-$KERNEL_SOURCE_BRANCH
echo "================================================================================" && num="" && SUMODE=""
echo "你想使用哪种方式加入 KernelSU 到内核中？"
[ ! -d [kK][eE][rR][nN][eE][lL][sS][uU] -o -f Need_KernelSU ] && {
	echo "1.使用 kprobe 集成（有可能编译成功但无法开机，可以使用第二种方式进行尝试）"
	echo "2.修改内核源码（仅支持 KernelSU 0.6.1 或以上版本，0.6.0 或以下版本请用第一种方式进行尝试）"
}
echo "3.不作任何修改直接编译（第一次编译建议先用此选项进行尝试，如果编译成功并能正常开机后再加入 KernelSU 进行重新编译）"
[ -f retry ] && echo "4.上一次编译可能各种原因中断，接回上一次编译进度继续编译（选这个确认是否每次都在同一个位置出错）"
[ -f BUILD_KERNEL_COMPLETE -a -f Need_KernelSU ] && echo "5.编译完成并 KernelSU 已能正常使用，但手机重启后应用授权列表会丢失，选这里尝试使用修复方案"
[ -d KernelSU -a -f Need_KernelSU ] && echo "6.已手动修改完 KernelSU 代码，直接编译（跳过下载 KernelSU 源码步骤，需要手动修改代码修复问题时选这个）"
echo "7.已编译完成，仅修改内核包名进行打包操作"
echo "0.退出本次编译"
echo "================================================================================"

while [[ "$num" != [0-7] ]];do
	read -p "请输入正确的数字 > " num
	case "$num" in
	1)
		SUMODE="使用 kprobe 集成"
		[ -d [kK][eE][rR][nN][eE][lL][sS][uU] -a ! -f Need_KernelSU ] && num="" && SUMODE=""
		;;
	2)
		SUMODE="修改内核源码"
		[ -d [kK][eE][rR][nN][eE][lL][sS][uU] -a ! -f Need_KernelSU ] && num="" && SUMODE=""
		;;
	4)
		[ ! -f retry ] && num=""
		;;
	5)
		[ ! -f BUILD_KERNEL_COMPLETE -o ! -f Need_KernelSU ] && num=""
		;;
	6)
		[ ! -d KernelSU -o ! -f Need_KernelSU ] && num=""
		;;
	0)
		echo "================================================================================"
		echo "已退出本次编译"
		echo "================================================================================" && return 2> /dev/null || exit
	esac
done

[[ "$num" = [1-2] ]] && {
	echo "================================================================================"
	echo "你想使用哪个版本的 KernelSU 加入到内核中？" && sunum="" && sutag="" && SUVERSION=""
	echo "1.最新版"
	echo "2.自定义输入版本号"
	echo "0.退出本次编译"
	echo "================================================================================"
	while [[ "$sunum" != [0-2] ]];do
		read -p "请输入正确的数字 > " sunum
		case "$sunum" in
		1)
			SUVERSION="最新版"
			;;
		2)
			read -p "请直接输入版本号，如：0.6.9 > " sutag
			sutag=v$sutag && SUVERSION="自定义输入版本号 $sutag"
			;;
		0)
			echo "================================================================================"
			echo "已退出本次编译"
			echo "================================================================================" && return 2> /dev/null || exit
		esac
	done
}

[[ "$num" = [1-3] ]] && {
	[ -f retry ] && rm -f retry
	[ -d KernelSU -a -f Need_KernelSU ] && rm -rf KernelSU drivers/kernelsu drivers/common/kernelsu
	[ -f drivers/Kconfig.backup ] && mv -f drivers/Kconfig.backup drivers/Kconfig 2> /dev/null
	[ -f drivers/Makefile.backup ] && mv -f drivers/Makefile.backup drivers/Makefile 2> /dev/null
	[ -f drivers/common/Kconfig.backup ] && mv -f drivers/common/Kconfig.backup drivers/common/Kconfig 2> /dev/null
	[ -f drivers/common/Makefile.backup ] && mv -f drivers/common/Makefile.backup drivers/common/Makefile 2> /dev/null
	[ -f arch/$ARCH/configs/$KERNEL_CONFIG.backup ] && mv -f arch/$ARCH/configs/$KERNEL_CONFIG.backup arch/$ARCH/configs/$KERNEL_CONFIG
	[ -f fs/exec.c.backup ] && mv -f fs/exec.c.backup fs/exec.c
	[ -f fs/read_write.c.backup ] && mv -f fs/read_write.c.backup fs/read_write.c
	[ -f fs/open.c.backup ] && mv -f fs/open.c.backup fs/open.c
	[ -f fs/stat.c.backup ] && mv -f fs/stat.c.backup fs/stat.c
	[ -f drivers/input/input.c.backup ] && mv -f drivers/input/input.c.backup drivers/input/input.c
}

[[ "$num" = [1-2] ]] && {
	[ ! -f NoneKernelSU ] && touch Need_KernelSU
	[ ! -f drivers/Kconfig.backup ] && cp drivers/Kconfig drivers/Kconfig.backup 2> /dev/null
	[ ! -f drivers/Makefile.backup ] && cp drivers/Makefile drivers/Makefile.backup 2> /dev/null
	[ ! -f drivers/common/Kconfig.backup ] && cp drivers/Kconfig drivers/common/Kconfig.backup 2> /dev/null
	[ ! -f drivers/common/Makefile.backup ] && cp drivers/Makefile drivers/common/Makefile.backup 2> /dev/null
	echo "================================================================================" && rm -rf out
	echo " 准备下载 KernelSU 源码，请等候······"
	echo "================================================================================" && read -t 1
	if [ "${sutag::1}" = v ];then
		wget https://github.com/tiann/KernelSU/archive/refs/tags/$sutag.tar.gz
		[ "$?" != 0 ] && {
			echo "================================================================================"
			echo "本次编译中止！原因：KernelSU $SUVERSION 源码下载失败，请确认是否有此版本存在"
			echo "================================================================================" && return 2> /dev/null || exit
		}
		tar -zxf $sutag.tar.gz
		mv -f `echo KernelSU-$sutag | sed 's/-v/-/'` KernelSU && rm $sutag.tar.gz
	else
		git clone https://github.com/tiann/KernelSU
		[ "$?" != 0 ] && {
			echo "================================================================================"
			echo "本次编译中止！原因：KernelSU $SUVERSION 源码下载失败"
			echo "================================================================================" && return 2> /dev/null || exit
		}
		cd KernelSU;git checkout "$(git describe --abbrev=0 --tags)" &> /dev/null
		SUVERSION="$SUVERSION：$(grep $(cat .git/HEAD) .git/packed-refs | awk -F '/' {'print $3'} | tail -n1)";cd ..
	fi;
	if [ -d common/drivers ];then
		ln -sf ../../KernelSU/kernel drivers/common/kernelsu
		grep -q kernelsu drivers/common/Makefile || echo "obj-\$(CONFIG_KSU)		+= kernelsu/" >> drivers/common/Makefile
		grep -q kernelsu drivers/common/Kconfig || sed -i "/endmenu/i\\source \"drivers/kernelsu/Kconfig\"\\n" drivers/common/Kconfig
	else
		ln -sf ../KernelSU/kernel drivers/kernelsu
		grep -q kernelsu drivers/Makefile || echo "obj-\$(CONFIG_KSU)		+= kernelsu/" >> drivers/Makefile
		grep -q kernelsu drivers/Kconfig || sed -i "/endmenu/i\\source \"drivers/kernelsu/Kconfig\"\\n" drivers/Kconfig
	fi
}

[ "$num" = 5 ] && {
	echo "================================================================================"
	echo "请选择以下可用修复方案" && fixnum=""
	echo "1.尝试修复开机后丢失用户授权列表（ KernelSU 0.6.7 或以上版本）"
	echo "X.因为没有其它有问题的设备用于测试，所以其它的修复代码暂时不写了，请自行参考下面地址"
	echo "X.其他有可能会遇到的问题解决方案：https://github.com/tiann/KernelSU/issues/943"
	echo "0.退出本次编译"
	echo "================================================================================"
	while [[ "$fixnum" != [0-1] ]];do
		read -p "请输入正确的数字 > " fixnum
		[ "$fixnum" = 0 ] && {
			echo "================================================================================"
			echo "已退出本次编译"
			echo "================================================================================" && return 2> /dev/null || exit
		}
	done;rm -rf out
	[ -f KernelSU/kernel/core_hook.c.backup ] && mv -f KernelSU/kernel/core_hook.c.backup KernelSU/kernel/core_hook.c && mv -f KernelSU/kernel/kernel_compat.c.backup KernelSU/kernel/kernel_compat.c && mv -f KernelSU/kernel/kernel_compat.h.backup KernelSU/kernel/kernel_compat.h
}

[ "$num" = 1 ] && {
	[ ! -f arch/$ARCH/configs/$KERNEL_CONFIG.backup ] && cp arch/$ARCH/configs/$KERNEL_CONFIG arch/$ARCH/configs/$KERNEL_CONFIG.backup
	[ $DISABLE_LTO = true ] && {
		sed -i 's/CONFIG_LTO=y/CONFIG_LTO=n/' arch/$ARCH/configs/$KERNEL_CONFIG && echo "参数 CONFIG_LTO=y 已修改为 CONFIG_LTO=n" && read -t 1
		sed -i 's/CONFIG_LTO_CLANG=y/CONFIG_LTO_CLANG=n/' arch/$ARCH/configs/$KERNEL_CONFIG && echo "参数 CONFIG_LTO_CLANG=y 已修改为 CONFIG_LTO_CLANG=n" && read -t 1
		sed -i 's/CONFIG_THINLTO=y/CONFIG_THINLTO=n/' arch/$ARCH/configs/$KERNEL_CONFIG && echo "参数 CONFIG_THINLTO=y 已修改为 CONFIG_THINLTO=n" && read -t 1
		[ -z "$(grep CONFIG_LTO_NONE=y arch/$ARCH/configs/$KERNEL_CONFIG)" ] && sed -i 's/CONFIG_LTO_NONE /d/' arch/$ARCH/configs/$KERNEL_CONFIG && echo "CONFIG_LTO_NONE=y" >> arch/$ARCH/configs/$KERNEL_CONFIG && echo "参数 CONFIG_LTO_NONE=y 已加入到配置文件中" && read -t 1
	}
	[ $DISABLE_CC_WERROR = true ] && {
		[ -z "$(grep CONFIG_CC_WERROR=n arch/$ARCH/configs/$KERNEL_CONFIG)" ] && sed -i 's/CONFIG_CC_WERROR /d/' arch/$ARCH/configs/$KERNEL_CONFIG && echo "CONFIG_CC_WERROR=n" >> arch/$ARCH/configs/$KERNEL_CONFIG && echo "参数 CONFIG_CC_WERROR=n 已加入到配置文件中" && read -t 1
	}
	[ $ADD_KPROBES_CONFIG = true ] && {
		[ -z "$(grep CONFIG_MODULES=y arch/$ARCH/configs/$KERNEL_CONFIG)" ] && sed -i 's/CONFIG_MODULES /d/' arch/$ARCH/configs/$KERNEL_CONFIG && echo "CONFIG_MODULES=y" >> arch/$ARCH/configs/$KERNEL_CONFIG && echo "参数 CONFIG_MODULES=y 已加入到配置文件中" && read -t 1
		[ -z "$(grep CONFIG_KPROBES=y arch/$ARCH/configs/$KERNEL_CONFIG)" ] && sed -i 's/CONFIG_KPROBES /d/' arch/$ARCH/configs/$KERNEL_CONFIG && echo "CONFIG_KPROBES=y" >> arch/$ARCH/configs/$KERNEL_CONFIG && echo "参数 CONFIG_KPROBES=y 已加入到配置文件中" && read -t 1
		[ -z "$(grep CONFIG_HAVE_KPROBES=y arch/$ARCH/configs/$KERNEL_CONFIG)" ] && sed -i 's/CONFIG_HAVE_KPROBES /d/' arch/$ARCH/configs/$KERNEL_CONFIG && echo "CONFIG_HAVE_KPROBES=y" >> arch/$ARCH/configs/$KERNEL_CONFIG && echo "参数 CONFIG_HAVE_KPROBES=y 已加入到配置文件中" && read -t 1
		[ -z "$(grep CONFIG_KPROBE_EVENTS=y arch/$ARCH/configs/$KERNEL_CONFIG)" ] && sed -i 's/CONFIG_KPROBE_EVENTS /d/' arch/$ARCH/configs/$KERNEL_CONFIG && echo "CONFIG_KPROBE_EVENTS=y" >> arch/$ARCH/configs/$KERNEL_CONFIG && echo "参数 CONFIG_KPROBE_EVENTS=y 已加入到配置文件中" && read -t 1
	}
	[ $ADD_OVERLAYFS_CONFIG = true ] && {
		[ -z "$(grep CONFIG_OVERLAY_FS=y arch/$ARCH/configs/$KERNEL_CONFIG)" ] && sed -i 's/CONFIG_OVERLAY_FS /d/' arch/$ARCH/configs/$KERNEL_CONFIG && echo "CONFIG_OVERLAY_FS=y" >> arch/$ARCH/configs/$KERNEL_CONFIG && echo "参数 CONFIG_OVERLAY_FS=y 已加入到配置文件中" && read -t 1
	}
}

[ "$num" = 2 ] && {
	[ ! -f fs/exec.c.backup ] && cp fs/exec.c fs/exec.c.backup
	[ ! -f fs/read_write.c.backup ] && cp fs/read_write.c fs/read_write.c.backup
	[ ! -f fs/open.c.backup ] && cp fs/open.c fs/open.c.backup
	[ ! -f fs/stat.c.backup ] && cp fs/stat.c fs/stat.c.backup
	[ ! -f drivers/input/input.c.backup ] && cp drivers/input/input.c drivers/input/input.c.backup
	[ -n "$(grep 'static int do_execveat_common(int fd, struct filename \*filename,' fs/exec.c)" ] && {
		cat > add_sucode << EOF
extern bool ksu_execveat_hook __read_mostly;
extern int ksu_handle_execveat(int *fd, struct filename **filename_ptr, void *argv,
			void *envp, int *flags);
extern int ksu_handle_execveat_sucompat(int *fd, struct filename **filename_ptr,
				 void *argv, void *envp, int *flags);
EOF
		line=$(($(sed -n '/static int do_execveat_common(int fd, struct filename \*filename,/=' fs/exec.c)-1))
		[ "$line" != -1 ] && sed -i ''$line'r add_sucode' fs/exec.c
		cat > add_sucode << EOF
	if (unlikely(ksu_execveat_hook))
		ksu_handle_execveat(&fd, &filename, &argv, &envp, &flags);
	else
		ksu_handle_execveat_sucompat(&fd, &filename, &argv, &envp, &flags);
EOF
		line=$(($(sed -n '/return __do_execve_file(fd, filename, argv, envp, flags, NULL);/=' fs/exec.c)-1))
		[ "$line" != -1 ] && sed -i ''$line'r add_sucode' fs/exec.c
	}
	[ -n "$(grep 'ssize_t vfs_read(struct file \*file, char __user \*buf, size_t count, loff_t \*pos)' fs/read_write.c)" ] && {
		cat > add_sucode << EOF
extern bool ksu_vfs_read_hook __read_mostly;
extern int ksu_handle_vfs_read(struct file **file_ptr, char __user **buf_ptr,
			size_t *count_ptr, loff_t **pos);
EOF
		line=$(($(sed -n '/ssize_t vfs_read(struct file \*file, char __user \*buf, size_t count, loff_t \*pos)/=' fs/read_write.c)-1))
		[ "$line" != -1 ] && sed -i ''$line'r add_sucode' fs/read_write.c
		cat > add_sucode << EOF
	if (unlikely(ksu_vfs_read_hook))
		ksu_handle_vfs_read(&file, &buf, &count, &pos);
EOF
		line=$(($(sed -n '/ssize_t vfs_read(struct file \*file, char __user \*buf, size_t count, loff_t \*pos)/=' fs/read_write.c)+3))
		[ "$line" != 3 ] && sed -i ''$line'r add_sucode' fs/read_write.c
	}
	[ -n "$(grep '\* access() needs to use the real uid\/gid, not the effective uid\/gid.' fs/open.c)" ] && {
		cat > add_sucode << EOF
extern int ksu_handle_faccessat(int *dfd, const char __user **filename_user, int *mode,
			 int *flags);
EOF
		line=$(($(sed -n '/\* access() needs to use the real uid\/gid, not the effective uid\/gid./=' fs/open.c)-2))
		[ "$line" != -2 ] && sed -i ''$line'r add_sucode' fs/open.c
		cat > add_sucode << EOF
	ksu_handle_faccessat(&dfd, &filename, &mode, NULL);
EOF
		if [ -n "$(grep 'long do_faccessat(int dfd, const char __user \*filename, int mode)' fs/open.c)" ];then
			line=$(($(sed -n '/long do_faccessat(int dfd, const char __user \*filename, int mode)/=' fs/open.c)+1))
			[ "$line" != 1 ] && sed -i ''$line'r add_sucode' fs/open.c
		elif [ -n "$(grep "if (mode & ~S_IRWXO)	/\* where's F_OK, X_OK, W_OK, R_OK? \*/" fs/open.c)" ];then
			line=$(($(sed -n "/if (mode & ~S_IRWXO)	\/\* where's F_OK, X_OK, W_OK, R_OK? \*\//=" fs/open.c)-1))
			[ "$line" != -1 ] && sed -i ''$line'r add_sucode' fs/open.c
		fi
	}
	cat > add_sucode << EOF
extern int ksu_handle_stat(int *dfd, const char __user **filename_user, int *flags);
EOF
	cat > add_sucode2 << EOF
	ksu_handle_stat(&dfd, &filename, &flags);
EOF
	if [ -n "$(grep 'EXPORT_SYMBOL(vfs_statx_fd);' fs/stat.c)" ];then
		line=$(($(sed -n '/EXPORT_SYMBOL(vfs_statx_fd);/=' fs/stat.c)+1))
		[ "$line" != 1 ] && sed -i ''$line'r add_sucode' fs/stat.c
		line=$(($(sed -n '/if ((flags & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |/=' fs/stat.c)-1))
		[ "$line" != -1 ] && sed -i ''$line'r add_sucode2' fs/stat.c
	elif [ -n "$(grep 'EXPORT_SYMBOL(vfs_fstat);') fs/stat.c" ];then
		line=$(($(sed -n '/EXPORT_SYMBOL(vfs_fstat);/=' fs/stat.c)+1))
		[ "$line" != 1 ] && sed -i ''$line'r add_sucode' fs/stat.c
		line=$(($(sed -n '/if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |/=' fs/stat.c)-1))
		[ "$line" != -1 ] && sed -i ''$line'r add_sucode2' fs/stat.c
	fi
	
	[ -n "$(grep 'static void input_handle_event(struct input_dev \*dev,' drivers/input/input.c)" ] && {
		cat > add_sucode << EOF
extern bool ksu_input_hook __read_mostly;
extern int ksu_handle_input_handle_event(unsigned int *type, unsigned int *code, int *value);
EOF
		line=$(($(sed -n '/static void input_handle_event(struct input_dev \*dev,/=' drivers/input/input.c)-1))
		[ "$line" != -1 ] && sed -i ''$line'r add_sucode' drivers/input/input.c
		cat > add_sucode << EOF
	if (unlikely(ksu_input_hook))
		ksu_handle_input_handle_event(&type, &code, &value);
EOF
		line=$(($(sed -n '/static void input_handle_event(struct input_dev \*dev,/=' drivers/input/input.c)+3))
		[ "$line" != 3 ] && sed -i ''$line'r add_sucode' drivers/input/input.c
	}
	rm -f add_sucode add_sucode2
}

[ "$fixnum" = 1 ] && {
	[ ! -f KernelSU/kernel/core_hook.c.backup ] && \
	cp KernelSU/kernel/core_hook.c KernelSU/kernel/core_hook.c.backup && \
	cp KernelSU/kernel/kernel_compat.c KernelSU/kernel/kernel_compat.c.backup && \
	cp KernelSU/kernel/kernel_compat.h KernelSU/kernel/kernel_compat.h.backup
	sed -i 's/LINUX_VERSION_CODE < KERNEL_VERSION(4, 10, 0)/1/' KernelSU/kernel/core_hook.c KernelSU/kernel/kernel_compat.c KernelSU/kernel/kernel_compat.h
}

[[ "$num" = [1-3,5-6] ]] && {
	[ -d out ] && {
	#	echo "================================================================================"
	#	echo "检测到有上一次编译留下的文件，可能会影响编译结果，是否删除？" && del=""
	#	echo "1.确认删除"
	#	echo "0.跳过，继续编译"
	#	echo "================================================================================"
	#	while [[ "$del" != [0-1] ]];do
	#		read -p "请输入正确的数字 > " del
	#		[ "$del" = 1 ] && {
				rm -rf out
				echo "================================================================================"
				echo " 文件夹 $BULID_KERNEL_DIR/$KERNEL_NAME-$KERNEL_SOURCE_BRANCH/out 已删除"
				echo "================================================================================" && read -t 1
	#		}
	#	done
	}
}

[ "$num" != 7 ] && {
	export SUBARCH=$ARCH
	export PATH=$CLANG_DIR:$PATH
	[ -n "$GCC64_DIR" ] && export PATH=$GCC64_DIR:$PATH
	[ -n "$GCC32_DIR" ] && export PATH=$GCC32_DIR:$PATH
	[ -f BUILD_KERNEL_COMPLETE ] && rm -f BUILD_KERNEL_COMPLETE
	[ "$num" != 4 ] && make -j$(nproc --all) O=out $BUILDKERNEL_CMDS $KERNEL_CONFIG
	touch retry && num="";make -j$(nproc --all) O=out $BUILDKERNEL_CMDS
	if [ "$?" = 0 ];then
		[ -d KernelSU -a -f Need_KernelSU ] && touch BUILD_KERNEL_COMPLETE
		echo "================================================================================"
		echo "内核仓库：$KERNEL_SOURCE"
		echo "仓库分支：$KERNEL_SOURCE_BRANCH"
		[ "$CLANG_CUSTOM" = true ] && \
		echo "自定义 Clang 编译器：$CLANG_DIR" || \
		echo "Clang 编译器：$CLANG_BRANCH-$CLANG_VERSION"
		[ "$GCC64_CUSTOM" = true ] && \
		echo "自定义 64 位 Gcc 交叉编译器：$GCC64_DIR" || \
		echo "64 位 Gcc 交叉编译器：$GCC64"
		[ "$GCC32_CUSTOM" = true ] && \
		echo "自定义 32 位 Gcc 交叉编译器：$GCC32_DIR" || \
		echo "32 位 Gcc 交叉编译器：$GCC32"
		echo "加入 KernelSU 方式：$SUMODE"
		echo "加入 KernelSU 版本：$SUVERSION"
		echo "本次编译使用指令：make -j$(nproc --all) O=out $(echo $BUILDKERNEL_CMDS | sed ':i;N;s/\n/ /;ti')"
		echo "================================================================================"
		echo "编译成功！将进行 boot.img 文件重新打包"
		echo "================================================================================" && num=7 && rm -f retry && read -t 3
	else
		echo "================================================================================"
		echo "内核仓库：$KERNEL_SOURCE"
		echo "仓库分支：$KERNEL_SOURCE_BRANCH"
		[ "$CLANG_CUSTOM" = true ] && \
		echo "自定义 Clang 编译器：$CLANG_DIR" || \
		echo "Clang 编译器：$CLANG_BRANCH-$CLANG_VERSION"
		[ "$GCC64_CUSTOM" = true ] && \
		echo "自定义 64 位 Gcc 交叉编译器：$GCC64_DIR" || \
		echo "64 位 Gcc 交叉编译器：$GCC64"
		[ "$GCC32_CUSTOM" = true ] && \
		echo "自定义 32 位 Gcc 交叉编译器：$GCC32_DIR" || \
		echo "32 位 Gcc 交叉编译器：$GCC32"
		echo "加入 KernelSU 方式：$SUMODE"
		echo "加入 KernelSU 版本：$SUVERSION"
		echo "本次编译使用指令：make -j$(nproc --all) O=out $(echo $BUILDKERNEL_CMDS | sed ':i;N;s/\n/ /;ti')"
		echo "================================================================================"
		echo "编译失败！请自行根据上面编译过程中的提示检查错误"
		echo "若非每次都在同一个地方出错，有可能是系统内存不足导致卡机失败"
		echo "可以直接重新编译进行尝试，如果是用虚拟机编译请尽量分配多一点的内存给虚拟机"
		echo "如果只提示（make[*]: *** [*****/*****：*****] 错误 *）"
		echo "但这条信息的上面没有明确提示什么错误的，很有可能是这个内核仓库源码本身有问题"
		echo "================================================================================"
	fi;
}

[ "$num" = 7 ] && {
	cd $BULID_KERNEL_DIR && KERNEL_IMAGE_NAME=""
	while [ ! -f $KERNEL_NAME-$KERNEL_SOURCE_BRANCH/out/arch/$ARCH/boot/$KERNEL_IMAGE_NAME ];do
		echo "================================================================================" && image=""
		[ -n "$KERNEL_IMAGE_NAME" ] && echo "内核 $KERNEL_NAME-$KERNEL_SOURCE_BRANCH/out/arch/$ARCH/boot/$KERNEL_IMAGE_NAME 文件不存在！请重新选择内核文件名" || \
		echo "哪一个是编译出来的内核文件？这将会用于打包 boot.img（一般就下面三个其中一个，不知道的可以逐个尝试）"
		echo "1.Image"
		echo "2.Image.gz"
		echo "3.Image.gz-dtb"
		echo "4.自定义输入"
		echo "0.退出打包操作"
		echo "================================================================================"
		while [[ "$image" != [0-4] ]];do
			read -p "请输入正确的数字 > " image
			case "$image" in
			1)
				KERNEL_IMAGE_NAME=Image
				;;
			2)
				KERNEL_IMAGE_NAME=Image.gz
				;;
			3)
				KERNEL_IMAGE_NAME=Image.gz-dtb
				;;
			4)
				read -p "请输入编译出来后的内核文件的名称： > " KERNEL_IMAGE_NAME
				;;
			0)
				echo "================================================================================"
				echo "已退出本次打包操作"
				echo "================================================================================" && return 2> /dev/null || exit
			esac
		done
	done
	img_repack_tools/unpack_bootimg.py --boot_img boot-source.img --format mkbootimg --out=img_repack_tools/out > BuildBootInfo 2> /dev/null
	[ "$?" != 0 ] && {
		echo "================================================================================" && rm -f BuildBootInfo
		echo "本次打包中止！原因：boot-source.img 文件错误（可能未完全下载成功？）"
		echo "================================================================================" && return 2> /dev/null || exit
	}
	echo "cp $KERNEL_NAME-$KERNEL_SOURCE_BRANCH/out/arch/$ARCH/boot/$KERNEL_IMAGE_NAME img_repack_tools/out/kernel" >> BuildBoot
	echo "img_repack_tools/mkbootimg.py $(cat BuildBootInfo) -o boot.img" >> BuildBoot
	echo "================================================================================" && source BuildBoot
	echo "打包成功！打包后的 boot.img 文件已存放于 $BULID_KERNEL_DIR 中"
	echo "fastboot 刷入时建议不要直接加入 flash 参数来进行刷入，等能开机了再真正刷入到手机"
	echo "刷入手机后首次开机可能会比较慢，请耐心等候"
	echo "如果加入 KernelSU 后能正常使用，但有各种小问题，可再运行本脚本选 5 尝试进行修复"
	echo "脚本制作不易，如果本脚本对你有用，希望能打赏支持一下！非常感谢！！！"
	echo "支持一下：https://github.com/xilaochengv/BuildKernelSU"
	echo "================================================================================" && rm -f BuildBootInfo BuildBoot
}
