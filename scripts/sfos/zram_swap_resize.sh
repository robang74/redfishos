#/bin/bash
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released under MIT license for SailFish OS 4.5.19
#
################################################################################
# release 0.0.9

if [ "$(whoami)" != "root" ]; then
    echo "This script should be executed by root"
    echo "Please, insert the password or CTRL-C"
    devel-su /bin/bash -c "$0 $1"
    exit $?
fi

if echo "${1:-help}" | grep -q "h"; then
    echo -e "\nUSAGE: $(basename $0) [ size(MB) | offload ]\n"
    exit 0
fi

### GLOBAL VARIABLES INITIALISATION ############################################

mtavail=no
swapuse=off
pwsvenagain=0
pwsvstate=enabled
blockname=/dev/block/zram0
filename=$(ls -1 /vendor/etc/fstab.pdx20?)

### GLOBAL FUNTCIONS DEFINITIONS ###############################################

power_saving_state() {
    pwsvstate=$(mcetool | sed -ne \
      "s,^Power saving mode: *\([endisabl]*\) .*,\\1,p")
    echo "Power saving mode: $pwsvstate" 
}

power_saving_toggle() {
    if [ "$1" = "disabled" ]; then
        echo "Enabling power state..."
        mcetool --set-power-saving-mode=enabled
        power_saving_state
    elif [ "$1" = "enabled" ]; then
	echo "Disabling power state..."
        mcetool --set-power-saving-mode=disabled
        power_saving_state
    else
        echo "USAGE: power_saving_toggle enable|disable"
        return 1
    fi
    return 0
}

mcetool_check() {
    if ! which mcetool >/dev/null; then
        echo -e "\nThis script whish to have mce-tools installed"
	echo    "because swapoff will fail with power saving enabled."
	echo    "You can disable power saving manually or you can"
        echo    "accept to reboot the device to complete the resize"
        echo    "or you can install with pkcon install -y mce-tools"
        echo -e "\nPress ENTER to continue or CTRL-C to abort."
        read
     fi
     mtavail=yes
}

zram_swap_change() {
    echo -e "\nDisabling and resizing the zRAM swap..." |\
        awk '{print} END {fflush()}'
    echo 1 > /proc/sys/vm/drop_caches
    if [ "$swapuse" != "off" ]; then
        if ! swapoff -v $blockname; then
            echo -e "\nWARNING: the on-line resize failed, reboot required"
            return 1
        fi
    fi
    swapusage
    zramctl -s $1 $blockname
    mkswap $blockname
    return 0
}

zram_swap_offload() {
    if [ "$swapuse" = "off" ]; then
        echo -e "\nWARNING: the swap is not active, nothing to do\n"
        return 1
    fi
    echo "Offloading the zRAM swap..."
    sleep 0.25; echo 1 > /proc/sys/vm/drop_caches
    if ! swapoff -v $blockname; then
        echo -e "\nWARNING: swapoff failed, aborting\n"
        return 1
    fi
    swapusage
    if ! swapon -v /dev/zram0; then
        echo -e "\nWARNING: swapon failed, aborting\n"
        return 1
    fi
    swapusage
}

swapusage() {
    free -m | grep -i swap | tr -s ' ' | sed "s,0 0 0,off,"
}

zram_swap_resize() {
    mb=$((${1:-1024} + 0))
    zramsize=$((mb*1024*1024))
    
    zram_swap_change $zramsize || resized=no
	
    echo -e "\nThe zram size at the next boot is set in $filename by this line"
    sed -i "s|\(^"$blockname".*size\)=[0-9]*,max|\\1="$((mb*1024*1024))",max|" \
        $filename
    grep zram $filename | tr -s ' '

    if [ "$resized" != "no" ]; then
        echo -e "\nEnabling the zRAM swap..."
        swapusage
        if ! swapon -v /dev/zram0; then
            echo -e "\nWARNING: swapon failed, aborting\n"
            return 1
        fi
        swapusage
    fi
    echo
}

sysmon_update() {
    return 0 # disabled because it does not work as expected
    kill $(pgrep harbour-systemmonitor) 2>/dev/null # wake-up/update
}

### MAIN SCRIPT SECTION ########################################################

swapuse=$(swapusage | awk '{ print $2 }')
printf "\nCurrent $(basename $blockname) swap size: %s Mb" $swapuse   
printf "\nCurrent swapiness index: %d%%\n\n" $(cat /proc/sys/vm/swappiness)               

mcetool_check
power_saving_state
if [ "$pwsvstate" = "enabled" ]; then
   power_saving_toggle enabled
   pwsvenagain=1
fi

if [ "$1" = "offload" ]; then
    zram_swap_offload
else
    zram_swap_resize $1
fi
sysmon_update

if [ "$pwsvenagain" = "1" ]; then
   power_saving_toggle disabled
fi
echo
