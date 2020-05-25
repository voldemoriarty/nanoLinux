#!/bin/bash

# this script generates ips and compiles the design
# however this must be run after the DDR pin assignments have been 
# added by 
# 1. Running Analysis & Synthesis
# 2. Run the DDR TCL
# This only needs to be done once
# I have a theory: the TCL adds the assignments to .qsf file. So once the 
# .qsf is made, no need to re run TCL. Have yet to test this

QSYS=soc_system.qsys
FAMILY=CycloneV
PART=5CSEBA6U23I7
TOP=LinuxDemo
SOF=$TOP.sof
RBF=$TOP.rbf

echo "======================================================"
echo "------------------ QSYS Generate ---------------------"
echo "======================================================"
qsys-generate $QSYS --synthesis=VERILOG --family=$FAMILY --part=$PART

echo "======================================================"
echo "----------------- Quartus Compile --------------------"
echo "======================================================"
quartus_sh --flow compile $TOP
quartus_cpf -c output_files/$SOF output_files/$RBF