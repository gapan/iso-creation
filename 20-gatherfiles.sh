#!/bin/sh

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

if [ ! -f ARCH ]; then
	echo "No ARCH file."
	exit 1
else
	arch=`cat ARCH`
fi

if [ ! -f EDITION ]; then
	echo "No EDITION file."
	exit 1
else
	edition=`cat EDITION | tr '[:upper:]' '[:lower:]'`
fi

rm -rf iso/{isolinux,kernels,README,EFI}

mkdir -p iso/isolinux
mkdir -p iso/kernels

cp -r isolinux/$arch/* iso/isolinux/
cp -r kernel/$arch/* iso/kernels/
cp README.iso iso/README

if [ $arch == "x86_64" ]; then
	cp -r efi/EFI iso/
fi

if [ $edition == "none" ]; then
	rm iso/salix/*/*
fi
