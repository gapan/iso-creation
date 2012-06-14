#!/bin/sh

if [ ! $# -eq 4 ]; then
	echo "ERROR. Syntax is: $0 EDITION ARCH VERSION ISO_FILENAME"
	exit 1
fi

CWD=`pwd`
edition=$1
arch=$2
ver=$3
iso=$4

unset LIBDIRSUFFIX
if [[ "$arch" == "x86_64" ]]; then
	export LIBDIRSUFFIX="64"
fi

cd iso

mkisofs -o ../$iso \
  -R -J -A "Salix${LIBDIRSUFFIX} Install" \
  -hide-rr-moved \
  -v -d -N \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -sort isolinux/iso.sort \
  -b isolinux/isolinux.bin \
  -c isolinux/isolinux.boot \
  -V "Salix${LIBDIRSUFFIX} $edition $ver" .

cd ..
isohybrid $iso
