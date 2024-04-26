##
 # Copyright (C) 2020 Alibaba Group Holding Limited
##
test = $(shell if [ -f "../.param" ]; then echo "exist"; else echo "noexist"; fi)
ifeq ("$(test)", "exist")
  include ../.param
endif

SDK_VER=v0.5

CONFIG_DEBUG_MODE=1
CONFIG_OUT_ENV=riscv_linux

CONFIG_BUILD_DRV_EXTRA_PARAM:=""
CONFIG_BUILD_TST_EXTRA_PARAM:=""

ifeq ("$(BUILD_SYSTEM)","YOCTO_BUILD")
  export PATH_TO_SYSROOT=${SYSROOT_DIR}
  export TOOLSCHAIN_PATH=${TOOLCHAIN_DIR}
  export TOOLCHAIN_HOST=${CROSS_COMPILE}
else
ifeq ("$(BUILD_SYSTEM)","BUILDROOT")
  export PATH_TO_SYSROOT=${BUILDROOT_DIR}/output/host/riscv64-buildroot-linux-gnu/sysroot
  export TOOLSCHAIN_PATH=${BUILDROOT_DIR}/output/host
  export TOOLCHAIN_HOST=${TOOLSCHAIN_PATH}/bin/riscv64-unknown-linux-gnu-
else
endif
endif
export PATH_TO_BUILDROOT=$(BUILDROOT_DIR)


DIR_TARGET_BASE=bsp/ddr-pmu
DIR_TARGET_KO =$(DIR_TARGET_BASE)/ko
DIR_TARGET_TEST=$(DIR_TARGET_BASE)/test

MODULE_NAME=THEAD-DDR-PMU
BUILD_LOG_START="\033[47;30m>>> $(MODULE_NAME) $@ begin\033[0m"
BUILD_LOG_END  ="\033[47;30m<<< $(MODULE_NAME) $@ end\033[0m"

#
# Do a parallel build with multiple jobs, based on the number of CPUs online
# in this system: 'make -j8' on a 8-CPU system, etc.
#
# (To override it, run 'make JOBS=1' and similar.)
#
ifeq ($(JOBS),)
  JOBS := $(shell grep -c ^processor /proc/cpuinfo 2>/dev/null)
  ifeq ($(JOBS),)
    JOBS := 1
  endif
endif

all:    info driver install_local_output install_rootfs
.PHONY: info driver install_local_output install_rootfs \
        install_prepare clean_driver clean_output clean

info:
	@echo $(BUILD_LOG_START)
	@echo "  ====== Build Info from repo project ======"
	@echo "    BUILD_SYSTEM="$(BUILD_SYSTEM)
	@echo "    BUILDROOT_DIR="$(BUILDROOT_DIR)
	@echo "    SYSROOT_DIR="$(SYSROOT_DIR)
	@echo "    CROSS_COMPILE="$(CROSS_COMPILE)
	@echo "    LINUX_DIR="$(LINUX_DIR)
	@echo "    ARCH="$(ARCH)
	@echo "    KBUILD_CFLAGS="$(KBUILD_CFLAGS)
	@echo "    KBUILD_AFLAGS="$(KBUILD_AFLAGS)
	@echo "    KBUILD_LDFLAGS="$(KBUILD_LDFLAGS)
	@echo "    BOARD_NAME="$(BOARD_NAME)
	@echo "    KERNEL_ID="$(KERNELVERSION)
	@echo "    KERNEL_DIR="$(LINUX_DIR)
	@echo "    CC="$(CC)
	@echo "    CXX="$(CXX)
	@echo "    LD="$(LD)
	@echo "    LD_LIBRARY_PATH="$(LD_LIBRARY_PATH)
	@echo "    rpath="$(rpath)
	@echo "    rpath-link="$(rpath-link)
	@echo "    INSTALL_DIR_ROOTFS="$(INSTALL_DIR_ROOTFS)
	@echo "    INSTALL_DIR_SDK="$(INSTALL_DIR_SDK)
	@echo "  ====== Build configuration by settings ======"
	@echo "    CONFIG_DEBUG_MODE="$(CONFIG_DEBUG_MODE)
	@echo "    CONFIG_OUT_ENV="$(CONFIG_OUT_ENV)
	@echo "    JOBS="$(JOBS)
	@echo "    SDK_VERSION="$(SDK_VER)
	@echo $(BUILD_LOG_END)

driver:
	@echo $(BUILD_LOG_START)
	make -C driver/light KDIR=$(LINUX_DIR) CROSS=$(CROSS_COMPILE) ARCH=$(ARCH)
	@echo $(BUILD_LOG_END)

clean_driver:
	@echo $(BUILD_LOG_START)
	make -C driver/light clean
	@echo $(BUILD_LOG_END)

install_prepare:
	mkdir -p ./output/rootfs/$(DIR_TARGET_KO)

install_local_output: driver install_prepare
	@echo $(BUILD_LOG_START)
	find ./driver -name "*.ko" | xargs -i cp -f {} ./output/rootfs/$(DIR_TARGET_KO)
	@if [ `command -v tree` != "" ]; then \
	    tree ./output/rootfs;             \
	fi
	@echo $(BUILD_LOG_END)

install_rootfs: install_local_output
	@echo $(BUILD_LOG_START)
	@echo $(BUILD_LOG_END)

clean_output:
	@echo $(BUILD_LOG_START)
	rm -rf ./output
	@echo $(BUILD_LOG_END)

clean: clean_output clean_driver

