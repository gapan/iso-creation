#!/bin/sh
export LANG=en_US
slapt-get -u
slapt-get --clean
{
	for i in `cat lists/KERNEL lists/CORE lists/BASIC lists/FULL lists/SETTINGS`; do 
	slapt-get -d --no-dep --reinstall -i $i
	done
} 2>&1 | tee download.log

grep "connect to server" download.log
