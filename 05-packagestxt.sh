#!/bin/sh

export LANG=C

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

function gen_packages_txt {
	echo '' > iso/PACKAGES.TXT
	find ./iso/salix -type f -name '*.meta' -exec cat {} \; >> iso/PACKAGES.TXT
	cat iso/PACKAGES.TXT | gzip -9 -c - > iso/PACKAGES.TXT.gz
	rm iso/PACKAGES.TXT
}

function gen_meta {
	unset REQUIRED CONFLICTS SUGGESTS
	if [ ! -f $1 ]; then
		echo "File not found: $1"
		exit 1;
	fi
		if [ "`echo $1|grep -E '(.*{1,})\-(.*[\.\-].*[\.\-].*).t[glx]z[ ]{0,}$'`" == "" ]; then
			return;
		fi
	NAME=$(echo $1|sed -re "s/(.*\/)(.*.t[glx]z)$/\2/")
	PKGNAME=`echo $NAME | sed "s/\(.*\)-\(.*\)-\(.*\)-\(.*\)\.t[glx]z/\1/"`
	LOCATION=$(echo $1|sed -re "s/(.*)\/(.*.t[glx]z)$/\1/")
	if [[ `echo $1 | grep "tgz$"` ]]; then
		SIZE=$( expr `gunzip -l $1 |tail -1|awk '{print $1}'` / 1024 )
		USIZE=$( expr `gunzip -l $1 |tail -1|awk '{print $2}'` / 1024 )
	elif [[ `echo $1 | grep "t[lx]z$"` ]]; then
		SIZE=$( expr `ls -l $1 | awk '{print $5}'` / 1024 )
		#USIZE is only an appoximation, nothing similar to gunzip -l for lzma yet
		USIZE=$[$SIZE * 4 ]
	fi
	
	METAFILE=${NAME%t[glx]z}meta
	
	if test -f $LOCATION/${NAME%t[glx]z}dep
	then
		REQUIRED="`cat $LOCATION/${NAME%t[glx]z}dep`"
	fi
	echo "PACKAGE NAME:  $NAME" > $LOCATION/$METAFILE
	if [ -n "$DL_URL" ]; then
		echo "PACKAGE MIRROR:  $DL_URL" >> $LOCATION/$METAFILE
	fi
	echo "PACKAGE LOCATION:  $LOCATION" >> $LOCATION/$METAFILE
	echo "PACKAGE SIZE (compressed):  $SIZE K" >> $LOCATION/$METAFILE
	echo "PACKAGE SIZE (uncompressed):  $USIZE K" >> $LOCATION/$METAFILE
	echo "PACKAGE REQUIRED:  $REQUIRED" >> $LOCATION/$METAFILE
	echo "PACKAGE DESCRIPTION:" >> $LOCATION/$METAFILE
	if test -f $LOCATION/${NAME%t[glx]z}txt
	then
		cat $LOCATION/${NAME%t[glx]z}txt |grep -E '[^[:space:]]*\:'|grep -v '^#' >> $LOCATION/$METAFILE
		sed "s/^$PKGNAME://" $LOCATION/${NAME%t[glx]z}txt > $LOCATION/${NAME%t[glx]z}desc 
	else
		if [[ `echo $1 | grep "tgz$"` ]]; then
			tar xfO $1 install/slack-desc |grep -E '[^[:space:]]*\:'|grep -v '^#' > $LOCATION/${NAME%t[glx]z}txt
			cat $LOCATION/${NAME%t[glx]z}txt |grep -E '[^[:space:]]*\:'|grep -v '^#' >> $LOCATION/$METAFILE
			sed "s/^$PKGNAME://" $LOCATION/${NAME%t[glx]z}txt > $LOCATION/${NAME%t[glx]z}desc 
		elif [[ `echo $1 | grep "t[x]z$"` ]]; then
			xz -c -d $1 | tar xO install/slack-desc |grep -E '[^[:space:]]*\:'|grep -v '^#' > $LOCATION/${NAME%t[glx]z}txt
			cat $LOCATION/${NAME%t[glx]z}txt |grep -E '[^[:space:]]*\:'|grep -v '^#' >> $LOCATION/$METAFILE
			sed "s/^$PKGNAME://" $LOCATION/${NAME%t[glx]z}txt > $LOCATION/${NAME%t[glx]z}desc 
		elif [[ `echo $1 | grep "t[l]z$"` ]]; then
			lzma -c -d $1 | tar xO install/slack-desc |grep -E '[^[:space:]]*\:'|grep -v '^#' > $LOCATION/${NAME%t[glx]z}txt
			cat $LOCATION/${NAME%t[glx]z}txt |grep -E '[^[:space:]]*\:'|grep -v '^#' >> $LOCATION/$METAFILE
			sed "s/^$PKGNAME://" $LOCATION/${NAME%t[glx]z}txt > $LOCATION/${NAME%t[glx]z}desc 
		fi
	fi
	echo "" >> $LOCATION/$METAFILE
}

for pkg in `find ./iso/salix -type f -name '*.t[glx]z' -print`
do
	gen_meta $pkg
done
gen_packages_txt
