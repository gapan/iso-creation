#!/bin/sh
#
# This script gets slackware kernel files from a slackware
# repository 
#
# You will first need to install curlftpfs to use it.


if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

set -e

if [ ! -f ARCH ]; then
	echo "No ARCH file."
	exit 1
else
	arch=`cat ARCH`
fi

if [ ! -f VERSION ]; then
	echo "No VERSION file."
	exit 1
else
	ver=`cat VERSION`
fi

# FIXME!
#
# This is temporary. When slackware releases 14.2, uncomment the first
# line and remove ver=current.
#ver=`cat VERSION`
ver=current

unset LIBDIRSUFFIX
if [[ "$arch" == "x86_64" ]]; then
	export LIBDIRSUFFIX="64"
fi

rm -rf kernel/$arch
mkdir -p kernel/$arch

# get the slack kernel
echo "Getting the slackware kernel..."
if [[ "$arch" == "i486" ]]; then
	(
		cd kernel/$arch
		wget -np -nH --cut-dirs=3 -r \
			ftp://ftp.slackware.uk/slackware/slackware${LIBDIRSUFFIX}-$ver/kernels/huge.s
		wget -np -nH --cut-dirs=3 -r \
			ftp://ftp.slackware.uk/slackware/slackware${LIBDIRSUFFIX}-$ver/kernels/hugesmp.s
	)
else
	(
		cd kernel/$arch
		wget -np -nH --cut-dirs=3 -r \
			ftp://ftp.slackware.uk/slackware/slackware${LIBDIRSUFFIX}-$ver/kernels/huge.s
	)
fi

echo "DONE!"
set +e
