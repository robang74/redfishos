#!/bin/bash
################################################################################
#
# Copyright (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
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

usbver="${1:-}"
if [ "$usbver" = "2" ]; then
    pwctrl="on"
    pciusb="d8.l=0 d0.l=0"   
elif [ "$usbver" = "3" ]; then
    pwctrl="auto"
    pciusb="d8.l=1 d0.l=3"   
else 
    echo -e "\nUSAGE: $(basename $0) 2 or 3\n" 
    exit 1
fi

if [ "$(whoami)" != "root" ]; then
    echo "This script should be executed by root"
    echo "Please, insert the password or CTRL-C"
    if which devel-su >/dev/null; then
        devel-su /bin/bash -c "$0 $1"
    else
        sudo /bin/bash -c "$0 $1"
    fi
    exit $?
fi

devname="Sony Ericsson Mobile"
if [ "$usbver" = "2" ]; then
	echo -e "\n$devname USB2 mode"
else
	echo -e "\nSystem switch to USB3 mode"
fi

################################################################################

echo "USB devices unbinding..."

usb_dir=/sys/bus/pci/drivers/xhci_hcd
usb_lst=$(ls -1 $usb_dir | grep -e "^[0-9:.]\{12\}$")

for i in $usb_lst; do
	echo $i >$usb_dir/unbind
done

sleep 1

################################################################################

echo "USB hub/ports setting..."

for i in $(lspci -nn |\
	sed -ne "s,.* USB .* \[\([0-9a-f]\{4\}:[0-9a-f]\{4\}\)\] .*,\\1,p")
		do setpci -H 1 -d $i $pciusb
done

sleep 1

################################################################################

echo "USB devices rebinding..."

for i in $usb_lst; do
	echo $i >$usb_dir/bind
done

sleep 3

################################################################################

echo "USB power control..."

usb_dir=/sys/bus/usb/drivers/rndis_host
for i in $usb_dir/*/net/usb*/power/control; do
	echo $pwctrl >$i
done 2>/dev/null 

tree=$(lsusb -vvt)
nline=$(echo "$tree" | grep -n "$devname" | cut -d: -f1)
for j in $nline; do
    devpath=$(echo "$tree" | head -n$((j+1)) |\
        tail -n1 | awk '{ print $1 }')
    for i in $(find $devpath/ -name control);
        do echo $pwctrl >$i; done
done
test -z "$nline" || echo "device found on USB tree"

################################################################################

if [ "$usbver" = "2" ]; then
	echo "set USB$usbver power always on mode"
else
	echo "set USB$usbver auto powering mode"
fi

exit 0
