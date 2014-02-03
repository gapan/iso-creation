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

rm -rf iso/{isolinux,kernels,README,EFI}

mkdir -p iso/isolinux
mkdir -p iso/kernels

cp -r isolinux/$arch/* iso/isolinux/
cp -r kernel/$arch/* iso/kernels/
cp README.iso iso/README

if [ $arch == "x86_64" ]; then
	cp -r EFI iso/
fi

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
		rm -rf iso/kernels/huge.s
	fi
fi
