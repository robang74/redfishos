#/bin/sh
################################################################################
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released under GPLv2 license terms
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

if [ "$(whoami)" != "root" ]; then
    echo "This script should be executed by root"
    echo "Please, insert the password or CTRL-C"
    devel-su /bin/bash -c "$0 $@"
    exit $?
fi


if [ "x${1:-}" = "x-r" ]; then
    echo
    echo "=> Removing the USB:rndis0 nating rule"
    rmvrule=1
    shift
else
    echo
    echo "=> Adding the USB:rndis0 nating rule"
    rmvrule=0
fi

swcrule=0
if [ "x${1:-}" = "x-s" ]; then
    echo
    echo "=> Switching the USB:rndis0 nating rule"
    swcrule=1
    shift
fi

# functions ####################################################################

getip() { ifconfig $1 | sed -ne "s/ *inet addr:\([0-9\.]*\).*/\\1/p"; }
getnet() { echo $(getip $1 | cut -d. -f-$2).0/$(($2*8)); }
do_for_interfaces() {
    local i cmd="$1"; shift
    for i in "$@"; do
        ip=$(getip $i 2>/dev/null)
        test -z "$ip" && continue
        eval "$cmd"
    done
}

# parameters ###################################################################
set -u

outif=$(do_for_interfaces 'echo $i; break' vpn0 rmnet_data1 rmnet_data2)
iptbl_opts="-s $(getnet rndis0 3) -o $outif -j MASQUERADE"

echo
echo "=> Search for the default route"
outrt=$(route -n | sed -ne "/^0.0.0.0 .* $outif/p" | tr -s ' ')
if [ -n "$outrt" ] ; then
    res=""
else
    res="NOT"
fi
echo "  \_ interface $outif is ${res:+$res }the default gateway"
echo
echo "   $outrt"
echo

# iptables #####################################################################

iptrulechk() { iptables -t nat -S | grep -qE -- "$iptbl_opts"; }
iptruleadd() { iptables -t nat -I POSTROUTING 1 $iptbl_opts; }
iptruledel() { iptables -t nat -D POSTROUTING $iptbl_opts; }

if [ $rmvrule -eq 1 ]; then
    iptruledel 2>/dev/null ||:
    ret=0 # can fail, it is ok
elif [ $swcrule -eq 1 ]; then
    if iptrulechk; then
        iptruledel; ret=$?
    else
        iptruleadd; ret=$?
    fi
elif ! iptrulechk; then
    iptruleadd; ret=$?
fi

echo "=> Active nating rules:"
echo
iptables -t nat -S | sed -e "s/^/  /"
echo
exit $ret
