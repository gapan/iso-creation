#!/bin/sh
#
# This script extracts the kernel image files+friends from the kernel
# packages that have been previously downloaded and places them inside
# the kernels directory

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
	VER=`cat VERSION`
fi

REPO=https://download.salixos.org/$arch/slackware-$VER/kernels

rm -rf kernel/$arch

get_kernel() {
	KERNEL=$1
	mkdir -p kernel/$arch/$KERNEL
	cd kernel/$arch/$KERNEL
	wget --no-verbose $REPO/$KERNEL/bzImage
	wget --no-verbose $REPO/$KERNEL/System.map.gz
	wget --no-verbose $REPO/$KERNEL/config
	cd ../../..
}

# get the slack kernel
echo "Getting the slackware kernel..."
if [[ "$arch" == "i486" ]]; then
	get_kernel hugesmp.s
	if [ -f iso/salix/kernels/kernel-huge-*-i586-*.txz ]; then
		get_kernel huge.s
	fi
else
	get_kernel huge.s
fi

echo "DONE!"
set +e
