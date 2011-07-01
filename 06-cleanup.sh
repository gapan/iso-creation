#!/bin/sh

find ./salix -name "*.dep" -exec rm {} \;
find ./salix -name "*.txt" -exec rm {} \;
find ./salix -name "*.meta" -exec rm {} \;

unlink lists
