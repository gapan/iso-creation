#!/bin/sh

export LANG=C

if [ "$UID" != "0" ]; then
	echo "You need to be root to run this"
	exit 1
fi

rm -rf secureboot-tmp
mkdir -p secureboot-tmp/{old,new}

mount -o loop isolinux/x86_64/efiboot.img secureboot-tmp/old
mv secureboot-tmp/old/EFI secureboot-tmp/new/
umount secureboot-tmp/old
rm isolinux/x86_64/efiboot.img
mv secureboot-tmp/new/EFI/BOOT/bootx64.efi \
	secureboot-tmp/new/EFI/BOOT/loader.efi
cp /boot/PreLoader.efi /secureboot-tmp/new/EFI/BOOT/bootx64.efi

sizeb=$(du -bc secureboot-tmp/new | grep 'total$' | cut -f1)
sizem=$((sizeb/1024/1024+10))
truncate -s $sizem isolinux/x86_64/efiboot.img
/sbin/mkfs.vfat -F16 -s 2 isolinux/x86_64/efiboot.img
mkdir -p secureboot-tmp/efiboot
mount -o loop isolinux/x86_64/efiboot.img secureboot-tmp/efiboot
mv secureboot-tmp/new/EFI secureboot-tmp/efiboot/
umount secureboot-tmp/efiboot
