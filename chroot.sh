#!/bin/bash

# if no command line argument given, chroot into rootfs directory
# otherwise can chroot directly in sdcard, ./chroot.sh $PATH_TO_SD_CARD_ROOTFS_PARTITION
ROOTFS=${1:-rootfs}

# the holy trinity
sudo mount -o bind  /dev  $ROOTFS/dev 
sudo mount -t sysfs /sys  $ROOTFS/sys 
sudo mount -t proc  /proc $ROOTFS/proc 

sudo cp -v /proc/mounts             $ROOTFS/etc/mtab 
sudo cp -v /etc/resolv.conf         $ROOTFS/etc/resolv.conf 
sudo cp -v /usr/bin/qemu-arm-static $ROOTFS/usr/bin 

sudo chroot $ROOTFS

# clean up
echo "Clean up"
sudo umount $ROOTFS/proc 
sudo umount $ROOTFS/sys 
sudo umount $ROOTFS/dev 