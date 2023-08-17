## The users and system backup suite

This shell scripts running on the laptop/PC provide backup and restore capabilities by SSH via USB.

- USAGE: [rfos-restore-backup.sh](rfos-restore-backup.sh) [ -v | -h ] [ -0|...|-4 ] [ /rootfs ]

- USAGE: [rfos-rootfs-backup.sh](rfos-rootfs-backup.sh) [ -v | -h ] tarball [ /rootfs ]

- USAGE: [rfos-user-backup.sh](rfos-user-backup.sh) [ [ -v ] /home/defaultuser | -h ]

Thanks to this suite, it starts to become feasible to play with the root filesystem because it can be restored via a previous backup in a minute.

However, in some cases a simple rollback of a previous tarball backup cannot solve the issue (e.g.: into a `service.d` folder a `faulty.conf`, which is new and therefore will not be overwritten nor deleted). This limitation highlights the need for a recovery image that can provide an integral root filesystem restore from a full previous backup archive.


## The SSH connetivity funtions

This script contains a variety of functions that aim to automatise as many cases as possible about SSH connectivity with the smartphone 

- [sfos-ssh-connect.env](sfos-ssh-connect.env)

The suite has been recently updated to support a smoothless interaction with the [new recovery image](../../recovery/ramdisk) which allows to flash the partitions via SSH or do backup and restore of the rootfs filesystem and home users folders.


## The USB fastboot issues fixer

Well, the title is a little brave because this script does not solve all the problem that `fastboot` shows with the new USB hardware

- USAGE: [fastboot-usb3fix.sh](fastboot-usb3fix.sh) <2|3>

However, it contains interesting ways of doing things that will be nice to see in a little more elaborate approch: detach, fastboot, re-attach.

