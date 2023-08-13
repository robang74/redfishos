#!/bin/bash
################################################################################
#
# Copyright (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#                     Released under GPLv2 license terms
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
################################################################################
# release: 0.0.1

set -eu

src_file_env "sfos-ssh-connect"

# VARIABLES DEFINITIONS ########################################################

v=""
if [ "x${1:-}" = "x-v" ]; then
	v="v"; shift
fi

date_time=$(date +"%F-%H-%M-%S")
date_time=$(date +"%Y%m%d%H%M%S")
find_opts="-xdev ! -type d" # likely -print0 but tar has not --null
tar_opts="--numeric-owner -p"
excl_list="
/root /tmp /var/tmp /usr/tmp /var/cache

/usr/lib/locale /vendor /home /apex /odm /boot

/usr/share/locale /usr/share/ambience /usr/share/fonts /usr/share/translations
/usr/share/sounds /usr/share/sailfish-tutorial /usr/share/licenses
/usr/share/themes /usr/share/man

/usr/libexec/droid-hybris
"
for i in $excl_list; do find_opts="$find_opts ! -path $i/\*"; done

tarball="backup-rootfs-${date_time}.tar.gz"

# MAIN CODE EXECUTION ##########################################################

afish getip
sshcmd="ssh root@$sfos_ipaddr"

echo
echo "Creating $tarball by SSH/cat in one minute..."

time $sshcmd "find / $find_opts | tar ${v}c $tar_opts -T - | pigz -4Ric" |\
	dd bs=1M iflag=fullblock of=$tarball 2>&1 |\
		sed -ne "s,\(.* copied\),\n\\1,p"

echo
printf "Syncing archive file to local storage..."
sync $tarball
echo " OK"

echo
printf "Checking archive file for integrity..."
if tar tzf $tarball >/dev/null; then
	echo " OK"
	echo
	echo "Size in MB:" $(du -ms $tarball)
	echo
	exit 0
else
	rm -f "$tarball"
	echo " KO"
	echo
fi
exit 1

