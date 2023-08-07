#!/bin/sh
# bash or ash or dash is required but sh for universal compatibility.
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
# release: 0.1.1

if ! type get_this_shell_name 2>&1 | head -n1 | grep -q "is a function"; then
	shn=$(cat /proc/$$/cmdline | tr '\0' '\n' | grep -v busybox | head -n1)
	if [ -x "$shn" ]; then
		shx=$(basename "$shn")
		shn=$(readlink -f "$shn")
		shn=$(basename "$shn")
		if [ "$shn" = "busybox" ]; then
			shn=$shx
		fi
	fi
else
	shn=$(get_this_shell_name)
fi
echo
echo "Script running on shell: $shn"
if [ "$shn" = "dash" -o "$shn" = "bash" -o "$shn" = "ash" ]; then
	:
else
	echo
	echo "WARNING: this script requires bash or ash or dash and may not work."
	echo
fi >&2

################################################################################
set -ue

zadir=$(dirname $0 2>/dev/null ||:)
source "${zadir:-.}/rfos-script-functions.env" 2>/dev/null ||:

# FUNTIONS DEFINITIOS ##########################################################

fd=0
if ! type isafunc 2>&1 | head -n1 | grep -q "is a function"; then
	test $fd -eq 0 && echo
	echo "function define isafunc()"
	isafunc() {
		test -n "${1:-}" || return 1
		type $1 2>&1 | head -n1 | grep -q "is a function"
	}
	fd=1
fi

if ! isafunc errexit; then
	test $fd -eq 0 && echo
	echo "function define errexit()"
	errexit() {
		if [ -n "${1:-}" ]; then
			echo
			echo "ERROR: $@"
			echo
		fi >&2
		exit 1
	}
	fd=1
fi

if ! isafunc download; then
	test $fd -eq 0 && echo
	echo "function define download()"
	download() {
		test -n "${2:-}" || return 1
		if which wget >/dev/null; then
			wget $1 -qO - >$2; sync $2
		elif which curl >/dev/null; then
			curl -sL $1 >$2; sync $2
		else
			return 1
		fi
	}
	fd=1
fi
test $fd -ne 0 && echo

# VARIABLES DEFINITIONS ########################################################

branch="devel"
branch="${1:-$branch}"
url="https://raw.githubusercontent.com/robang74/redfishos/$branch/scripts"
dir=$HOME/bin

rfos=$(cd /etc && egrep -i "[sail|red]fish" *-release issue group passwd ||:)
if [ "$rfos" != "" ]; then ## rfos #############################################
echo "Script running on mbile device"
src="
sfos/patch_dblock_functions.env
sfos/patch_installer.sh
sfos/patch_downloader.sh
sfos/setnet_postroute.sh
rfos-script-functions.env
rfos-suite-installer.sh
rfos-first-setup.sh
"
else ## pcos ###################################################################
echo "Script running on a workstation"
src="
pcos/fastboot_usb3fix.sh
pcos/sfos-ssh-connect.env
rfos-script-functions.env
rfos-suite-installer.sh
rfos-first-setup.sh
"
fi #############################################################################
# MAIN CODE EXECUTION ##########################################################

blankline() { touch "$1" && tail -n1 "$1" | grep -q . && echo >> "$1" ||:; }

hme=$(printf "$dir" | sed -e "s,$HOME/,~,")
brn=$(printf "$branch" | head -c6)
envirm=""

echo
mkdir -p $dir || errexit "cannot create '$dir' folder, abort."
for i in $src; do
	dst=$dir/$(basename $i)
	printf "Downloading from %s to %s: %-32s ..." $brn $hme $i
	rm -f $dst
	download $url/$i $dst || errexit "cannot download $i, abort."
	echo " ok"
	if echo $i | grep -q "\.sh$"; then
		chmod a+x $dst || errexit "cannot chmod +x $dst, abort."
	fi
done

for shellrc in $HOME/.profile $HOME/.bashrc; do
	blankline "$shellrc"
	for i in $src; do
		dst=$dir/$(basename $i)
		if ! echo $i | grep -q "\.sh$"; then
			grep -q "source $dst" "$shellrc" ||\
				echo "source $dst" >> "$shellrc"
		fi
	done
	grep -q "export -f src_file_env" "$shellrc" ||\
		echo "export -f src_file_env" >> "$shellrc"
	blankline "$shellrc" "$shellrc"
	envirm="$shellrc ${envirm:-}"
#	grep -qE ".bashrc" $shellrc && break
done

echo
echo "DONE: scripts suite for RedFish OS, installed in"
echo "      folder    : $dir"
echo "      enviroment: $envirm"
echo
echo "Please, (re)execute bash to load its enviroment, then"
echo "      rfos-first-setup.sh"
echo "to start the RedFish OS first boot setup procedure"
echo

