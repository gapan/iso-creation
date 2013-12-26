#!/bin/sh
#
# This scripts creates the isolinux directory for using in salix iso.


if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

set -e

answer="$(eval dialog \
	--stdout \
	--title \"Select edition\" \
	--menu \"Select the edition you want to create isolinux files for:\" \
	0 0 0 \
	'Xfce' 'o' \
	'KDE' 'o' \
	'Mate' 'o' \
	'Ratpoison' 'o' \
	'Openbox' 'o' \
	'LXDE' 'o' \
	'Core' 'o' )"
retval=$?
if [ $retval -eq 1 ] || [ $retval -eq 255 ]; then
	exit 0
else
	edition=$answer
fi

answer="$(eval dialog --title \"Select arch\" \
	--stdout \
	--menu \"Select the target architecture:\" \
	0 0 0 \
	'i486' 'o' \
	'x86_64' 'o')"
retval=$?
if [ $retval -eq 1 ] || [ $retval -eq 255 ]; then
	exit 0
else
	arch=$answer
fi

rm -rf isolinux/$arch
mkdir -p isolinux/$arch

# copy the isolinux.bin from the system (it's exactly the same for both
# architectures). For some reason slackware uses the
# isolinux-debug.bin, which prevents making a hybrid iso
cp /usr/share/syslinux/isolinux.bin isolinux/$arch

# copy the initrd (it should already be there)
cp initrd/$arch/*.img isolinux/$arch/

# copy the rest of the files
cp isolinux-files/$arch/* isolinux/$arch/

# write the edition in the messages.txt file
sed -i "s/__EDITION__/$edition/" isolinux/$arch/message.txt
echo "DONE!"

set +e
