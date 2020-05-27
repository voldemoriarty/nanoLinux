#!/bin/bash

# script to download and compile the latest release or 
# release canditate version of uboot for de10 nano
# Automatically configures uboot with the handoff files from
# the hardware project
# this script is meant to be run after the hardware
# is generated. 

set -e 

HWDIR=hardware
HANDOFFDIR=hps_isw_handoff/soc_system_hps
BOOTLOADERDIR=bootloader
SETTINGS=settings.bsp
QTSFILTER=$BOOTLOADERDIR/uboot/arch/arm/mach-socfpga/qts-filter.sh
BOARD=terasic/de10-nano  
UBOOT_CFG=socfpga_de10_nano_defconfig
BINDIR=binaries
RBF=LinuxDemo.rbf 
QSYS_SYSTEM=soc_system

# the path of the cross compiler
# make sure this is it
export CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf-

# check if bootloader directory exists
# if it does, assume these commands have already been run
if [ ! -d "$BOOTLOADERDIR/uboot" ]; then
  echo "Bootloader directory does not exist, downloading from git"
  # create directory for uboot
  mkdir -p $BOOTLOADERDIR/uboot
  mkdir -p $BOOTLOADERDIR/binaries

  # download uboot, don't download the history
  git clone https://github.com/altera-opensource/u-boot-socfpga --depth=1 $BOOTLOADERDIR/uboot

  # checkout the latest uboot release
  (cd $BOOTLOADERDIR/uboot; \
    REL=$(git tag -l rel* | head -n1); \
    notify-send "Building UBoot-$REL"; \
    git checkout $REL)
  
  # sanity check
  make -C $BOOTLOADERDIR/uboot distclean

  # configure uboot for de10 nano
  make -C $BOOTLOADERDIR/uboot $UBOOT_CFG 

  # update config to run u-boot.scr on boot
  # not sure if this is the best way to do it
  # but it gets it done
  echo "CONFIG_USE_BOOTCOMMAND=y" >> $BOOTLOADERDIR/uboot/.config 
  echo "CONFIG_BOOTCOMMAND=\"run fatscript\"" >> $BOOTLOADERDIR/uboot/.config 
  notify-send "To modify UBoot Config run 'make menuconfig' in bootloader/uboot"
else 
  echo "Bootloader directory exists, skipping download ..."
fi 

# these directories correspond to the sdcard partitions
# sdfs = FAT partition

if [ ! -d "sdfs" ]; then 
  mkdir sdfs 
fi 

# create the settings from the Qsys generated handoff
echo "Creating BSP Settings"
bsp-create-settings \
  --type spl \
  --bsp-dir $BOOTLOADERDIR \
  --preloader-settings-dir $HWDIR/$HANDOFFDIR \
  --settings $BOOTLOADERDIR/$SETTINGS


# update the qts files
echo "Updating QTS files for $BOARD"
$QTSFILTER \
  cyclone5 \
  $HWDIR/ \
  $BOOTLOADERDIR/ \
  $BOOTLOADERDIR/uboot/board/$BOARD/qts/

echo "Building uboot"
make -C $BOOTLOADERDIR/uboot -j$(nproc)

# create device tree from the qsys project
(cd $HWDIR; \
  sopc2dts --input soc_system.sopcinfo --output $QSYS_SYSTEM.dts --board soc_system_board_info.xml --board hps_common_board_info.xml --type dts --bridge-removal all --clocks; \
  dtc -I dts -O dtb -o $QSYS_SYSTEM.dtb $QSYS_SYSTEM.dts)

# copy the executables
cp -v $BOOTLOADERDIR/uboot/spl/u-boot-spl $BOOTLOADERDIR/$BINDIR/
cp -v $BOOTLOADERDIR/uboot/u-boot $BOOTLOADERDIR/$BINDIR/
cp -v $BOOTLOADERDIR/uboot/u-boot-with-spl.sfp $BOOTLOADERDIR/$BINDIR/
cp -v $HWDIR/output_files/$RBF sdfs 
cp -v $HWDIR/$QSYS_SYSTEM.dtb sdfs 

# create the compiled uboot script
./$BOOTLOADERDIR/uboot/tools/mkimage \
  -A arm \
  -O linux \
  -T script \
  -C none \
  -a 0 \
  -e 0 \
  -n DE10-Nano-Script \
  -d u-boot.script \
  sdfs/u-boot.scr

notify-send "UBoot build done"