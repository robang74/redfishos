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

#date_time=$(date +"%F-%H-%M-%S")
date_time=$(date +"%Y%m%d%H%M%S")
tarball="backup-rootfs-${date_time}.tar.gz"
find_opts="-xdev ! -type d" # likely -print0 but tar has not --null
tar_opts="--numeric-owner -p"
excl_list_0="/tmp /var/tmp /usr/tmp /var/cache /home /root"
excl_list_1="/usr/lib/locale /vendor /apex /odm /boot"
excl_list_2="/usr/libexec/droid-hybris"
excl_list_3="/usr/share/themes /usr/share/man /usr/share/sailfish-tutorial
/usr/share/locale /usr/share/ambience /usr/share/fonts /usr/share/translations
/usr/share/sounds /usr/share/licenses"

case "${1:-}" in
    "-1")
        excl_list_strn="0"
        excl_list=${excl_list_0}
        ;;
    "-2")
        excl_list_strn="0 1"
        excl_list="${excl_list_0} ${excl_list_1}"
        ;;
    "-3")
        excl_list_strn="0 1 2"
        excl_list="${excl_list_0} ${excl_list_1} ${excl_list_2}"
        ;;
       *)
        excl_list_strn="0 1 2 3"
        excl_list="${excl_list_0} ${excl_list_1} ${excl_list_2} ${excl_list_3}"
        ;;
esac

for i in $excl_list; do find_opts="$find_opts ! -path $i/\*"; done

# MAIN CODE EXECUTION ##########################################################

mob_data_check_cmd="
    { ifconfig rmnet_data1; ifconfig rmnet_data2; } | grep 'inet6* addr'
"

while true; do
    afish getip
    sshcmd="ssh root@$sfos_ipaddr"
    echo
    printf "=> Check mobile data connection on device..."
    if $sshcmd "$mob_data_check_cmd" | grep -q 'inet6* addr'; then
        echo " active"
        echo
        echo "WARNING: please, deactive mobile data on the samrtphone"
        echo "         back-up should be use the USB connection, only"
        echo
        echo "         Press ENTER to retry or CTRL-C to stop"
        sleep 1
        read
    else
        echo " ok"
        break
    fi
done

echo
echo "=> Creating backup by SSH/cat in one minute..."
echo "  \_ archive: $tarball"
echo "  \_ exclusions lists: $excl_list_strn"

{
    time $sshcmd \
        "find / $find_opts | tar ${v}c $tar_opts -T - | pigz -4Ric" |\
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

