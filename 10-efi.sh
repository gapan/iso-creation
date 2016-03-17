#!/bin/sh
#
# This script get the EFI files from slackware and adapts them
# to Salix.
#
# You will first need to install curlftpfs to use it.

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

set -e

if [ ! -f ARCH ]; then
	echo "No ARCH file."
	exit 1
else
	arch=`cat ARCH`
fi

if [ ! -f VERSION ]; then
	echo "No VERSION file."
	exit 1
else
	ver=`cat VERSION`
fi

# FIXME
#
# This is temporary. When slackware releases 14.2, remove this line
ver=current

if [ ! -d isolinux/x86_64 ]; then
	echo "I can't find the isolinux files."
	exit 1
fi

CWD=`pwd`

if [[ "$arch" != "x86_64" ]]; then
	echo "This only works for x86_64."
	exit 1
fi

# clean up previous files
rm -rf efi
mkdir efi

# get the slack EFI files
echo "Getting the slackware EFI files..."
(
  cd efi
  wget -np -nH --cut-dirs=2 -r -R huge.s,initrd.img ftp://ftp.slackware.uk/slackware/slackware64-$ver/EFI
)
(
  cd isolinux/x86_64
  wget -np -nH --cut-dirs=3 -r ftp://ftp.slackware.uk/slackware/slackware64-$ver/isolinux/efiboot.img
)

# copy over the grub.cfg file to be used. This ones includes menu
# entries for all available languages.
cp efi-files/grub.cfg efi/EFI/BOOT

echo "DONE!"
set +e
