#!/bin/sh
#
# This script just stores the current user in a file, so it can be
# used by other scripts that run as root to chown to the correct
# unprivileged user.

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

rm -f USER
echo $USER > USER

