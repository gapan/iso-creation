#/bin/sh

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

rm -f iso/CHECKSUMS.md5 iso/PACKAGELIST iso/PACKAGELIST-TEMP

for pkg in `find ./iso/salix -type f -name '*.t[gx]z' -print`
do
	if [ ! -f ${pkg%t[gx]z}md5 ]; then
		md5sum ${pkg} | sed "s|  \.\(.*\)/\(.*\)|  \2|" > ${pkg%t[gx]z}md5
	fi
	cat ${pkg%t[glx]z}md5 | \
	sed "s|`basename ${pkg}`|${pkg}|" | \
	sed "s|/packages/|/salix/|" | \
	sed "s|/iso/|/|" >> iso/CHECKSUMS.md5
	echo "`basename ${pkg}`" >> iso/PACKAGELIST-TEMP
done

sort iso/PACKAGELIST-TEMP > iso/PACKAGELIST
rm iso/PACKAGELIST-TEMP
