#!/bin/sh
#
# This script gets a slackware initrd.img file from a slackware
# repository and converts it to a salix initrd.img file.
#
# You really shouldn't build an initrd yourself if you're
# making a custom iso. Use the initrd files found in a
# Salix iso instead.
#
# This script assumes that in a 32bit system, you're running the smp
# kernel and that you at least have the non-smp kernel-modules package
# installed.
#
# You need to be running a stock slackware kernel.

set -e

CWD=`pwd`
SCRIPTSDIR=$CWD/initrd-scripts

if [ "$UID" != "0" ]; then
	echo "You need to be root to run this"
	exit 1
fi

if [ ! -f USER ]; then
	echo "No USER file."
	exit 1
fi
user=`cat USER`

if [ ! -f VERSION ]; then
	echo "No VERSION file."
	exit 1
else
	VER=`cat VERSION`
fi

if [ -z "$arch" ]; then
	case "$( uname -m )" in
		i?86) arch=i486 ;;
		*) arch=$( uname -m ) ;;
	esac
fi

MSG="This script gets a slackware initrd.img file from a slackware\n\
repository and converts it to a salix initrd.img file.\n\
\n\
You really shouldn't build an initrd yourself if you're\n\
making a custom iso. Use the initrd files found in a\n\
Salix iso instead.\n\
\n\
When you get the initrd files from a salix iso, put them in an\n\
initrd/i486 or initrd/x86_64 directory, according to your\n\
architecture.\n\
\n\
This script assumes that in a 32bit system, you're running the smp\n\
kernel and that you at least have the non-smp kernel-modules package\n\
installed.\n\
\n\
You need to be running a stock slackware kernel.\n\
\n\
You also need to be running the architecture for which you are\n\
creating the initrd. The architecture you are running now\n\
is ${arch}.\n\
\n\
ARE YOU SURE YOU KNOW WHAT YOU'RE DOING?"

dialog --title "Are you sure you want to do this?" \
	--defaultno \
	--yesno "$MSG" 0 0
retval=$?
if [ $retval -eq 1 ] || [ $retval -eq 255 ]; then
	exit 0
fi

unset LIBDIRSUFFIX
if [[ "$arch" == "x86_64" ]]; then
	export LIBDIRSUFFIX="64"
fi

REPO=http://slackware.uk

# http://slackware.uk/slackware/slackware64-14.2/
SLACKREPO=$REPO/slackware/slackware${LIBDIRSUFFIX}-current
SLACK2REPO=$SLACKREPO/slackware${LIBDIRSUFFIX}
# http://slackware.uk/slackware/slackware64-14.2/slackware64/
SALIXREPO=$REPO/salix/$arch/14.2/
# http://slackware.uk/salix/x86_64/14.2/

