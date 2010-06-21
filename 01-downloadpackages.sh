#!/bin/sh

export LANG=en_US
export ARCH=${ARCH:-i486}

slapt-get -u -c slapt-getrc.$ARCH
slapt-get --clean
{
	for i in `cat lists/KERNEL lists/CORE lists/BASIC lists/FULL lists/SETTINGS`; do 
	slapt-get -d --no-dep --reinstall -c slapt-getrc.$ARCH -i $i
	done
} 2>&1 | tee download-$ARCH.log

grep "connect to server" download-$ARCH.log
