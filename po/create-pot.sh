#!/bin/bash

xgettext --from-code=utf-8 -L shell -o salix-installer.pot \
	../initrd-scripts/usr-lib-setup/setup;
for i in INCISO \
	INSCD \
	INSNFS \
	INSSMB \
	INSURL \
	INSUSB \
	INSdir \
	INShd \
	SeTDOS \
	SeTEFI \
	SeTPKG \
	SeTconfig \
	SeTdisk \
	SeTfull \
	SeTkernel \
	SeTkeymap \
	SeTmedia \
	SeTnet \
	SeTpartitions \
	SeTswap \
	SeTusers \
	autoinstall \
	slackinstall
do
	xgettext --from-code=utf-8 -j -L shell -o salix-installer.pot \
		../initrd-scripts/usr-lib-setup/$i;
done
