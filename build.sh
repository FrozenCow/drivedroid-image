#!/bin/bash -x
set -o errexit

root="$(pwd)"
workdir=${root}/build
gummibootdir=/usr/lib/gummiboot
syslinuxdir=/usr/lib/syslinux
syslinuxbiosdir=/usr/lib/syslinux/bios
syslinuxefi64dir=/usr/lib/syslinux/efi64

# Use custom syslinux version
# syslinuxdir=${root}/syslinux/out/usr/share/syslinux
# syslinuxbiosdir=${syslinuxdir}
# syslinuxefi64dir=${syslinuxdir}/efi64

# Use custom gummiboot version
# gummiboot=${root}/gummiboot

outdir=${workdir}/out

# Clean up
rm -rf ${workdir}

# Populate root of ISO
mkdir -p ${workdir}/iso/
cp -r ${root}/root/* ${workdir}/iso/

# Prepare syslinux
cp  ${syslinuxbiosdir}/*.c32 \
    ${workdir}/iso/syslinux/

# Prepare isolinux
cp  ${syslinuxbiosdir}/isolinux.bin     \
    ${syslinuxbiosdir}/isohdpfx.bin     \
    ${syslinuxbiosdir}/ldlinux.c32      \
    ${workdir}/iso/isolinux/

# Prepare gummiboot
install -D ${gummibootdir}/gummibootx64.efi ${workdir}/iso/EFI/boot/bootx64.efi

# Prepare efiboot.img
install -d ${workdir}/iso/EFI/archiso/
dd if=/dev/zero of=${workdir}/iso/EFI/archiso/efiboot.img bs=2k count=100
mkdosfs ${workdir}/iso/EFI/archiso/efiboot.img
install -d ${workdir}/efiboot/
mount ${workdir}/iso/EFI/archiso/efiboot.img ${workdir}/efiboot/
install -D ${gummibootdir}/gummibootx64.efi ${workdir}/efiboot/EFI/boot/bootx64.efi
cp -r ${root}/root/loader ${workdir}/efiboot/loader
umount ${workdir}/efiboot/


# Create ISO
mkdir -p ${workdir}/out

_iso_efi_boot_args="-eltorito-alt-boot
    -e EFI/archiso/efiboot.img
    -no-emul-boot
    -isohybrid-gpt-basdat"
    # -preparer "prepared by mkarchiso" \
xorriso -as mkisofs \
    -iso-level 3 \
    -volid "drivedroid" \
    -appid "drivedroid" \
    -publisher "softwarebakery" \
    -graft-points \
    -full-iso9660-filenames \
    -eltorito-boot isolinux/isolinux.bin \
    -eltorito-catalog isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -isohybrid-mbr ${workdir}/iso/isolinux/isohdpfx.bin \
    ${_iso_efi_boot_args} \
    -output "${workdir}/out/drivedroid.iso" \
    -r \
    "${workdir}/iso/" --sort-weight 0 / --sort-weight 1 /isolinux

# Make iso hybrid (not sure whether this is still needed)
isohybrid --uefi ${workdir}/out/drivedroid.iso


# x64 UEFI CD-rom
# qemu-system-x86_64 -bios /usr/share/ovmf/x86_64/ovmf.bin -cdrom ${workdir}/out/drivedroid.iso

# x64 UEFI USB
# qemu-system-x86_64 -bios /usr/share/ovmf/x86_64/ovmf.bin -device piix3-usb-uhci -drive id=my_usb_disk,file=${workdir}/out/drivedroid.iso,if=none -device usb-storage,drive=my_usb_disk

# x64 MBR CD-rom
# qemu-system-x86_64 -cdrom ${workdir}/out/drivedroid.iso

# x64 MBR USB
qemu-system-x86_64 -device piix3-usb-uhci -drive id=my_usb_disk,file=${workdir}/out/drivedroid.iso,if=none -device usb-storage,drive=my_usb_disk

# x86 MBR CD-rom
# qemu-system-i386 -cdrom ${workdir}/out/drivedroid.iso

# X86 MBR USB
# qemu-system-i386 -device piix3-usb-uhci -drive id=my_usb_disk,file=${workdir}/out/drivedroid.iso,if=none -device usb-storage,drive=my_usb_disk

