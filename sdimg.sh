#!/bin/bash
echo "====================="
echo "Creating sdcard image"
echo "====================="


sudo ./make_sdimage_p3.py -f \
-P bootloader/binaries/u-boot-with-spl.sfp,num=3,format=raw,size=10M,type=A2  \
-P sdfs,num=1,format=vfat,size=200M \
-s 500M \
-n sdcard_cv.img