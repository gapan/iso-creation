#!/bin/sh
#
# This script creates an efiboot.img file that includes elilo and can
# boot the installation media on UEFI systems

if [ "$UID" -ne "0" ]; then
	echo "You need to be root to run this"
	exit 1
fi

set -e

if [ ! -f USER ]; then
	echo "No USER file."
	exit 1
fi
user=`cat USER`

if [ ! -f ARCH ]; then
	echo "No ARCH file."
	exit 1
else
	arch=`cat ARCH`
fi

if [ ! -f kernel/x86_64/huge.s/bzImage ]; then
	echo "I can't find the kernel in kernel/x86_64/huge.s/bzImage"
	exit 1
fi

if [ ! -f initrd/x86_64/initrd.img ]; then
	echo "I can't find initrd/x86_64/initrd.img"
	exit 1
fi

CWD=`pwd`

if [[ "$arch" != "x86_64" ]]; then
	echo "This only works for x86_64."
	exit 1
fi

rm -rf efi
mkdir -p efi/EFI/BOOT

# Create the efiboot.img file
dd if=/dev/zero of=isolinux/x86_64/efiboot.img bs=1M count=51

# Format the image as FAT12:
mkdosfs -F 12 isolinux/x86_64/efiboot.img

# Create a temporary mount point and mount the efiboot.img file there
MOUNTPOINT=$(mktemp -d)
mount -o loop isolinux/x86_64/efiboot.img $MOUNTPOINT

# Create efi/EFI/BOOT inside the efiboot.img file
mkdir -p $MOUNTPOINT/EFI/BOOT

# Copy elilo-x86_64.efi from the host system (make sure the latest
# version of elilo is installed)
cp /boot/elilo-x86_64.efi $MOUNTPOINT/EFI/BOOT/BOOTx64.EFI
# Now also in the efi directory
cp /boot/elilo-x86_64.efi efi/EFI/BOOT/BOOTx64.EFI

# Finally copy elilo menu files
# in the efiboot.img
cp efi-files/* $MOUNTPOINT/EFI/BOOT/
# as well as the efi directory...
cp efi-files/* efi/EFI/BOOT/

# copy the kernel in the same places...
cp kernel/x86_64/huge.s/bzImage $MOUNTPOINT/EFI/BOOT/
cp kernel/x86_64/huge.s/bzImage efi/EFI/BOOT/
# and put the initrd in there too
cp initrd/x86_64/initrd.img $MOUNTPOINT/EFI/BOOT/
cp initrd/x86_64/initrd.img efi/EFI/BOOT/

# Unmount and clean up:
umount $MOUNTPOINT
rmdir $MOUNTPOINT

# chown everything back
chown -R ${user}:users isolinux/x86_64/efiboot.img

echo "DONE!"
set +e
