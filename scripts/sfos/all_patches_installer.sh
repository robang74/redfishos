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
# release: 0.0.6

set -ue -o pipefail

export patch_db="/etc/patches.db"
export patch_dir="/etc/patches.d"
export patch_url="https://coderus.openrepos.net/media/documents"
export patch_opts="-slEfp1 -r /dev/null --no-backup-if-mismatch -d/"
export patch_link=""

export reload_path="$patch_dir/services-to-reload.list"

export patches_to_apply=""
test "x${1:-}" == "x--all" && patches_to_apply="
robang74, utilities-quick-fp-restart , 0.0.3, tar.gz, none;
robang74, set-network-postroute      , 0.0.2, tar.gz, none;
robang74, zram-swap-resize-script    , 0.0.9, tar.gz, none;
robang74, sshd-publickey-login-only  , 0.0.3, tar.gz, none;
robang74, x10ii-iii-udev-rules-fixing, 0.0.1, tar.gz, none;
robang74, x10ii-iii-agps-config-emea , 0.2.2, tar.gz, ofono;
robang74, dnsmasq-connman-integration, 0.1.1, tar.gz, dnsmasq connman;
robang74, x10ii-iii-udev-rules-fixing, 0.0.2, tar.gz, systemd-udevd;
"
# prov  , name                       , vern , extn  , srvs

if [ ! -n "$patches_to_apply" ]; then
	if [ -n "${1:-}" ]; then
		patch_downloader.sh "$@" || exit 1
		patches_to_apply=$(grep ", *$1 *," $patch_db)
	else
		patches_to_apply=$(cat $patch_db)
	fi
fi

if [ ! -n "$patches_to_apply" ]; then
	echo ERROR; exit 1
fi

# preparation for the loop that will install the patches
n=1; mkdir -p "$patch_dir/"; rm -f "$reload_path"

# this loop install all the patches in the ordered list
echo; while true; do ###########################################################

err=1
# retrieve the patch data from the list
patch_strn=$(echo $patches_to_apply | cut -d\; -f$n)
# quit the loop after the last patch
test -n "$patch_strn" || break;

echo "=> Installing the patch #$n..."

# cast the patch data into useful variables
prov=$(echo $patch_strn | cut -d\, -f1 | tr -d ' '     ||:)
name=$(echo $patch_strn | cut -d\, -f2 | tr -d ' '     ||:)
vern=$(echo $patch_strn | cut -d\, -f3 | tr -d ' '     ||:)
extn=$(echo $patch_strn | cut -d\, -f4 | tr -d ' '     ||:)
srvs=$(echo $patch_strn | cut -d\, -f5 | grep -vw none ||:)

patch_link="$patch_url/$prov-$name-$vern.$extn"
link=$(eval echo $patch_link)

patch_name="$prov-$name-$vern.patch"
patch_path="$patch_dir/$patch_name"

echo "\_ patch name: $patch_name"
while true; do # ===============================================================

# download the patch and save it into the patches folder
curl -sL $link | tar xz -O > "$patch_path" || break
echo "\_ patch saved in: $patch_dir"

# save with the patch, the services that need to be restarted
servs_path=$(echo "$patch_path" | sed s/.patch$/.servs/)
echo $srvs > "$servs_path"

brk=0
for srv in $srvs; do
	out=$(systemctl --no-pager status $srv 2>&1)
	ret=$?
	if [ $ret -eq 4 ]; then
# srv_file=$(echo $out | sed -ne "s/Unit \([^ ]*\)\.service .*/\\1/p")
		echo "\_ missing system service: $srv"
		echo "   searching, wait..."
		out=$(pkcon install -yp --allow-reinstall $srv 2>&1)
		if [ $? -eq 0 ]; then
			echo "\_ system service installed: $srv"
		else
			echo "\_ system service not found: $srv"
			echo "$out" | sed -e "s/^/   /"
			brk=1
			break 2
		fi
	fi
done ||:
test $brk -ne 0 && break #RAF: not indispensable, break 2 should work

echo "\_ checking for an old patch"
# test if the patch has been applied before and revert
if patch $patch_opts -R --dry-run < "$patch_path"; then
	echo "\_ reverting old patch from rootfs"
	# forcely revert the patch that applied only partially
	if patch -R $patch_opts < "$patch_path"; then
		echo "\_ old patch reverted"
	fi
fi

echo "\_ checking for apply patch"
# test if the patch can be applied as expected to be
patch $patch_opts --dry-run < "$patch_path" || break

# apply the patch may fail despite the dry run test
if patch $patch_opts < "$patch_path"; then
	echo "\_ patch applied to rootfs"
	echo $srvs >> "$reload_path"
	err=0
else
	# forcely revert the patch that applied only partially
	patch -R $patch_opts < "$patch_path" ||:
fi

break; done # ==================================================================

if [ $err -ne 0 ]; then
	echo
	echo "WARNING: patch #$n failed to be applied to rootfs, skipped"
	echo "         fix pre-requisites and then try to install again."
else
	: # RAF, TODO: update the patches database (lock is required)
fi

# move to the next patch
n=$((n+1))
echo

done ###########################################################################

reload_list=$(grep . "$reload_path")
if [ -n "$reload_list" ]; then
	echo "=> Restarting system services"
	echo "\_ to restart: "$reload_list
	echo
	echo "WARNING: WiFi tethering will not automatically raise up again"
	echo "         You may be going to be disconnected, grab your phone"
	echo
	systemctl --no-pager daemon-reload
	for i in $reload_list; do
		systemctl --no-pager reload $i ||:
	done
	systemctl --no-pager restart $reload_list
	echo
	echo "=> Check the restarted system services"
	echo "\_ to check: "$reload_list
	echo
	for srv in $reload_list; do
		systemctl --no-pager status $reload_list 2>&1 |\
			tr '\n' '^' | cut -d'^' -f1,3 | tr '^' '\n'
		echo
	done
	echo
fi
