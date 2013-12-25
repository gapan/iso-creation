#!/bin/bash

export LANG=en_US

if [ "$UID" != "0" ]; then
	echo "You need to be root to run this"
	exit 1
fi

if [ ! $# -eq 2 ]; then
	echo "ERROR. Syntax is: $0 EDITION ARCH [both_smp_nosmp]"
	exit 1
fi

if [ -x /usr/bin/salix-update-notifier ]; then
	echo "ERROR: salix-update-notifier should not be installed"
	exit 1
fi

edition=$1
arch=$2
smp=$3

unlink lists

answer="$( eval dialog --title "Select edition" \
	--menu \
	"Select the edition you want to download packages for:" \
	0 0 0 \
	"xfce" "o" \
	"kde" "o" \
	"mate" "o" \
	"ratpoison" "o" \
	"openbox" "o" \
	"lxde" "o" )"
retval=$?
if [ $retval -eq 1 ]; then
	exit 0
else
	edition=$answer
fi
ln -sf lists-$edition lists

answer="$( eval dialog --title "Select arch" \
	--menu \
	"Select the target architecture:" \
	0 0 0
	"i486" "o" \
	"x86_64" "o")"
retval=$?
if [ $retval -eq 1 ]; then
	exit 0
else
	arch=$answer
fi

smp=0
if [ $arch == "i486" ]; then
	answer="$( eval dialog --title "Include i486 non-SMP kernel?" \
	--menu \
	"Do you want to include the i486 non-SMP kernel?"
	0 0 0
	"NO" "o" \
	"Yes" "o" )"
retval=$?
if [ $retval -eq 1 ]; then
	exit 0
else
	if [ "$answer" == "Yes" ];then
		smp=1
	fi
fi

slapt-get -u -c slapt-getrc.$arch
slapt-get --clean
{
	if [ $arch == "i486" ] && [ $smp -eq 1 ]; then
		KERNELPKG=`cat lists/KERNEL | grep smp`
	else
		KERNELPKG=`cat lists/KERNEL`
	fi
	for i in $KERNELPKG `cat lists/CORE lists/BASIC lists/FULL lists/SETTINGS`; do 
	slapt-get -d --no-dep --reinstall -c slapt-getrc.$arch -i $i
	done
} 2>&1 | tee download-$arch.log

grep "connect to server" download-$arch.log
grep "No such" download-$arch.log
