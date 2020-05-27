#!/bin/bash

# script to download and compile the latest linux kernel
# for de10 nano

set -e 

KERNEL=kernel 
KERNEL_SRC=$KERNEL/source

if [ ! -d "kernel" ]; then 
  echo "Kernel directory does not exist, downloading ..."
  mkdir $KERNEL
  mkdir $KERNEL_SRC

  # download the source and checkout the latest release
  # the depth argument makes sure we don't download the entire history
  git clone https://github.com/altera-opensource/linux-socfpga --depth=1 $KERNEL_SRC
  
else 
  echo "Kernel directory exists, skipping download ..."
fi 

