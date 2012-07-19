#/bin/sh

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

rm -rf iso
rm -rf temp
mkdir -p iso/salix/{kernels,core,basic,full,settings}
mkdir -p temp

find /var/slapt-get -name *.t[gx]z -exec cp {} temp/ \;

for i in `cat lists/KERNEL`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/KERNELLIST
done

for i in `cat lists/CORE`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/CORELIST
done

for i in `cat lists/BASIC`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/BASICLIST
done

for i in `cat lists/FULL`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/FULLLIST
done

for i in `cat lists/SETTINGS`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/SETTINGSLIST
done

for i in `cat temp/KERNELLIST`; do
	mv $i iso/salix/kernels/
done

for i in `cat temp/CORELIST`; do
	mv $i iso/salix/core/
done

for i in `cat temp/BASICLIST`; do
	mv $i iso/salix/basic/
done

for i in `cat temp/FULLLIST`; do
	mv $i iso/salix/full/
done

for i in `cat temp/SETTINGSLIST`; do
	mv $i iso/salix/settings/
done

