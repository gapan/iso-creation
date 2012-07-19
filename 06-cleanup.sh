#!/bin/sh

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

find ./iso/salix -name "*.dep" -exec rm {} \;
find ./iso/salix -name "*.txt" -exec rm {} \;
find ./iso/salix -name "*.meta" -exec rm {} \;

unlink lists
