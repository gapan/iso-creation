#/bin/sh

if [ "$UID" -eq "0" ]; then
	echo "Don't run this script as root"
	exit 1
fi

if [ ! -f ARCH ]; then
	echo "No ARCH file."
	exit 1
else
	export ARCH=`cat ARCH`
fi

rm -rf iso
rm -rf temp
mkdir -p iso/salix/{aaa,kernels,core,settings}
if [[ "$ARCH" == "x86_64" ]]; then
	mkdir -p iso/salix/efi
fi
if [ -f lists/BASIC ]; then
	if [[ "$ARCH" == "x86_64" ]]; then
		mkdir -p iso/salix/efi-gui
	fi
	mkdir -p iso/salix/basic
fi
if [ -f lists/FULL ]; then
	mkdir -p iso/salix/full
fi
mkdir -p temp

find /var/slapt-get -name "*.t[gx]z" -exec cp {} temp/ \;

for i in `cat lists/AAA`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/AAALIST
done

for i in `cat lists/KERNEL`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/KERNELLIST
done

for i in `cat lists/CORE`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/CORELIST
done

if [[ "$ARCH" == "x86_64" ]]; then
	for i in `cat lists/EFI`; do
		find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/EFILIST
	done
fi

if [ -f lists/BASIC ]; then
	for i in `cat lists/BASIC`; do
		find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/BASICLIST
	done
	if [[ "$ARCH" == "x86_64" ]]; then
		for i in `cat lists/EFI-GUI`; do
			find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/EFIGUILIST
		done
	fi
fi

if [ -f lists/FULL ]; then
	for i in `cat lists/FULL`; do
		find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/FULLLIST
	done
fi

for i in `cat lists/SETTINGS`; do
	find temp/ | grep /$i- | sed "/$i-.*-.*-.*-.*/d" >> temp/SETTINGSLIST
done

for i in `cat temp/AAALIST`; do
	mv $i iso/salix/aaa/
done

for i in `cat temp/KERNELLIST`; do
	mv $i iso/salix/kernels/
done

for i in `cat temp/CORELIST`; do
	mv $i iso/salix/core/
done

if [[ "$ARCH" == "x86_64" ]]; then
	for i in `cat temp/EFILIST`; do
		mv $i iso/salix/efi/
	done
fi

if [ -f lists/BASIC ]; then
	for i in `cat temp/BASICLIST`; do
		mv $i iso/salix/basic/
	done
	if [[ "$ARCH" == "x86_64" ]]; then
		for i in `cat temp/EFIGUILIST`; do
			mv $i iso/salix/efi-gui/
		done
	fi
fi

if [ -f lists/FULL ]; then
	for i in `cat temp/FULLLIST`; do
		mv $i iso/salix/full/
	done
fi

for i in `cat temp/SETTINGSLIST`; do
	mv $i iso/salix/settings/
done

