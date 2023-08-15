#!/bin/bash

for i in {1..80}; do
    sed -i "s/ $//g" "$@" scripts/*.{sh,env} scripts/*os/*.{sh,env} || break
done

for i in {1..80}; do
    sed -i "s/\t/    /g" "$@" scripts/*.{sh,env} scripts/*os/*.{sh,env} || break
done
