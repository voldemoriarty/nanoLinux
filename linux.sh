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
BROOT=buildroot
BROOT_SRC=$BROOT/source 

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

if [ ! -d "buildroot" ]; then
  echo "Buildroot directory does not exist, downloading ..."
  mkdir $BROOT
  mkdir $BROOT_SRC

  git clone git://git.buildroot.net/buildroot $BROOT_SRC
  (cd $BROOT_SRC; \
    REL=$(git tag -l 2020.* | tail -n1); \
    notify-send "Building Buildroot $REL"; \
    git checkout $REL)

  # this step requires user input
  cp -v buildroot.config $BROOT_SRC
else 
  echo "Buildroot directory exists, skipping download ..."
fi

make -C $KERNEL_SRC ARCH=arm LOCALVERSION=$KERNEL_IMG -j$(nproc)
notify-send "Kernel build complete. Now building Buildroot"
cp -v $KERNEL_SRC/arch/arm/boot/$KERNEL_IMG $SDFS

make -C $BROOT_SRC all -j$(nproc)
notify-send "Buildroot build complete. Updating rootfs"
if [ -d "$ROOTFS" ]; then rm -rf $ROOTFS; fi
mkdir $ROOTFS 
tar -xvf $BROOT_SRC/output/images/rootfs.tar -C $ROOTFS