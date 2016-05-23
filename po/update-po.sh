#!/bin/bash

# Merge translations
for i in `ls *.po`; do
	echo "Merging $i"
	msgmerge -UN $i salix-installer.pot
done

# Delete empty translations
for i in `ls *.po`; do
	msgfmt --statistics $i 2>&1 | grep "^0 translated" > /dev/null \
		&& rm $i¬
done
rm -f messages.mo

# Delete translation backups. They're in git anyway.
rm -f *.po~
