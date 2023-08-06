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
# release: 0.0.7

set -ue -o pipefail

patch_string_to_filename() {
	test -n "${1:-}" || return 1

	# cast the patch data into useful variables
	prov=$(echo $1 | cut -d\, -f1 | tr -d ' '     ||:)
	name=$(echo $1 | cut -d\, -f2 | tr -d ' '     ||:)
	vern=$(echo $1 | cut -d\, -f3 | tr -d ' '     ||:)
	extn=$(echo $1 | cut -d\, -f4 | tr -d ' '     ||:)
	srvs=$(echo $1 | cut -d\, -f5 | grep -vw none ||:)

	patch_file="$prov-$name-$vern.patch"
	patch_path="$patch_dir/$patch_file"
	bckup_path=${patch_path%.patch}

	return 0
}

patch_db="/etc/patches.db"
patch_dir="/etc/patches.d"
patch_lst="/etc/patches.list"
patch_opts="-slEfp1 -r /dev/null --no-backup-if-mismatch -d/"

patches_to_apply=""

reload_path="$patch_dir/services-to-reload.list"

filter_1="grep . | sed -e 's,^,\ \ \ ,' | uniq ||:"
filter_2="grep . | sed -e 's,^,\ \ \|\ \ ,' ||:"

if false; then # OLD WAY TO DO #################################################

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

else # NEW WAY TO DO ###########################################################

test "x${1:-}" == "x--all" && patches_to_apply="
utilities-quick-fp-restart
set-network-postroute
zram-swap-resize-script
sshd-publickey-login-only
x10ii-iii-udev-rules-fixing
x10ii-iii-agps-config-emea
dnsmasq-connman-integration
x10ii-iii-udev-rules-fixing
"

fi #############################################################################

plst="ERROR"
if [ ! -n "$patches_to_apply" ]; then
	if [ -n "${1:-}" ]; then
		patches_to_apply="$@"
		plst="args"
	else
		patches_to_apply=$(cat $patch_lst)
		plst="file"
	fi
else
	plst="--all"
fi

if [ ! -n "$patches_to_apply" ]; then
	errexit "no patches to apply found, abort."
fi
echo
echo "=> Using the patch list from '$plst':"
echo "  \_ $plst: $patches_to_apply"

# this loop install all the patches in the ordered list ########################
n=1; mkdir -p "$patch_dir/"; rm -f "$reload_path" # preparation for the loop ###
echo; while true; do ###########################################################

if false; then
	err=1
	# retrieve the patch data from the list
	patch_strn=$(echo $patches_to_apply | cut -d\; -f$n)
	# quit the loop after the last patch
	test -n "$patch_strn" || break;

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
fi

for patch_name in $patches_to_apply; do # ======================================

err=1

echo "=> Previous patch check: $patch_name"
patch_prev_strn=$(grep ", *$patch_name *," $patch_db)
patch_prev_path=""
if patch_string_to_filename "$patch_prev_strn"; then
	echo "  \_ previous patch: found"
	echo "  |  $patch_prev_strn"
	echo "  \_ checking for reversibility... "
	if patch $patch_opts -R --dry-run -i "$patch_path"; then
		patch_prev_path=$patch_path
		reversible="OK"
	else
		reversible="KO"
	fi >/dev/null 2>&1
	echo "  \_ reversibility : $reversible"
else
	echo "  \_ previous patch: none"
fi

echo
echo "=> Download the patch #$n..."
echo "  \_ patch name: $patch_name"
patch_downloader.sh $patch_name 2>&1 | eval $filter_2
echo "  \_ patch saved in: $patch_dir"
patch_strn=$(grep ", *$patch_name *," $patch_db)
echo "  |  $patch_strn"

if ! patch_string_to_filename "$patch_strn"; then
	errexit "patch string  of '$patch_name' is void, abort."
fi
if [ "$patch_path" = "$patch_prev_path" ]; then
	echo "  \_ patch status: just applied in its version."
	echo "$patch_prev_path"
	echo "$patch_path"
	err=0; continue
elif [ "$reversible" = "OK" ]; then
	echo "  \_ patch status: new version to apply."
else
	echo "  \_ patch status: patch to apply."
fi

echo
echo "patch path: $patch_path"
echo "bckup path: $bckup_path"

# This part cannt be interrupted # ******************************************* #
set +e; stty -echoctl 2>/dev/null
trap 'true' SIGINT EXIT

echo
echo "=> Applying the patch #$n..."
reversed=""
if [ "$reversible" = "OK" ]; then
	echo "  \_ Reversing previous version patch..."
	if patch $patch_opts -R -i "$patch_prev_path"; then
		reversed="OK"
	else
		reversed="KO"
	fi
	echo "  \_ Reversing patch status: $reversed"
fi

stty +echoctl 2>/dev/null; set -e
trap -- SIGINT EXIT # ******************************************************** #

if true || [ "$reversed" = "KO" ]; then
	errexit "patch #$n failed to apply because cannot be reversed.

\t\tManual intervetion is needed, these are the working values: 

\t\tpatch path: $(dirname  "$patch_path")
\t\tpatch file: $(basename "$patch_path")
\t\tpatch prev: $(basename "${patch_prev_path:-none}")
\t\tpatch opts: $patch_opts
"
fi

continue # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

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
			echo "\_ system service not found: $srv"./patch_installer.sh
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

done # =========================================================================

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

break; done ####################################################################

reload_list=$(cat "$reload_path" 2>/dev/null)
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
