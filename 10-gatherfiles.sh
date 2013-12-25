#!/bin/sh

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
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

smp=0
if [ $arch == "i486" ]; then
	answer="$(eval dialog --title \"Include i486 non-SMP kernel?\" \
	--stdout \
	--menu \"Do you want to include the i486 non-SMP kernel?\" \
	0 0 0 \
	'NO' 'o' \
	'Yes' 'o' )"
	retval=$?
	if [ $retval -eq 1 ] || [ $retval -eq 255 ]; then
		exit 0
	else
		if [ "$answer" == "Yes" ]; then
			smp=1
		fi
	fi
fi

mkdir -p iso/isolinux
mkdir -p iso/kernels

cp -r isolinux/$arch/* iso/isolinux/
cp -r kernel/$arch/* iso/kernels/
cp README iso/

# remove the non-smp initrd and kernel files if building an smp-only iso
if [ $arch == "i486" ]; then
	if [ $smp -eq 0 ]; then
		sed -i "/huge\.s/d" iso/isolinux/isolinux.cfg
		sed -i "/f2\.txt/d" iso/isolinux/isolinux.cfg
		sed -i "/huge\.s/d" iso/isolinux/message.txt
		sed -i "/Pentium-Pro/d" iso/isolinux/message.txt
		sed -i "s/Welcome/\n\nWelcome/" iso/isolinux/message.txt
		echo "" >> iso/isolinux/message.txt
		rm iso/isolinux/nosmp.img
		rm iso/isolinux/f2.txt
		rm -r iso/kernels/huge.s
	fi
fi
