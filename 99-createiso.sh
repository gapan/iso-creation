#!/bin/bash


 if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi


ISOHYBRID_MBR=/usr/share/syslinux/isohdpfx.bin

if [ ! -f $ISOHYBRID_MBR ]; then
	echo "syslinux is not installed"
	exit 1
fi

if [ ! -x /usr/bin/xorriso ]; then
	echo "libisoburn is not installed"
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
	\"Enter the salix version you want to create the iso for. You can add suffixes like alpha1, beta1, RC1 etc here.:\" \
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
if [ "$arch" = "x86_64" ]; then
	export LIBDIRSUFFIX="64"
	EFIOPTIONS="-eltorito-alt-boot -e isolinux/efiboot.img"
fi

(
  cd iso
  xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -R -J -A "Salix${LIBDIRSUFFIX} Install" \
    -hide-rr-moved \
    -v -d -N \
    -eltorito-boot isolinux/isolinux.bin \
    -eltorito-catalog isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -isohybrid-mbr $ISOHYBRID_MBR \
    $EFIOPTIONS -no-emul-boot -isohybrid-gpt-basdat \
    -volid "Salix-${ver}" \
    -output ../salix${LIBDIRSUFFIX}-${edition}-${ver}.iso \
    .
)

# Distrowatch like to have this easily accessible
cp iso/PACKAGELIST salix${LIBDIRSUFFIX}-${edition}-${ver}.pkglist
