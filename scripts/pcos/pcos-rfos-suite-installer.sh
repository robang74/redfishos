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
			wget $1 -qO $2
		elif which curl >/dev/null; then
			curl -sL $1 >$2
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

src="
pcos/pcos-rfos-suite-installer.sh
sfos/patch_dblock_functions.env
rfos-script-functions.env
pcos/sfos-ssh-connect.env
pcos/fastboot_usb3fix.sh
rfos-first-setup.sh
"

# MAIN CODE EXECUTION ##########################################################

echo
mkdir -p $dir || errexit "cannot create '$dir' folder, abort."
for i in $src; do
	dst=$dir/$(basename $i)
	printf "Downloading from %s to %s: %-36s ..." \
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
grep -q "export -f src_file_env" "$HOME/.bashrc" ||\
echo "export -f src_file_env" >> "$HOME/.bashrc"

echo
echo "DONE: scripts suite for RedFish OS, installed in"
echo "      folder    : $dir"
echo "      enviroment: $HOME/.bashrc"
echo
echo "Please, (re)execute bash to load its enviroment, then"
echo "      rfos-first-setup.sh"
echo "to start the RedFish OS first boot setup procedure"
echo

