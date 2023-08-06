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
#
# TODO: create a back-up of the files before patching, date-time-Nprogressive
#
# release: 0.0.8

set -ue -o pipefail

patch_string_to_filename() {
	test -n "${1:-}" || return 1

	# cast the patch data into useful variables
	prov=$(echo $1 | cut -d\, -f1 | tr -d ' '     ||:)
	name=$(echo $1 | cut -d\, -f2 | tr -d ' '     ||:)
	vern=$(echo $1 | cut -d\, -f3 | tr -d ' '     ||:)
	extn=$(echo $1 | cut -d\, -f4 | tr -d ' '     ||:)
	srvs=$(echo $1 | cut -d\, -f5 | grep -vw none ||:)
	srvs=${srvs%;}

	patch_file="$prov-$name-$vern.patch"
	patch_path="$patch_dir/$patch_file"
	bckup_path=${patch_path%.patch}

	return 0
}

exit_for_manual_intervetion() {
	stty +echoctl 2>/dev/null; trap - SIGINT EXIT
	reload_list=$(cat "$reload_path" 2>/dev/null ||:)
	errexit "patch #$n failed to apply because cannot be reversed.

\tManual intervetion is needed, these are the working values: 

 patch path: $(dirname  "$patch_path")
 patch file: $(basename "$patch_path")
 patch prev: $(basename "${patch_prev_path:-none}")
 patch opts: $patch_opts
 srv2reload: $(echo $reload_list)"
}

patch_db="/etc/patches.db"
patch_dir="/etc/patches.d"
patch_lst="/etc/patches.list"
patch_opts="-slEfp1 -r /dev/null --no-backup-if-mismatch -d/"

patches_to_apply=""

reload_path="$patch_dir/services-to-reload.list"

filter_1="grep . | sed -e 's,^,\ \ \ ,' | uniq ||:"
filter_2="grep . | sed -e 's,^,\ \ \|\ \ ,' ||:"
filter_3="grep -Ev 'Status:|Percentage:|Results:'"
filter_3="$filter_3 | $filter_2"

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

reload_list=$(cat "$reload_path" 2>/dev/null ||:)
if true || [ -n "$reload_list" ]; then
	echo
	echo "WARNING: system services to restart found from a previous run"
	echo "         collected and put in the current list of restarting." 
fi

# this loop install all the patches in the ordered list #=======================
n=1; mkdir -p "$patch_dir/"; for patch_name in $patches_to_apply; do # =========

echo
echo "=> Previous patch #$n check: $patch_name"
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
echo "=> Download the patch #$n last version..."
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
	continue
elif [ "$reversible" = "OK" ]; then
	patch_new="$patch_path"
	echo "  \_ patch status: new version to apply."
else
	echo "  \_ patch status: patch to apply."
fi

echo
echo "patch path: $patch_path"
echo "bckup path: $bckup_path"

echo
echo "=> System services check for patch #$n..."

brk=0
for srv in $srvs; do
	systemctl --no-pager status $srv >/dev/null 2>&1
	if [ $? -eq 4 ]; then
# srv_file=$(echo $out | sed -ne "s/Unit \([^ ]*\)\.service .*/\\1/p")
		echo "  \_ missing system service: $srv"
		echo "  \_ searching, wait..."
		out=$(pkcon install -yp --allow-reinstall $srv 2>&1)
		if [ $? -eq 0 ]; then
			echo "  \_ system service installed: $srv"
		else
			echo "  \_ system service not found: $srv"
			echo "$out" | eval $filter_3
			brk=1
			break
		fi
	fi
done ||:
if [ $brk -ne 0 ]; then
	echo "  \_ system services check: failed, skip patch #$n."
	continue
fi

if false; then
# save with the patch, the services that need to be restarted
servs_path=$(echo "$patch_path" | sed s/.patch$/.servs/)
echo $srvs > "$servs_path"
fi

echo
echo "=> Applying the patch #$n last version..."

# This part cannt be interrupted # *********************************************
set +e; stty -echoctl 2>/dev/null; trap 'true' SIGINT EXIT

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

if [ "$reversed" = "KO" ]; then exit_for_manual_intervetion; fi   #<- exit-point

skip=0
echo "  \_ Checking to apply patch..."
# test if the patch can be applied as expected to be
# apply the patch may fail despite the dry run test
# forcely revert the patch that applied only partially
if ! patch $patch_opts --dry-run -i "$patch_path"; then
	echo "  \_ In apply patch dry-run failed, skip."
	skip=1
elif patch $patch_opts -i "$patch_path"; then
	echo "  \_ Patch #$n applied to rootfs"
	echo $srvs >> "$reload_path"
else
	echo "  \_ Patch #$n failed to apply, reverting back..."
	if patch -R $patch_opts -i "$patch_path"; then
		echo "  \_ Patch #$n reverted back sucessfully."
		skip=1
	else
		echo "  \_ Patch #$n revert back failed, abort."
		exit_for_manual_intervetion                               #<- exit-point	
	fi
fi

stty +echoctl 2>/dev/null; set -e; trap - SIGINT EXIT
# ******************************************************************************
# move to the next patch
n=$((n+1))
done # =========================================================================

if false && [ $err -ne 0 ]; then
	echo
	echo "WARNING: patch #$n failed to be applied to rootfs, skipped"
	echo "         fix pre-requisites and then try to install again."
else
	: # RAF, TODO: update the patches database (lock is required)
fi

# This part cannt be interrupted # *********************************************
set +e; stty -echoctl 2>/dev/null; trap 'true' SIGINT EXIT

echo
reload_list=$(cat "$reload_path" 2>/dev/null ||:)
if [ -n "$reload_list" ]; then
	rm -f "$reload_path"
	echo "=> Restarting system services"
	echo "\_ to restart: "$reload_list
	echo
	echo "WARNING: WiFi tethering will not automatically raise up again"
	echo "         You may be going to be disconnected, grab your phone"
	echo
	systemctl --no-pager daemon-reload
	for i in $reload_list; do
		systemctl --no-pager reload $i ||:
	done 2>/dev/null
	systemctl --no-pager restart $reload_list
	echo "=> Check the restarted system services"
	echo "\_ to check: "$reload_list
	echo
	for srv in $reload_list; do
		systemctl --no-pager status $reload_list 2>&1 |\
			tr '\n' '^' | cut -d'^' -f1,3 | tr '^' '\n'
		echo
	done
fi

stty +echoctl 2>/dev/null; set -e; trap - SIGINT EXIT
# ******************************************************************************
