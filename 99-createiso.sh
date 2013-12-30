#!/bin/bash

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

CWD=`pwd`

answer="$(eval dialog \
	--stdout \
	--title \"Select edition\" \
	--menu \"Select the edition you want to create the iso for:\" \
	0 0 0 \
	'xfce' 'o' \
	'kde' 'o' \
	'mate' 'o' \
	'ratpoison' 'o' \
	'openbox' 'o' \
	'lxde' 'o' )"
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

answer="$(eval dialog \
	--title \"Enter Salix version\" \
	--stdout \
	--inputbox \
	\"Enter the salix version you want to create the iso for.\n\You can add suffixes like alpha1, beta1, RC1 etc here.:\" \
	0 0 )"
retval=$?
if [ $retval -eq 1 ] || [ $retval -eq 255 ]; then
	exit 0
else
	ver=$answer
fi

unset LIBDIRSUFFIX
if [[ "$arch" == "x86_64" ]]; then
	export LIBDIRSUFFIX="64"
fi

cd iso

mkisofs -o ../salix${LIBDIRSUFFIX}-${edition}-${ver}.iso \
  -R -J -A "Salix${LIBDIRSUFFIX} Install" \
  -hide-rr-moved \
  -v -d -N \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -sort isolinux/iso.sort \
  -b isolinux/isolinux.bin \
  -c isolinux/isolinux.boot \
  -V "Salix${LIBDIRSUFFIX} $edition $ver" .

cd ..
isohybrid ../salix${LIBDIRSUFFIX}-${edition}-${ver}.iso

