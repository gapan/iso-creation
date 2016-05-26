
update-po:
	for i in `ls *.po`; do \
		echo "Merging $$i"; \
		msgmerge -UN $$i salix-installer.pot; \
	done
	for i in `ls *.po`; do \
		msgfmt --statistics $$i 2>&1 | grep "^0 translated" > /dev/null \
			&& rm $$i || true; \
	done
	rm -f messages.mo
	rm -f *.po~

pot:
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
		SeTconfig \
		SeTdisk \
		SeTfull \
		SeTkeymap \
		SeTmedia \
		SeTnet \
		SeTpartitions \
		SeTswap \
		SeTusers \
		autoinstall \
		slackinstall; \
	do \
		xgettext --from-code=utf-8 -j -L shell -o salix-installer.pot \
			../initrd-scripts/usr-lib-setup/$$i; \
	done

stat:
	@for i in `ls *.po`; do \
		echo "Statistics for $$i:"; \
		msgfmt --statistics $$i; \
		echo; \
	done
	@rm -f messages.mo
