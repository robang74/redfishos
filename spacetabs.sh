#!/bin/bash

initscripts=$(ls -1 recovery/ramdisk/init* | grep -Ev .orig ||:)

for i in {1..80}; do
    sed -i "s/ $//g" "$@" scripts/*.{sh,env} scripts/*os/*.{sh,env} \
        $initscripts || break
done

for i in {1..80}; do
    sed -i "s/\t/    /g" "$@" scripts/*.{sh,env} scripts/*os/*.{sh,env} \
        $initscripts || break
done
