#!/bin/bash

# script to download and compile the latest linux kernel
# and builtroot for de10 nano

set -e 

KERNEL=kernel 
KERNEL_SRC=$KERNEL/source
KERNEL_CFG=socfpga_defconfig
KERNEL_IMG=zImage
SDFS=sdfs
ROOTFS=rootfs

UBUNTU_VER=20.04
UBUNTU_TAR=ubuntu-base-$UBUNTU_VER-base-armhf.tar.gz

TOOLCHAIN=/usr/bin/arm-linux-gnueabihf
export CROSS_COMPILE=$TOOLCHAIN-

if [ ! -d "kernel" ]; then 
  echo "Kernel directory does not exist, downloading ..."
  mkdir $KERNEL
  mkdir $KERNEL_SRC

  # download the source and checkout the latest release
  # the depth argument makes sure we don't download the entire history
  git clone https://github.com/altera-opensource/linux-socfpga --depth=1 $KERNEL_SRC
  (cd $KERNEL_SRC; \
    REL=$(git tag -l rel_* | tail -n1); \
    notify-send "Building Kernel $REL"; \
    git checkout $REL)

  # default configuration of the kernel
  make -C $KERNEL_SRC ARCH=arm $KERNEL_CFG
  notify-send "Using $KERNEL_CFG. To edit, run 'make ARCH=arm menuconfig' in $KERNEL_SRC"
else 
  echo "Kernel directory exists, skipping download ..."
fi 

make -C $KERNEL_SRC ARCH=arm LOCALVERSION=$KERNEL_IMG -j$(nproc)
cp -v $KERNEL_SRC/arch/arm/boot/$KERNEL_IMG $SDFS

if [ ! -d "$ROOTFS" ]; then
  echo "rootfs directory does not exist, downloading ubuntu base $UBUNTU_VER ..."
  wget -O "$UBUNTU_TAR" "cdimage.ubuntu.com/ubuntu-base/releases/$UBUNTU_VER/release/$UBUNTU_TAR"
  mkdir $ROOTFS 
  tar -xvf "$UBUNTU_TAR" -C $ROOTFS/
else 
  echo "rootfs directory exists, skipping download ..."
fi