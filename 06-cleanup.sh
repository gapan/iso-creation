#!/bin/sh

find ./iso/salix -name "*.dep" -exec rm {} \;
find ./iso/salix -name "*.txt" -exec rm {} \;
find ./iso/salix -name "*.meta" -exec rm {} \;

unlink lists
