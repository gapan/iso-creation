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

rm -rf kernel/$arch
mkdir -p kernel/$arch

# get the slack kernel
echo "Getting the slackware kernel..."
if [[ "$arch" == "i486" ]]; then
	mkdir kernel/$arch/hugesmp.s
	tar --wildcards -xf iso/salix/kernels/kernel-huge-smp-*-i686-*.txz \
		boot/vmlinuz-huge-* -O > kernel/$arch/hugesmp.s/bzImage
	tar --wildcards -xf iso/salix/kernels/kernel-huge-smp-*-i686-*.txz \
		boot/System.map-huge-* -O | gzip > kernel/$arch/hugesmp.s/System.map.gz
	tar --wildcards -xf iso/salix/kernels/kernel-huge-*-i686-*.txz \
		boot/config-huge-* -O > kernel/$arch/hugesmp.s/config
	if [ -f iso/salix/kernels/kernel-huge-*-i586-*.txz ]; then
		mkdir kernel/$arch/huge.s
		tar --wildcards -xf iso/salix/kernels/kernel-huge-*-i586-*.txz \
			boot/vmlinuz-huge-* -O > kernel/$arch/huge.s/bzImage
		tar --wildcards -xf iso/salix/kernels/kernel-huge-*-i586-*.txz \
			boot/System.map-huge-* -O | gzip > kernel/$arch/huge.s/System.map.gz
		tar --wildcards -xf iso/salix/kernels/kernel-huge-*-i586-*.txz \
			boot/config-huge-* -O > kernel/$arch/huge.s/config
	fi
else
	mkdir kernel/$arch/huge.s
	tar --wildcards -xf iso/salix/kernels/kernel-huge-*-x86_64-*.txz \
		boot/vmlinuz-huge-* -O > kernel/$arch/huge.s/bzImage
	tar --wildcards -xf iso/salix/kernels/kernel-huge-*-x86_64-*.txz \
		boot/System.map-huge-* -O | gzip > kernel/$arch/huge.s/System.map.gz
	tar --wildcards -xf iso/salix/kernels/kernel-huge-*-x86_64-*.txz \
		boot/config-huge-* -O > kernel/$arch/huge.s/config
fi

echo "DONE!"
set +e
