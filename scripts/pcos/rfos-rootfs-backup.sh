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
# release: 0.0.8

set -eu

src_file_env "sfos-ssh-connect"

# VARIABLES DEFINITIONS ########################################################

#date_time=$(date +"%F-%H-%M-%S")
date_time=$(date +"%Y%m%d%H%M%S")
find_opts="-xdev ! -type d" # likely -print0 but tar has not --null
tar_opts="--numeric-owner -p"

excl_list_1="/tmp /var/tmp /usr/tmp /var/cache /home /root"
excl_list_2="/usr/lib/locale /vendor /apex /odm /boot"
excl_list_3="/usr/libexec/droid-hybris"
excl_list_4="/usr/share/themes /usr/share/man /usr/share/sailfish-tutorial
/usr/share/locale /usr/share/ambience /usr/share/fonts /usr/share/translations
/usr/share/sounds /usr/share/licenses"

usage() {
    cat <<'EOF'

USAGE: excl_list='...' $(basename $0) [ -v | -h ] [- 0|...|-4 ] [ /rootfs ]

EOF
    exit 0
}

while true; do
    while [ -n "${1:-}" ]; do
        if [ "${1:0:1}" = "/" ]; then
            rmtdir="$1"
            shift
            continue
        fi
        case $1 in
            -4) excl_list_strn="4 ${excl_list_strn:-}"
                excl_list="${excl_list:-} ${excl_list_4}"
                ;;&
        -[3-4]) excl_list_strn="3 ${excl_list_strn:-}"
                excl_list="${excl_list:-} ${excl_list_3}"
                ;;&
        -[2-4]) excl_list_strn="2 ${excl_list_strn:-}"
                excl_list="${excl_list:-} ${excl_list_2}"
                ;;&
        -[1-4]) excl_list_strn="1 ${excl_list_strn:-}"
                excl_list="${excl_list:-} ${excl_list_1}"
                ;;&
        -[0-4]) lvl="$1"
                ;;
            -v)
                v="v"
                ;;
            -h|--help|*)
                usage
                ;;
        esac
        shift
    done
    if [ -n "${lvl:-}" ]; then
        break
    else
        set -- -4
    fi
done

for i in ${excl_list:-}; do find_opts="$find_opts ! -path $i/\*"; done

tarball="backup-rootfs${lvl}-${date_time}.tar.gz"

rmtdir=${rmtdir:-/}

# MAIN CODE EXECUTION ##########################################################

ask_to_stop_mobile_data

echo
echo "=> Creating backup by SSH/cat in one minute..."
echo "  \_ archive: $tarball"
echo "  \_ remote source folder: $rmtdir"
echo "  \_ exclusions lists: ${excl_list_strn:-none}"

sshcmd="ssh -q $ssh_opts"
if [ "$sfos_ipaddr" = "$sfos_ip_addr_r" ]; then
    sshcmd="sshpass -p recovery $sshcmd"
fi

{
    time $sshcmd root@$sfos_ipaddr "cd '$rmtdir' && " \
        "find . $find_opts | tar ${v:-}c $tar_opts -T - | pigz -4Ric" |\
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

