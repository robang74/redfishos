#!/bin/bash
################################################################################
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released under the MIT (tlo.mit.edu) license terms
#
################################################################################

initscripts=$(ls -1 recovery/ramdisk/init* | grep -Ev .orig ||:)

filelist="$(ls -1 scripts/*.{sh,env} scripts/*os/*.{sh,env}) $initscripts"

stat="do"

while [ "$stat" != "${curr:-1}" ]; do
	stat=$(stat -c +%Y $filelist)
	for i in {1..8}; do
		sed -i -e "s/ $//g" -e "s/\t/    /g" "$@" $filelist
	done
	curr=$(stat -c +%Y $filelist)
done

{ return 0 || exit 0; } 2>&1 | dd of=/dev/null status=none;
###############################################################################

for i in {1..80}; do
    sed -i "s/ $//g" "$@" scripts/*.{sh,env} scripts/*os/*.{sh,env} \
        $initscripts || break
done

for i in {1..80}; do
    sed -i "s/\t/    /g" "$@" scripts/*.{sh,env} scripts/*os/*.{sh,env} \
        $initscripts || break
done
