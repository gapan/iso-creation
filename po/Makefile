
.PHONY: update-po
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

.PHONY: pot
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
		slackinstall; \
	do \
		xgettext --from-code=utf-8 -j -L shell -o salix-installer.pot \
			../initrd-scripts/usr-lib-setup/$$i; \
	done

.PHONY: stat
stat:
	@for i in `ls *.po`; do \
		echo "Statistics for $$i:"; \
		msgfmt --statistics $$i; \
		echo; \
	done
	@rm -f messages.mo

.PHONY: tx-pull
tx-pull:
	tx pull -a
	@for i in `ls *.po`; do \
		msgfmt --statistics $$i 2>&1 | grep "^0 translated" > /dev/null \
			&& rm $$i || true; \
		msgfmt --statistics $$i 2>&1 | grep "^1 translated" > /dev/null \
			&& rm $$i || true; \
	done
	@rm -f messages.mo

.PHONY: tx-pull-f
tx-pull-f:
	tx pull -a -f
	@for i in `ls *.po`; do \
		msgfmt --statistics $$i 2>&1 | grep "^0 translated" > /dev/null \
			&& rm $$i || true; \
		msgfmt --statistics $$i 2>&1 | grep "^1 translated" > /dev/null \
			&& rm $$i || true; \
	done
	@rm -f messages.mo

