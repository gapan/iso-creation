#!/bin/bash

export LANG=en_US

if [ "$UID" != "0" ]; then
	echo "You need to be root to run this"
	exit 1
fi

if [ ! $# -eq 2 ]; then
	echo "ERROR. Syntax is: $0 EDITION ARCH"
	exit 1
fi

edition=$1
arch=$2

if [ $edition = "xfce" ] || [ $edition = "ratpoison" ] || [ $edition = "lxde" ] || [ $edition = "kde" ] || [ $edition = "fluxbox" ];then
	ln -sf lists-$edition lists
else
	echo "ERROT. Not a valid EDITION"
	exit 1
fi

if [ ! $arch = "i486" ] && [ ! $arch = "x86_64" ];then
	echo "ERROR. Not a valid ARCH"
	exit 1
fi

slapt-get -u -c slapt-getrc.$arch
slapt-get --clean
{
	for i in `cat lists/KERNEL lists/CORE lists/BASIC lists/FULL lists/SETTINGS`; do 
	slapt-get -d --no-dep --reinstall -c slapt-getrc.$arch -i $i
	done
} 2>&1 | tee download-$arch.log

grep "connect to server" download-$arch.log
grep "No such" download-$arch.log
