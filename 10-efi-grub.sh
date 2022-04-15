#!/bin/bash

VER=`cat VERSION`
SLACKREPO=http://download.salixos.org/x86_64/slackware-$VER

rm -rf efi
mkdir -p efi/EFI/BOOT

FILES="bootx64.efi grub-embedded.cfg grub.cfg osdetect.cfg tools.cfg"
MIRROR=https://download.salixos.org
cd efi/EFI/BOOT
for f in $FILES; do
	[ ! -f $f ] && wget -q $MIRROR/x86_64/slackware-$VER/EFI/BOOT/$f
done
cd -
cp initrd/x86_64/initrd.img efi/EFI/BOOT/
cp efi-files/grub/grub.cfg efi/EFI/BOOT/
cp kernel/x86_64/huge.s/bzImage efi/EFI/BOOT/huge.s
wget $SLACKREPO/isolinux/efiboot.img -O isolinux/x86_64/efiboot.img

