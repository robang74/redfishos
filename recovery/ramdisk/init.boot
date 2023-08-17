#!/bin/sh
##############################################################################
#
# Generic ramdisk init process for booting a device. Based Marko Saukko's
# initrd for Galaxy Note GT-i9250. RAF reworked
#
# Copyright (C) 2014 Jolla Ltd.
# Copyright (C) 2012 Marko Saukko
# Copyright (C) 2023 Roberto A. Foglietta
#     Contact: roberto.foglietta@gmail.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# IRC: Sage @ #mer & #nemomobile @ Freenode
#
##############################################################################
# release: 0.0.2

exec 2>/boot.log

# Location of the device init script, if not set, few defaults are tried.
INITBIN=/sbin/preinit

# Where to mount the rootfs
ROOTMNTDIR="/rootfs"

# With MNTSCRIPT, you can use your own mounting script and bypass the default
# root mounting. The script should take $ROOTMNTDIR as parameter
# for where to mount the root.
MNTSCRIPT="/sbin/root-mount"

fail()
{
	echo "initrd: Failed" > /dev/kmsg
	echo "initrd: $1" > /dev/kmsg
	reboot2 recovery
}

if ! mount | grep -q "on /proc "; then
	mkdir -p /proc
	mount -t proc proc /proc
fi

if ! mount | grep -q "on /sys "; then
	mkdir -p /sys
	mount -t sysfs sys /sys
fi

if ! mount | grep -q "on /dev "; then
	mkdir -p /dev
	mount -t devtmpfs devtmpfs /dev
	mkdir -p /dev/pts
fi

# Some filesystem tools may need mtab to work
cat /proc/mounts > /etc/mtab

echo "initrd: Starting ramdisk.." > /dev/kmsg

mkdir -p $ROOTMNTDIR

# Mount the root filesystem
if [ -e $MNTSCRIPT ]; then
	$MNTSCRIPT $ROOTMNTDIR
	if [ $? -eq 0 ]; then
		echo "initrd: Mounting root succeeded" > /dev/kmsg
	else
		fail "Mouting root failed"
	fi
else
	fail "$MNTSCRIPT does not exist, cannot mount root!"
fi

echo "initrd: Searching for init process..." > /dev/kmsg

if [ -n $INITBIN ] || [ -e $ROOTMNTDIR/$INITBIN ]; then
	echo "initrd: Found $INITBIN" > /dev/kmsg
elif [ -e ${ROOTMNTDIR}/usr/sbin/init ]; then
	INITBIN="/usr/sbin/init"
elif [ -e ${ROOTMNTDIR}/sbin/init ]; then
	INITBIN="/sbin/init"
elif [ -e ${ROOTMNTDIR}/init ]; then
	INITBIN="/init"
else
	fail "Unable to find init process from rootfs."
fi

# umount everything before doing switch root as the init process
# is responsible of doing these inside the final boot env.
umount -l /dev
umount -l /sys
umount -l /proc
umount -l -a

# Old preinit ( < 1.0.4.* Sailfish releases) does not mount /dev so let's mount
# it here.
mkdir -p ${ROOTMNTDIR}/dev
mount -t devtmpfs devtmpfs ${ROOTMNTDIR}/dev

echo "initrd: Switching to rootfs at ${ROOTMNTDIR}, with init ${INITBIN}" > ${ROOTMNTDIR}/dev/kmsg

# #############################################################################
# Magic Close feature:
#
# If a driver supports "Magic Close", the driver will not disable the
# watchdog unless a specific magic character 'V' has been sent to
# /dev/watchdog just before closing the file.  If the userspace daemon
# closes the file without sending this special character, the driver
# will assume that the daemon (and userspace in general) died, and will
# stop pinging the watchdog without disabling it first.  This will then
# cause a reboot if the watchdog is not re-opened in sufficient time.
#
# Source: https://www.kernel.org/doc/Documentation/watchdog/watchdog-api.txt
#
# Reset watchdog timer
echo "V" > /dev/watchdog

# usage: switch_root <newrootdir> <init> <args to init>
exec switch_root ${ROOTMNTDIR} ${INITBIN}
