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
# release: 0.0.7 - patched x2

set -ue -o pipefail

zadir=$(dirname $0 2>/dev/null ||:)
source "${zadir:-.}/rfos-script-functions.env" 2>/dev/null ||:

# FUNTIONS DEFINITIOS ##########################################################

if ! type isafunc 2>&1 | head -n1 | grep -q "is a function"; then
	echo -e "\nfunction define isafunc()"
	isafunc() {
		test -n "${1:-}" || return 1
		type $1 2>&1 | head -n1 | grep -q "is a function"
	}
fi

if ! isafunc errexit; then
	echo "function define errexit()"
	errexit() {
		if [ -n "${1:-}" ]; then
			echo
			echo "ERROR: $@"
			echo
		fi >&2
		exit 1
	}
fi

if ! isafunc download; then
	echo "function define download()"
	download() {
		test -n "${2:-}" || return 1
		if which wget >/dev/null; then
			wget $1 -qO  $2; sync $2
		elif which curl >/dev/null; then
			curl -sL $1 >$2; sync $2
		else
			return 1
		fi
	}
fi

# VARIABLES DEFINITIONS ########################################################

branch="devel"
branch="${1:-$branch}"
url="https://raw.githubusercontent.com/robang74/redfishos/$branch/scripts"
dir=$HOME/bin

rfos=$(cd /etc && egrep -i "[sail|red]fish" *-release issue group passwd ||:)
if [ "$rfos" != "" ]; then ## rfos #############################################
echo -e "\nScript running on mbile device"
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
echo -e "\nScript running on a workstation"
src="
pcos/fastboot_usb3fix.sh
pcos/sfos-ssh-connect.env
rfos-script-functions.env
rfos-suite-installer.sh
rfos-first-setup.sh
"
fi #############################################################################
# MAIN CODE EXECUTION ##########################################################

shellrc="$HOME/.profile"
bashrc="$HOME/.bashrc"

blankline() { touch "$1" && tail -n1 "$1" | grep -q . && echo >> "$1"; }

echo
blankline "$shellrc"
mkdir -p $dir || errexit "cannot create '$dir' folder, abort."
for i in $src; do
	dst=$dir/$(basename $i)
	printf "Downloading from %s to %s: %-32s ..." \
		${branch:0:6} ${dir/$HOME\//\~/} $i
	rm -f $dst
    download $url/$i $dst || errexit "cannot download $i, abort."
    echo " ok"
	if echo $i | grep -q "\.sh$"; then
		chmod a+x $dst || errexit "cannot chmod +x $dst, abort."
	else
		grep -q "source $dst" "$HOME/.bashrc" ||\
			echo "source $dst" >> "$HOME/.bashrc"
	fi
done
grep -q "export -f src_file_env" "$shellrc" ||\
	echo "export -f src_file_env" >> "$shellrc"
blankline "$shellrc" "$shellrc"

blankline "$bashrc"
grep -q "source $shellrc" "$bashrc" ||\
	echo "source $shellrc" >> "$bashrc"
blankline "$bashrc"

echo
echo "DONE: scripts suite for RedFish OS, installed in"
echo "      folder    : $dir"
echo "      enviroment: $HOME/.bashrc"
echo
echo "Please, (re)execute bash to load its enviroment, then"
echo "      rfos-first-setup.sh"
echo "to start the RedFish OS first boot setup procedure"
echo

