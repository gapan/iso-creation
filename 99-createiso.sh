#!/bin/bash

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

CWD=`pwd`

if [ ! -f EDITION ]; then
	echo "No EDITION file."
	exit 1
else
	edition=`cat EDITION | tr '[:upper:]' '[:lower:]'`
fi

if [ ! -f ARCH ]; then
	echo "No ARCH file."
	exit 1
else
	arch=`cat ARCH`
fi

answer="$(eval dialog \
	--title \"Enter Salix version\" \
	--stdout \
	--inputbox \
	\"Enter the salix version you want to create the iso for.\n\You can add suffixes like alpha1, beta1, RC1 etc here.:\" \
	0 0 )"
retval=$?
if [ $retval -eq 1 ] || [ $retval -eq 255 ]; then
	exit 0
else
	ver=$answer
fi

unset LIBDIRSUFFIX
unset MKISOFS_EFI_OPTS
unset ISOHYBRID_EFI_OPTS
if [[ "$arch" == "x86_64" ]]; then
	export LIBDIRSUFFIX="64"
	MKISOFS_EFI_OPTS="-eltorito-alt-boot -no-emul-boot -eltorito-platform 0xEF -eltorito-boot isolinux/efiboot.img"
	ISOHYBRID_EFI_OPTS="--uefi"
fi

cd iso

mkisofs -o ../salix${LIBDIRSUFFIX}-${edition}-${ver}.iso \
  -R -J -A "Salix${LIBDIRSUFFIX} Install" \
  -V "Salix${LIBDIRSUFFIX} $edition $ver" \
  -hide-rr-moved \
  -v -d -N \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -sort isolinux/iso.sort \
  -b isolinux/isolinux.bin \
  -c isolinux/isolinux.boot \
  $MKISOFS_EFI_OPTS . 

cd ..
isohybrid $ISOHYBRID_EFI_OPTS salix${LIBDIRSUFFIX}-${edition}-${ver}.iso

