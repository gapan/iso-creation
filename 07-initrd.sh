#!/bin/sh
#
# This script gets a slackware initrd.img file from a slackware
# repository and converts it to a salix initrd.img file.
#
# You will first need to install curlftpfs to use it.
# You also need to be running a stock slackware kernel.

set -e

CWD=`pwd`
SCRIPTSDIR=$CWD/initrd-scripts


if [ "$UID" != "0" ]; then
	echo "You need to be root to run this"
	exit 1
fi

if [ ! $# -eq 1 ]; then
	echo "ERROR. Syntax is: $0 VERSION"
	exit 1
fi
VER=$1

if [ ! -x /usr/bin/curlftpfs ]; then
	echo "curlftpfs is missing"
	exit 1
fi

if [ -z "$arch" ]; then
	case "$( uname -m )" in
		i?86) arch=i486 ;;
		*) arch=$( uname -m ) ;;
	esac
fi

echo "You need to run this on a system using the target architecture."
echo "Architecture detected: $arch"

unset LIBDIRSUFFIX
if [[ "$arch" == "x86_64" ]]; then
	export LIBDIRSUFFIX="64"
fi

mkdir -p initrd/$arch
rm -rf initrd/$arch/*initrd.img

# create the mountpoint for the ftpfs
mkdir ftp
FTP="$CWD/ftp"

# mount the slackware.org.uk ftp server with curlftpfs
# we're using the slackware.org.uk mirror because it includes both
# slackware and salix repos
echo "Mounting ftp repository..."
curlftpfs ftp://ftp.slackware.org.uk ftp

# get the slack initrd
echo "Getting the slackware initrd..."
cp -f $FTP/slackware/slackware${LIBDIRSUFFIX}-$VER/isolinux/initrd.img initrd/$arch/slack-initrd.img

# unpack slack initrd
echo "Unpacking slackware initrd..."
rm -rf /boot/initrd-tree
mkdir /boot/initrd-tree
cd /boot/initrd-tree
gzip -dc < $CWD/initrd/$arch/slack-initrd.img | cpio -i

# replace rc.d scripts
echo "Replacing rc.d scripts..."
rm /boot/initrd-tree/etc/rc.d/*
cp $SCRIPTSDIR/etc-rc.d/* /boot/initrd-tree/etc/rc.d/
# replace setup scripts
echo "Replacing setup scripts..."
rm /boot/initrd-tree/usr/lib/setup/*
cp $SCRIPTSDIR/usr-lib-setup/* /boot/initrd-tree/usr/lib/setup/

# install packages from ftp
echo "Installing spkg..."
spkg --root=/boot/initrd-tree/ -i $FTP/salix/$arch/$VER/salix/a/spkg-*.tgz
echo "Installing xz..."
spkg --root=/boot/initrd-tree/ -i $FTP/slackware/slackware${LIBDIRSUFFIX}-$VER/slackware${LIBDIRSUFFIX}/a/xz-*.tgz
echo "Installing showmount binary from nfsutils..."
tar xf $FTP/slackware/slackware${LIBDIRSUFFIX}-$VER/slackware${LIBDIRSUFFIX}/n/nfs-utils-*.txz -C /boot/initrd-tree usr/sbin/showmount
echo "Installing fuse..."
spkg --root=/boot/initrd-tree/ -i $FTP/slackware/slackware${LIBDIRSUFFIX}-$VER/slackware${LIBDIRSUFFIX}/l/fuse-*.txz
echo "Installing httpfs2..."
spkg --root=/boot/initrd-tree/ -i $FTP/salix/$arch/$VER/salix/n/httpfs2-*.txz
echo "Installing fuse.ko kernel modules..."
for i in `ls $FTP/slackware/slackware${LIBDIRSUFFIX}-$VER/slackware${LIBDIRSUFFIX}/a/kernel-modules-*.txz`; do
	tar xf $i -C /boot/initrd-tree --wildcards "*/fuse.ko"
done
echo "Installing cyrus-sasl..."
spkg --root=/boot/initrd-tree/ -i $FTP/slackware/slackware${LIBDIRSUFFIX}-$VER/slackware${LIBDIRSUFFIX}/n/cyrus-sasl-*.txz
echo "Installing smbclient binary from samba..."
tar xf $FTP/slackware/slackware${LIBDIRSUFFIX}-$VER/slackware${LIBDIRSUFFIX}/n/samba-*.txz -C /boot/initrd-tree --wildcards \
  usr/bin/smbclient \
  usr/lib${LIBDIRSUFFIX}/*.dat \
  usr/lib${LIBDIRSUFFIX}/charset/*
install -d /boot/initrd-tree/etc/samba
touch /boot/initrd-tree/etc/samba/smb.conf

echo "Tweaking config files..."
# network logon message
cat << EOF > /boot/initrd-tree/etc/motd.net

Welcome to Salix${LIBDIRSUFFIX} $VER

Please run '. /etc/profile' to initialise the environment.

EOF
# change the hostname
sed "s/slackware/salix${LIBDIRSUFFIX}/g" -i /boot/initrd-tree/etc/HOSTNAME
sed "/^127.0.0.1/s|slackware|salix${LIBDIRSUFFIX}|g" -i /boot/initrd-tree/etc/hosts

# remove not needed dirs
echo "Removing unnecessary stuff..."
rm -rf /boot/initrd-tree/usr/{doc,include,man,src}
rm -rf /boot/initrd-tree/usr/share/locale
rm -rf /boot/initrd-tree/var/log/packages
# remove cyrus-sasl stuff
rm -f /boot/initrd-tree/usr/sbin/{pluginviewer,saslauthd,sasldblistusers2,saslpasswd2,testsaslauthd}
rm -f /boot/initrd-tree/etc/rc.d/rc.saslauthd
rm -rf /boot/initrd-tree/usr/lib${LIBDIRSUFFIX}/sasl*/

# repack initrd
echo "Repacking initrd..."
depmod -b /boot/initrd-tree/
mkinitrd -o $CWD/initrd/$arch/initrd.img

# unmount the ftpfs and remove the mountpoint
echo "Unmounting ftp repository..."
fusermount -u $FTP
rmdir $FTP

echo "DONE!"
set +e
