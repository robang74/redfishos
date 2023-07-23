#!/bin/bash
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released and re-licensed under the GPLv2 license terms.
#
################################################################################

set -muex -o pipefail

workdir=${1:-.}
if [ ! -d "$workdir" ]; then
	echo
	echo "ERROR: destination folder does not exist, abort."
	echo
	exit 1
fi
if [ "$workdir" != "." ]; then
	cp -arf $0 "$workdir/"
fi
cd $workdir

if [ -x usr/bin/busybox-static -a -L bin/busybox-static ]; then
	if [ ! -e bin/busybox ]; then
		ln -sf busybox-static bin/busybox
	fi
fi
for i in $(bin/busybox --list-full); do
    ln -sf /bin/busybox $workdir/$i 
done

shell=""
for sh in bin/bash bin/ash bin/hush bin/sh; do
	if [ -x $(readlink -f $sh) ]; then
		shell=/$sh
		break
	fi 
done 

if [ "$shell" = "" ]; then
	echo                  
        echo "ERROR: destination shell does not exist, abort."
        echo                                                   
        exit 1
fi

mkdir -p dev/pts proc var/log run tmp dev/shm config sys

mount -t devtmpfs devtmpfs dev
mount -t devpts   devpts   dev/pts
mount -t tmpfs    tmpfs    dev/shm
mount -t proc     proc     proc
mount -t tmpfs    tmpfs    run
mount -t tmpfs    tmpfs    tmp
mount -t sysfs    sysfs    sys
mount -t configfs configfs config

for i in /etc/passwd /etc/group; do
	test -f $workdir/$i && continue
	cp -arf $i $workdir/$(dirname $i)
done

USER=root chroot . $shell

for mnt in dev/pts dev/shm dev tmp config run sys proc; do
	umount -R $mnt
done
