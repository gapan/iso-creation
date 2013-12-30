#/bin/sh

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

rm -rf iso
rm -rf temp
mkdir -p iso/salix/{kernels,core,settings}
if [ -f lists/BASIC ]; then
	mkdir -p iso/salix/basic
fi
if [ -f lists/FULL ]; then
	mkdir -p iso/salix/full
fi
mkdir -p temp

find /var/slapt-get -name *.t[gx]z -exec cp {} temp/ \;

for i in `cat lists/KERNEL`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/KERNELLIST
done

for i in `cat lists/CORE lists/EFI`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/CORELIST
done

if [ -f lists/BASIC ]; then
	for i in `cat lists/BASIC`; do
		find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/BASICLIST
	done
fi

if [ -f lists/FULL ]; then
	for i in `cat lists/FULL`; do
		find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/FULLLIST
	done
fi

for i in `cat lists/SETTINGS`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/SETTINGSLIST
done

for i in `cat temp/KERNELLIST`; do
	mv $i iso/salix/kernels/
done

for i in `cat temp/CORELIST`; do
	mv $i iso/salix/core/
done

if [ -f lists/BASIC ]; then
	for i in `cat temp/BASICLIST`; do
		mv $i iso/salix/basic/
	done
fi

if [ -f lists/FULL ]; then
	for i in `cat temp/FULLLIST`; do
		mv $i iso/salix/full/
	done
fi

for i in `cat temp/SETTINGSLIST`; do
	mv $i iso/salix/settings/
done

