#!/bin/sh

if [ ! $# -eq 1 ]; then
	echo "ERROR. Syntax is: $0 ARCH"
	exit 1
fi

arch=$1

mkdir -p iso/isolinux
mkdir -p iso/kernels

cp -r isolinux/$arch/* iso/isolinux/
cp -r kernel/$arch/* iso/kernels/
cp README iso/
