# nanoLinux
A linux builder for the DE10 Nano. It builds the latest uBoot, Linux Kernel and a Buildroot based rootfs to be used on the DE10 Nano. The hardware design is very minimal with the ARM HPS connected only to LEDs and Switches through LWH2F bridge. You can freely modify the hardware design, the scripts will automatically configure uBoot Device Trees according to Qsys generated design files.

Most of the flow is automated. The only step requiring user input modification of script variables

## PreRequisites
  - Quartus 19 (Older versions **will not work**)
  - SoC EDS 19
  - `arm-linux-gnueabihf` GCC toolchain (`apt install gcc-arm-linux-gnueabihf`)
  - Build Essentials
  - All commands run in Embedded Command Shell

## Prep
If you did not install in `/usr/bin` then you need to edit the `CROSS_COMPILE` variable in `uboot.sh` and `linux.sh`. To find out where your toolchain is installed run 

```bash 
 which arm-linux-gnueabihf-gcc
```

## Hardware Project
The Quartus project is in `hardware` directory. A script called `compile.sh` will compile the design. It is very minimal. The Qsys for the design is:
