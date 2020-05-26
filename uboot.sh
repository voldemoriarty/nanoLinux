#!/bin/bash

# this script is meant to be run after the hardware
# is generated. Takes the handoff files from the qsys
# generated files and compiles the latest release version
# of altera socfpga uboot

set -e 

HWDIR=hardware
HANDOFFDIR=hps_isw_handoff/soc_system_hps
BOOTLOADERDIR=bootloader
SETTINGS=settings.bsp
QTSFILTER=$BOOTLOADERDIR/uboot/arch/arm/mach-socfpga/qts-filter.sh
BOARD=terasic/de10-nano  
UBOOT_CFG=socfpga_de10_nano_defconfig
BINDIR=binaries

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
  
  # sanity check
  make -C $BOOTLOADERDIR/uboot distclean
else 
  echo "Bootloader directory exists, skipping download ..."
fi 

# create the settings from the Qsys generated handoff
echo "Creating BSP Settings"
bsp-create-settings \
  --type spl \
  --bsp-dir $BOOTLOADERDIR \
  --preloader-settings-dir $HWDIR/$HANDOFFDIR \
  --settings $BOOTLOADERDIR/$SETTINGS

# do uboot specific stuff
(cd $BOOTLOADERDIR/uboot; \
  REL=$(git tag -l rel* | head -n1); \
  echo "Building $REL"; \
  git checkout $REL)

# update the qts files
echo "Updating QTS files for $BOARD"
$QTSFILTER \
  cyclone5 \
  $HWDIR/ \
  $BOOTLOADERDIR/ \
  $BOOTLOADERDIR/uboot/board/$BOARD/qts/

echo "Building uboot"
make -C $BOOTLOADERDIR/uboot $UBOOT_CFG 
make -C $BOOTLOADERDIR/uboot -j$(nproc)

# copy the executables
cp -v $BOOTLOADERDIR/uboot/spl/u-boot-spl $BOOTLOADERDIR/$BINDIR/
cp -v $BOOTLOADERDIR/uboot/u-boot $BOOTLOADERDIR/$BINDIR/
cp -v $BOOTLOADERDIR/uboot/u-boot-with-spl.sfp $BOOTLOADERDIR/$BINDIR/