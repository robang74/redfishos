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
# release: 0.1.2

set -ue -o pipefail

trap 'echo -e "\nError occurred ($?) on $LINENO\n" >&2' ERR EXIT

src_file_env "rfos-script-functions"

# FUNTIONS DEFINITIONS #########################################################

patch_unapplied_warning() {
	echo
	echo "WARNING: patch #$n failed to be applied to rootfs, skipped"
	echo "         patch: $patch_name $vern"
	echo "         fix pre-requisites and then try to install again."
}

patch_string_to_filename() {
	test -n "${1:-}" || return 1

	# cast the patch data into useful variables
	strn=$(echo $1    | cut -d\; -f1)
	prov=$(echo $strn | cut -d\, -f1  | tr  -d ' '    ||:)
	name=$(echo $strn | cut -d\, -f2  | tr  -d ' '    ||:)
	vern=$(echo $strn | cut -d\, -f3  | tr  -d ' '    ||:)
	extn=$(echo $strn | cut -d\, -f4  | tr  -d ' '    ||:)
	srvs=$(echo $strn | cut -d\, -f5- | grep -vw none ||:)
	srvs=$(echo $srvs | cut -d\# -f1)

	patch_file="$prov-$name-$vern.patch"
	patch_path="$patch_dir/$patch_file"
	bckup_path=${patch_path%.patch}

	return 0
}

exit_for_manual_intervetion() {
	trap - SIGINT EXIT ||:
	stty +echoctl 2>/dev/null ||:
	servs_list=$(cat "$reload_path" 2>/dev/null ||:)
	errexit "patch #$n failed to apply because cannot be $1.

\tManual intervetion is needed, these are the working values:

 patch path: $(dirname  "$patch_path")
 patch name: $patch_name
 patch opts: $patch_opts
 patch file: $(basename "$patch_path")
 patch revr: $(basename "${patch_reverse:-none}")
 patch prev: $(basename "${patch_prev_path:-none}")
 srv2reload: $(echo ${servs_list:-none})"
}

do_patch() {
	set -ue -o pipefail
	patch $patch_opts "$@" 2>&1 | { eval "$filter_2" ||:; }
}

do_patch() {
	patch $patch_opts "$@" 2>&1
}

reversible_check() {
	echo "  \_ Checking for reversibility..."
	if do_patch -R --dry-run -i "$1" >/dev/null; then
		reversible="OK"
		patch_reverse=$1
	else
		reversible="KO"
		patch_reverse=""
	fi
	echo "  \_ Reversibility : $reversible"
	test "$reversible" = "OK"
}

applicable_check() {
	echo "  \_ Checking for application... "
	if do_patch --dry-run -i "$1" >/dev/null; then
		applicable="OK"
		patch_applicable=$1
	else
		applicable="KO"
		patch_applicable=""
	fi
	echo "  \_ Applicability : $applicable"
	test "$applicable" = "OK"
}

read_patch_string() {
	touch "$patch_db"
	grep ", *$patch_name *," "$patch_db"
	return 0
}

# VARIABLES DEFINITIONS ########################################################

patch_db="/etc/patches.db"
patch_dir="/etc/patches.d"
patch_lst="/etc/patches.list"
patch_opts="-slEfp1 -r /dev/null --no-backup-if-mismatch -d/"

patches_to_apply=""

reload_path="$patch_dir/services-to-reload.list"

filter_1="grep . | sed -e 's,^,\ \ \ ,'"
filter_2="grep . | sed -e 's,^,\ \ \|\ \ ,'"
filter_3="grep -Ev 'Status:|Percentage:|Results:'"
filter_3="$filter_3 | $filter_2"
filter_4="sed -e 's/^+ //' | $filter_2"

test "x${1:-}" == "x--all" && patches_to_apply="
sshd-publickey-login-only
utilities-quick-fp-restart
x10ii-iii-agps-config-emea
x10ii-iii-udev-rules-fixing
dnsmasq-connman-integration
"

# MAIN CODE EXECUTION ##########################################################

export PATH=$HOME/bin:$PATH

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
echo "  \_ List of patches to apply:"
echo
echo "$patches_to_apply" | eval $filter_1

servs_list=$(cat "$reload_path" 2>/dev/null ||:)
if [ -n "$servs_list" ]; then
	echo
	echo "WARNING: system services to restart found from a previous run"
	echo "         collected and put in the current list of restarting." 
fi

# this loop install all the patches in the ordered list #=======================
n=0; mkdir -p "$patch_dir/"; for patch_name in $patches_to_apply; do n=$((n+1))

echo
echo "=> Previous patch #$n check: $patch_name"

patch_prev_strn=$(read_patch_string)
patch_prev_path=""
reversible="none"
if patch_string_to_filename "$patch_prev_strn"; then
	echo "  \_ previous patch: found"
	echo "  |  $patch_prev_strn"
	if reversible_check "$patch_path"; then
		patch_prev_path=$patch_reverse
	fi
else
	echo "  \_ previous patch: none"
fi

echo
echo "=> Download the patch #$n last version..."
echo "  \_ patch name: $patch_name"
if ! patch_downloader.sh $patch_name 2>&1 | eval $filter_4; then
	echo "  \_ patch discarded."
	continue
fi
patch_strn=$(read_patch_string)
if ! patch_string_to_filename "$patch_strn"; then
	errexit "patch string  of '$patch_name' is void, abort."
fi

if [ "$patch_path" = "$patch_prev_path" ]; then
	echo "  \_ Patch status: just applied in its last version."
	continue
else
	echo "  \_ Patch status: last version to apply."
fi

echo
echo "=> System services check for patch #$n..."

brk=0
if [ -n "${srvs:-}" ]; then
	for srv in $srvs; do
		ret=0; systemctl --no-pager status $srv >/dev/null 2>&1 || ret=$?
		if [ $ret -eq 4 ]; then
			echo "  \_ missing system service: $srv"
			echo "  \_ searching, wait..."
			out=$(pkcon install -yp --allow-reinstall $srv 2>&1)
			if [ $? -eq 0 ]; then
				echo "  \_ system service installed: $srv"
			else
				echo "  \_ system service not found: $srv"
				echo "$out" | eval $filter_3 ||:
				brk=1
				break
			fi
		fi
	done
else
	echo "  \_ system services: none"
fi
if [ $brk -ne 0 ]; then
	echo "  \_ system services check: failed, skip patch #$n."
	patch_unapplied_warning
	continue
fi

# This part cannot be interrupted # ********************************************
set +e; stty -echoctl 2>/dev/null ||:; trap 'true' SIGINT EXIT

echo
echo "=> Applying the patch #$n last version..."
if [ -n "$patch_prev_path" ]; then
	verstr="previous"
else
	verstr="last"
fi
echo "  \_ Reversing $verstr version patch..."
if reversible_check "${patch_prev_path:-$patch_path}"; then
	if do_patch -R -i "${patch_prev_path:-$patch_path}"; then
		reversed="OK"
	else
		reversed="KO"
	fi
	echo "  \_ Reversing patch status: $reversed"
fi

skip=0
# test if the patch can be applied as expected to be
# apply the patch may fail despite the dry run test
# forcely revert the patch that applied only partially
if ! applicable_check "$patch_path"; then
	echo "  \_ In applying patch the dry run failed, skip."
	skip=1
elif do_patch -i "$patch_path"; then
	echo "  \_ Patch #$n applied to rootfs"
	echo "  \_ Services scheduled to restart: $srvs"
	echo $srvs >> "$reload_path"
else
	echo "  \_ Patch #$n failed to apply, reverting back..."
	if do_patch -R -i "$patch_path"; then
		echo "  \_ Patch #$n reverted back sucessfully."
		skip=1
	else
		echo "  \_ Patch #$n revert back failed, abort."
		exit_for_manual_intervetion "reversed"                    #<- exit-point	
	fi
fi

if [ $skip -eq 1 ]; then
	exit_for_manual_intervetion "applied"
fi

stty +echoctl 2>/dev/null ||:; set -e; trap - SIGINT EXIT
# ******************************************************************************
# move to the next patch
done # =========================================================================

# This part cannot be interrupted # ********************************************
set +e; stty -echoctl 2>/dev/null ||:; trap 'true' SIGINT EXIT

echo
sctlcmd="systemctl --no-pager"
servs_list=$(cat "$reload_path" 2>/dev/null ||:)
if [ -n "${servs_list:-}" ]; then
	echo "=> Restarting system services"
	echo "\_ to restart: "$servs_list
	echo
	echo "WARNING: WiFi tethering will not automatically raise up again"
	echo "         You may be going to be disconnected, grab your phone"
	echo
	$sctlcmd daemon-reload
	for i in $servs_list; do
		if [ "x${i:0:1}" = "x-" ]; then
			s=${i:1}
		else
			s="$i"
		fi
		restart_list="${restart_list:-} $s"
	done
	rm -f "$reload_path"
	$sctlcmd reload $restart_list 2>/dev/null ||:
	$sctlcmd enable $restart_list 2>&1 | eval $filter_1 ||:
	echo
	$sctlcmd restart $restart_list
	echo "=> Check the restarted system services"
	echo "\_ to check: "$servs_list
	echo
	for i in $restart_list; do
		$sctlcmd status $i 2>&1 |\
				tr '\n' '^' | cut -d'^' -f1,3 | tr '^' '\n'
	done
	echo
fi

stty +echoctl 2>/dev/null ||:; set -e; trap - SIGINT EXIT
# ******************************************************************************
