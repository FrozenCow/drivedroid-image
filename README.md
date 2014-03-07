# drivedroid-image

This project aims to create a bootable ISO/IMG that works on:

* CD-rom drives
* USB drives
* MBR capable machines
* UEFI capable machines, including Mac
* x86 architecture
* x86\_64 architecture

In addition it tries to be as minimal as possible so that it can be included into [DriveDroid](http://softwarebakery.com/projects/drivedroid). It therefore does not include any Linux kernel, only a Syslinux and Gummiboot bootloader.

It is based on the ISO files ArchLinux distributes.

## Requirements

I'm running this on ArchLinux, which needs the following:

    pacman -S syslinux gummiboot libisoburn

To get a title in UEFI, you need a custom build of gummiboot located [here](https://github.com/FrozenCow/gummiboot).

## Building

Run:

    ./build.sh

This will create the ISO in `build/out/drivedroid.iso` and runs qemu to test the image.

