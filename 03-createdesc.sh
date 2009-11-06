#!/bin/sh
#
# .desc files are needed for the installer to display a description of
# the package when it is being installed. If no .desc file is present
# the package will get installed, but no description will be shown

for PKG in `find ./salix/ -name *.t[gx]z`;do
	PKGNAME=`echo $PKG | sed "s/.*\/\(.*\)-\(.*\)-\(.*\)-\(.*\)/\1/"`
	DESC=`echo $PKG | sed "s/\(.*\)\.t[gx]z/\1.desc/"`
	if [ ! -f $DESC ]; then
		echo "Creating $DESC"
		tar xfO $PKG install/slack-desc | grep "$PKGNAME:" | sed "s/$PKGNAME://" > $DESC
	fi
done
