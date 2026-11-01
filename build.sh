#!/bin/bash
set -eE


cmd=$(realpath $0)
SDK_ROOT_DIR=$(dirname $cmd)

C_BLACK="\e[30;1m"
C_RED="\e[31;1m"
C_GREEN="\e[32;1m"
C_YELLOW="\e[33;1m"
C_BLUE="\e[34;1m"
C_PURPLE="\e[35;1m"
C_CYAN="\e[36;1m"
C_WHITE="\e[37;1m"
C_NORMAL="\033[0m"

export PATH="${SDK_ROOT_DIR}/tools/toolchain/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin:$PATH"

function msg_info() {
	echo -e "${C_GREEN}[$(basename $0):info] $1${C_NORMAL}"
}

function msg_warn() {
	echo -e "${C_YELLOW}[$(basename $0):warn] $1${C_NORMAL}"
}

function msg_error() {
	echo -e "${C_RED}[$(basename $0):error] $1${C_NORMAL}"
}

function usage() {
	echo "Usage: build.sh [OPTIONS]"
	echo "Available options:"
	echo "uboot              -build uboot"
    echo "kernel             -build kernel"
    echo "rootfs             -build rootfs"
	echo ""
	echo "clean uboot        -clean uboot"
    echo "clean kernel       -clean kernel"
    echo "clean rootfs       -clean rootfs"
	exit 0
}

function build_uboot() {
	echo "============Start building uboot============"
	echo "CROSS_COMPILE=arm-linux-gnueabihf-"
    echo "mx6ull_14x14_ddr512_emmc_defconfig"
	echo "========================================="

    make -C uboot ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- mx6ull_14x14_ddr512_emmc_defconfig
    make -C uboot ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j$(nproc)
}

function build_kernel() {
	echo "============Start building kernel============"
	echo "CROSS_COMPILE=arm-linux-gnueabihf-"
    echo "imx_v7_defconfig"
	echo "========================================="

    make -C kernel ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- imx_v7_defconfig
    make -C kernel ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- all -j$(nproc)
}

function build_rootfs() {
	echo "============Start building rootfs============"
	echo "buildroot"
	echo "========================================="
    make -C rootfs ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- rootfs
}

function build_clean() {
	param="${1}"
	msg_info "clean ${param}"
	case $param in
	uboot)
		make -C uboot ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- distclean
		;;
	kernel)
		make -C kernel ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- distclean
		;;
	rootfs)
		make -C rootfs ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- distclean
		;;
	*)
		msg_warn "clean [$1] not support, ignore"
		;;
	esac
}



num=$#
option=""
while [ $# -ne 0 ]; do
    case $1 in 
    uboot) option=build_uboot ;;
    kernel) option=build_kernel ;;
    rootfs) option=build_rootfs ;;
	clean)
		option="build_clean $2"
		break
		;;
    *) option=usage ;;
	esac
	if [ $((num)) -gt 0 ]; then
		shift
	fi
done

eval "${option}"