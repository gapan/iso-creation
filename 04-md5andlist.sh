#/bin/sh

rm -f CHECKSUMS.md5 PACKAGELIST PACKAGELIST-TEMP

for pkg in `find ./salix -type f -name '*.t[gx]z' -print`
do
	if [ ! -f ${pkg%t[gx]z}md5 ]; then
		md5sum ${pkg} | sed "s|  \.\(.*\)/\(.*\)|  \2|" > ${pkg%t[gx]z}md5
	fi
	cat ${pkg%t[glx]z}md5 | \
	sed "s|`basename ${pkg}`|${pkg}|" | \
	sed "s|/packages/|/salix/|">> CHECKSUMS.md5
	echo "`basename ${pkg}`" >> PACKAGELIST-TEMP
done

sort PACKAGELIST-TEMP > PACKAGELIST
rm PACKAGELIST-TEMP
