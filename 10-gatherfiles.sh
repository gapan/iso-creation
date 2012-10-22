#!/bin/sh

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

if [ ! $# -eq 1 ]; then
	echo "ERROR. Syntax is: $0 ARCH [both_smp_nonsmp]"
	exit 1
fi

arch=$1
smp=$2

mkdir -p iso/isolinux
mkdir -p iso/kernels

cp -r isolinux/$arch/* iso/isolinux/
cp -r kernel/$arch/* iso/kernels/
cp README iso/

# remove the non-smp initrd and kernel files if building an smp-only iso
if [ $arch == "i486" ]; then
	if [ $smp != "both_smp_nonsmp" ]; then
		sed -i "/huge\.s/d" iso/isolinux/isolinux.cfg
		sed -i "/huge\.s/d" iso/isolinux/message.txt
		sed -i "/Pentium-pro/d" iso/isolinux/message.txt
		rm iso/isolinux/nonsmp.img
		rm -r iso/kernels/huge.s
	fi
fi
