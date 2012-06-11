#!/bin/sh
#
# This scripts creates the isolinux directory for using in salix iso.

set -e

if [ ! $# -eq 2 ]; then
	echo "ERROR. Syntax is: $0 ARCH EDITION"
	exit 1
fi
arch=$1
edition=$2

unset LIBDIRSUFFIX
if [[ "$arch" == "x86_64" ]]; then
	export LIBDIRSUFFIX="64"
fi

rm -rf isolinux/$arch
mkdir -p isolinux/$arch

# copy the isolinux.bin from the system (it's exactly the same for both
# archictectures). For some reason slackware uses the
# isolinux-debug.bin, which prevents making a hybrid iso
cp /usr/share/syslinux/isolinux.bin isolinux/$arch

# copy the initrd (it should already be there)
cp initrd/$arch/initrd.img isolinux/$arch/

# copy the rest of the files
cp isolinux-files/$arch/* isolinux/$arch/

# write the edition in the messages.txt file
sed -i "s/__EDITION__/$edition/" isolinux/$arch/messages.txt
echo "DONE!"

set +e
