#!/bin/bash
################################################################################
#
# Copyright (C) 2023, Roberto A. Foglietta
#     Contact: roberto.foglietta@gmail.com
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

if [ "$(whoami)" != "root" ]; then
    echo "This script should be executed by root"
    echo "Please, insert the password or CTRL-C"
    devel-su /bin/bash -c "$0 $1"
    exit $?
fi

# functions ####################################################################

getip() { ifconfig $1 | sed -ne "s/ *inet addr:\([0-9\.]*\).*/\\1/p"; }
getnet() { echo $(getip $1 | cut -d. -f-$2).0/$(($2*8)); }
do_for_interfaces() { local i cmd="$1"; shift; for i in "$@"; do 
ip=$(getip $i 2>/dev/null); test -z "$ip" && continue; eval "$cmd"; done; }

# parameters ###################################################################

outif=$(do_for_interfaces 'echo $i; break' vpn0 rmnet_data1 rmnet_data2)
iptbl_opts="-s $(getnet rndis0 3) -o $outif -j MASQUERADE"

