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

if [ ! -x /usr/bin/curlftpfs ]; then
	echo "curlftpfs is missing"
	exit 1
fi

set -e

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
	\"Enter the salix version you want to create the initrd for:\" \
	0 0 )"
retval=$?
if [ $retval -eq 1 ] || [ $retval -eq 255 ]; then
	exit 0
else
	ver=$answer
fi

CWD=`pwd`

unset LIBDIRSUFFIX
if [[ "$arch" == "x86_64" ]]; then
	export LIBDIRSUFFIX="64"
fi

rm -rf kernel/$arch
mkdir -p kernel/$arch

# create the mountpoint for the ftpfs
mkdir ftp
FTP="$CWD/ftp"

# mount the slackware.org.uk ftp server with curlftpfs
# we're using the slackware.org.uk mirror because it includes both
# slackware and salix repos
echo "Mounting ftp repository..."
curlftpfs ftp://ftp.slackware.org.uk ftp

# get the slack kernel
echo "Getting the slackware kernel..."
if [[ "$arch" == "i486" ]]; then
	cp -r $FTP/slackware/slackware${LIBDIRSUFFIX}-$ver/kernels/{hugesmp.s,huge.s} kernel/$arch/
else
	cp -r $FTP/slackware/slackware${LIBDIRSUFFIX}-$ver/kernels/huge.s kernel/$arch/
fi

# unmount the ftpfs and remove the mountpoint
echo "Unmounting ftp repository..."
fusermount -u $FTP
rmdir $FTP

echo "DONE!"
set +e