mkdir -p initrd/$arch
rm -rf initrd/$arch/*initrd*.img

# get the slack initrd
# use wget instead of ftp, less error prone
echo "Getting the slackware initrd..."
wget $SLACKREPO/isolinux/initrd.img -O initrd/$arch/slack-initrd.img


# unpack slack initrd
echo "Unpacking slackware initrd..."
rm -rf /boot/initrd-tree
mkdir /boot/initrd-tree
cd /boot/initrd-tree
gzip -dc < $CWD/initrd/$arch/slack-initrd.img | cpio -i
# not needed anymore
cd $CWD
rm initrd/$arch/slack-initrd.img

# replace rc.d scripts
echo "Replacing rc.d scripts..."
rm /boot/initrd-tree/etc/rc.d/*
cp $SCRIPTSDIR/etc-rc.d/* /boot/initrd-tree/etc/rc.d/
# replace setup scripts
echo "Replacing setup scripts..."
rm /boot/initrd-tree/usr/lib/setup/*
cp $SCRIPTSDIR/usr-lib-setup/* /boot/initrd-tree/usr/lib/setup/

# download and install required packages
rm -f slack.md5 salix.md5
echo "Downloading slack CHECKSUMS.md5 file"
wget -q $SLACKREPO/CHECKSUMS.md5 -O slack.md5
echo "Downloading salix CHECKSUMS.md5 file"
wget -q $SALIXREPO/CHECKSUMS.md5 -O salix.md5

echo "Downloading spkg..."
rm -f spkg-*.t?z
LOC=`grep "\/spkg-.*-.*-.*\.tgz$" salix.md5 | sed "s|\(.*\)  \./\(.*\)|\2|"`
wget -q $SALIXREPO/$LOC
echo "Installing spkg..."
spkg -qq --root=/boot/initrd-tree/ -i spkg-*.t?z
rm spkg-*.t?z

# the slackware installer does not install the locale files for dialog
# and we need those to have the installer completely translated.
install_dialog () {
echo "Downloading dialog..."
rm -f dialog-*.t?z
LOC=`grep "dialog-.*t[gx]z$" slack.md5|sed "s|\(.*\)  \./\(.*\)|\2|"`
wget -q $SLACKREPO/$LOC
echo "Installing dialog..."
spkg -qq --root=/boot/initrd-tree/ -i dialog-*.t?z
rm -f dialog-*.t?z
}
install_dialog

# We just  need xzdec, needed by spkg. - Didier
install_xzdec () {
echo "Downloading xz..."
rm -f xz-*.t?z
LOC=`grep "xz-.*t[gx]z$" slack.md5|sed "s|\(.*\)  \./\(.*\)|\2|"`
wget -q $SLACKREPO/$LOC
echo "Installing xzdec ..."
tar xf xz-*.t?z -C /boot/initrd-tree usr/bin/xzdec
mv /boot/initrd-tree/usr/bin/xzdec /boot/initrd-tree/bin/xzdec
rm -f xz-*.t?z
}
install_xzdec

# We need gettext (but not gettext-tools) - Didier
install_gettext() {
echo "Downloading gettext..."
rm -rf gettext-*.txz
LOC=`grep "gettext-[[:digit:]].*.t[gx]z$" slack.md5 | sed "s|\(.*\)  \./\(.*\)|\2|"`
wget -q $SLACKREPO/$LOC
tar xf gettext-*t?z -C /boot/initrd-tree --wildcards \
  usr/bin/{envsubst,gettext*}
rm -f gettext-*.txz
}
install_gettext

# We need appropriate fonts for each locale - Didier
install_fonts() {
echo "Installing terminus fonts"
rm -f terminus-font-*
LOC=`grep "terminus-font.*t[gx]z$" slack.md5 | sed "s|\(.*\)  \./\(.*\)|\2|"`
wget -q $SLACKREPO/$LOC
FONT_LIST=$(grep -o "FONT[^=]*=[^;]*" $SCRIPTSDIR/etc-rc.d/rc.font | \
    sort | uniq | cut -d= -f2| sed ':a;N;s/\n/ /;ta')
for i in $FONT_LIST; do
  tar xf terminus-font-*t?z -C /boot/initrd-tree \
    usr/share/kbd/consolefonts/$i
done
rm -f terminus-font-*
}
install_fonts

# We need messages catalogs for available locales - Didier
install_messages_catalogs() {
echo "Installing messages catalogs"
for j in $(find po -name "*.po"); do
  LocaleDir=`echo $j | sed "s|po/\(.*\)\.po|\1|"`
  MO_DIR=/boot/initrd-tree/usr/share/locale/$LocaleDir/LC_MESSAGES
  mkdir -p $MO_DIR
  msgfmt --strict -c -v --statistics -o $MO_DIR/salix-installer.mo $j
  chown root:root $MO_DIR/salix-installer.mo
  chmod 644 $MO_DIR/salix-installer.mo
done
}
install_messages_catalogs

# We need definitions for all available locales. - Didier
install_locales_definitions() {
echo "Installing locale definitions"
mkdir -p /boot/initrd-tree/usr/lib$LIBDIRSUFFIX/locale
TMPDIR=$(mktemp -d)
rm -rf glibc-i18n-*.txz
LOC=`grep "glibc-i18n-.*.t[gx]z$" slack.md5 | sed "s|\(.*\)  \./\(.*\)|\2|"`
wget -q $SLACKREPO/$LOC
# We can't cherry pick the locales we need from the archive, because it
# contains hard links. - Didier
tar -xf glibc-i18n-*t?z -C $TMPDIR

# Read the available locales from the isolinux boot menu options. Use
# the 64-bit one, it shouldn't make a difference anyway. Downside is
# that if there is no menu option for a locale, there is no support for
# it during installation.
LOCALES=$( grep LANG isolinux-files/x86_64/isolinux.cfg | \
    sed "s/.* LANG=\(.*\)\.utf8/\1.utf8/" | tr '\n' ' ' )
for i in $LOCALES; do
  cp -a $TMPDIR/usr/lib$LIBDIRSUFFIX/locale/$i \
    /boot/initrd-tree/usr/lib$LIBDIRSUFFIX/locale
done
rm -rf $TMPDIR
rm -f glibc-i18n-*z
}
install_locales_definitions

# lets'install nano, a newbie friendly text editor, and its dependency
# libmagic.
install_nano() {
echo "Installing nano and its dependency libmagic"
rm -rf nano-*
LOC=`grep "/nano-.*.t[gx]z$" slack.md5 | sed "s|\(.*\)  \./\(.*\)|\2|"`
wget -q $SLACKREPO/$LOC
THENANO=$(ls nano-*)
tar -xf $THENANO -C /boot/initrd-tree usr/bin/nano
rm -f nano-*
rm -f $THENANO 
LOC=`grep "/file-.*.t[gx]z$" slack.md5 | sed "s|\(.*\)  \./\(.*\)|\2|"`
wget -q $SLACKREPO/$LOC
THEFILE=$(ls file-*)
tar -xf $THEFILE -C /boot/initrd-tree \
  usr/lib$LIBDIRSUFFIX/libmagic.so.1.0.0
rm -f $THEFILE
}
install_nano

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
# For localization, we need /boot/initrd-tree/usr/share/locale!
# rm -rf /boot/initrd-tree/usr/share/locale
rm -rf /boot/initrd-tree/usr/src
rm -rf /boot/initrd-tree/var/log/packages
# remove cyrus-sasl stuff - No mre installed - Didier
# rm -f /boot/initrd-tree/usr/sbin/{pluginviewer,saslauthd,sasldblistusers2,saslpasswd2,testsaslauthd}
# rm -f /boot/initrd-tree/etc/rc.d/rc.saslauthd
# rm -rf /boot/initrd-tree/usr/lib${LIBDIRSUFFIX}/sasl*/

echo "Repacking initrd..."
# We didn't install modules, so no need for depmod
# depmod -b /boot/initrd-tree
rm -f /boot/initrd-tree/{wait-for-root,rootfs,rootdev,initrd-name}
(
  cd /boot/initrd-tree
  find . -print | cpio -o --owner root:root -H newc \
  | gzip -9 > $CWD/initrd/$arch/initrd.img
)

# clean up
rm -f slack.md5 salix.md5
rm -rf /boot/initrd-tree

# chown everything back
chown -R ${user}:users initrd

echo "DONE!"
set +e
