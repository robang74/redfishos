#!/bin/bash
################################################################################
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released under the MIT (tlo.mit.edu) license terms
#
################################################################################

filelist=$(ls -1 scripts/*.{sh,env} scripts/*os/*.{sh,env} recovery/*.{sh,env})
filelist="$filelist $(ls -1 recovery/ramdisk/init* | grep -Ev .orig ||:)"

stat="do"

while [ "$stat" != "${curr:-1}" ]; do
	stat=$(stat -c +%Y $filelist)
	for i in {1..8}; do
		sed -i -e "s/ $//g" -e "s/\t/    /g" "$@" $filelist
	done
	curr=$(stat -c +%Y $filelist)
done
