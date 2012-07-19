#/bin/sh

export LANG=C
export ARCH=${ARCH:-i486}

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

for pkg in `find ./iso/salix -type f -name '*.t[gx]z' -print`
do
	PKGNAME=`basename $pkg | sed "s/\(.*\)-\(.*\)-\(.*\)-\(.*\)\.t[gx]z/\1/"`
	DEPS=`/usr/sbin/slapt-get -c slapt-getrc.$ARCH --show $PKGNAME |grep "Package Required:   "|sed "s/Package Required:   //"`
	echo -n $DEPS > `echo $pkg | sed "s/\.t[gx]z/\.dep/"`
done

