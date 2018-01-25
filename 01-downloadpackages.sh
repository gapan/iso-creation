#!/bin/bash

export LANG=en_US

if [ "$UID" != "0" ]; then
	echo "You need to be root to run this"
	exit 1
fi

if [ -x /usr/bin/salix-update-notifier ]; then
	echo "ERROR: salix-update-notifier should not be installed"
	exit 1
fi

if [ ! -f USER ]; then
	echo "No USER file."
	exit 1
fi
user=`cat USER`

unlink lists
rm -f EDITION ARCH VERSION

answer="$(eval dialog \
	--title \"Enter Salix version\" \
	--stdout \
	--inputbox \
	\"Enter the salix version you want to create the iso for:\" \
	0 0 )"
retval=$?
if [ $retval -eq 1 ] || [ $retval -eq 255 ]; then
	exit 0
else
	echo "$answer" > VERSION
	VER=$answer
fi

answer="$(eval dialog \
	--stdout \
	--title \"Select edition\" \
	--menu \"Select the edition you want to download packages for:\" \
	0 0 0 \
	'Xfce' 'o' \
	'KDE' 'o' \
	'MATE' 'o' \
	'Ratpoison' 'o' \
	'Openbox' 'o' \
	'Fluxbox' 'o' \
	'LXDE' 'o' \
	'Core' 'o' )"
retval=$?
if [ $retval -eq 1 ] || [ $retval -eq 255 ]; then
	exit 0
else
	echo "$answer" > EDITION
	edition=`echo $answer | tr '[:upper:]' '[:lower:]'`
fi
ln -sf lists-$edition lists

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
	echo "$answer" > ARCH
	arch=$answer
fi

slapt-get -u -c slapt-getrc.$arch
slapt-get --clean
{
	AAAPKG=`cat lists/AAA`
	KERNELPKG=`cat lists/KERNEL`
	if [ $arch == "x86_64" ]; then
		COREPKG=`cat lists/CORE lists/EFI`
	else
		COREPKG=`cat lists/CORE`
	fi
	if [ -f lists/BASIC ]; then
		BASICPKG=`cat lists/BASIC`
	else
		BASICPKG=""
	fi
	if [ -f lists/FULL ]; then
		FULLPKG=`cat lists/FULL`
	else
		FULLPKG=""
	fi
	if [[ "$arch" == "x86_64" ]]; then
		if [ -f lists/EFI ]; then
			EFIPKG=`cat lists/EFI`
		fi
		if [ -f lists/EFI-GUI ]; then
			EFIGUIPKG=`cat lists/EFI-GUI`
		fi
	fi
	SETTINGSPKG=`cat lists/SETTINGS`
	for i in $AAAPKG $KERNELPKG $COREPKG $BASICPKG $FULLPKG $EFIPKG \
		$EFIGUIPKG $SETTINGSPKG; do
		slapt-get -d --no-dep --reinstall -c slapt-getrc.$arch -i $i
	done
} 2>&1 | tee download-$arch.log

# chown everything back
chown -R ${user}:users ./*

grep "connect to server" download-$arch.log
grep "No such" download-$arch.log
grep "Write failed" download-$arch.log
grep "Failed" download-$arch.log
