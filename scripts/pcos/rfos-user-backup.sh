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
# release: 0.0.3

set -eu

src_file_env "sfos-ssh-connect"

# VARIABLES DEFINITIONS ########################################################

usage() {
    echo
    echo "USAGE: $(basename $0) [ -h | -v ] [ /home/defaultuser ]"
    echo
    exit 0
}

while [ -n "${1:-}" ]; do
    if [ "${1:0:1}" = "/" ]; then
        userdir="$1"
        shift
        continue
    fi
    case $1 in
    -v)
        v="v"
        ;;
    -h|--help|*)
        usage
        ;;
    esac
    shift
done

userdir=${userdir:-/home/defaultuser}

#date_time=$(date +"%F-%H-%M-%S")
date_time=$(date +"%Y%m%d%H%M%S")
prl_opts="--pipe --recend '' --keep-order --block-size 16M"
tar_opts="--numeric-owner -p"
excl_list="
.cache cache cache2 vungle_cache diskcache-v4 .mozilla/storage
$userdir/Pictures/Default $userdir/Videos/Default $userdir/.tmp
"

for i in $excl_list; do tar_opts="$tar_opts --exclude '$i/*'"; done

tarball="backup-$(basename ${userdir})-${date_time}.tar.gz"

# MAIN CODE EXECUTION ##########################################################

ask_to_stop_mobile_data

echo
echo "=> Creating home user backup by SSH/cat..."
echo "  \_ archive: $tarball"
#echo "  \_ exclusions lists: $excl_list"

{
    time ssh $ssh_opts root@$sfos_ipaddr \
        "tar ${v:-}c $tar_opts ${userdir:1}/ -C / | pigz -4Ric" |\
            dd bs=1M iflag=fullblock of=$tarball
} 2>&1 | grep -v "tar: removing leading" | grep -E "real|copied" | tr '\t' ' '\
    | sed -e "s/.* bytes (\(.*\), .*)\(.*\)/transfer speed: \\1\\2/" -e \
        "s/real /execution time: /" | sed -e "s,^,  |  ,"
echo "  \_ creation: completed"

echo
printf "=> Syncing archive file to local storage..."
sync $tarball
echo " OK"

echo
printf "=> Checking archive file for integrity..."
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

