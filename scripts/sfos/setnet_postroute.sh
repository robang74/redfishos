#/bin/bash
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released under MIT license for SailFish OS 4.5.19
#
################################################################################

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

