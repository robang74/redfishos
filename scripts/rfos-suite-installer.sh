#!/bin/sh
# bash or ash or dash is required but sh for universal compatibility.
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
# release: 0.1.8

set -ue

# FUNTIONS DEFINITIONS #########################################################

isafunc() {
    test -n "${1:-}" || return 1
    type $1 2>&1 | head -n1 | grep -q "is a function"
}

errexit() {
    if [ -n "${1:-}" ]; then
        echo
        echo "ERROR: $@"
        echo
    fi >&2
    exit 1
}

download() {
    test -n "${2:-}" || return 1
    if which wget >/dev/null; then
        wget $1 -qO - >$2.tmp
    elif which curl >/dev/null; then
        curl -sL $1 >$2.tmp
    else
        return 1
    fi
    if [ $? -eq 0 -a -s $2.tmp ]; then
        mv -f $2.tmp $2
        sync $2
    else
        rm -f $2.tmp
        return 1
      fi
      return 0
}

blankline() { touch "$1" && tail -n1 "$1" | grep -q . && echo >> "$1" ||:; }

shellname() {
    local shn shx m
    shn=$(cat /proc/$$/cmdline | tr '\0' '\n' | grep -v busybox | head -n1)
    m=$(printf "%c" "$shn")
    if [ "x$m" = "x-" ]; then
        shn=$(printf "%s" "$shn" | cut -d- -f2-)
    else
        m=""
    fi
    if [ -x "$shn" ]; then
        shx=$(basename "$shn")
        shn=$(readlink -f "$shn")
        shn=$(basename "$shn")
        if [ "$shn" = "busybox" ]; then
            shn=$shx
        fi
    fi
    echo $m$shn
}

check_running_shell() {
    local shn=$(shellname) m
    echo "Script ${1:+$1 }running on shell: $shn"
    if printf "%c" "$shn" | grep -q '-'; then
        shn=$(printf "%s" "$shn" | cut -d- -f2-)
    fi
    if [ "$shn" = "dash" -o "$shn" = "bash" -o "$shn" = "ash" ]; then
        if [ "$shn" = "${2:-}" ]; then
            echo
            echo "ERROR: this script cannot run on $2, abort."
            echo
            exit 1
        fi >&2
    else
    (>&2 # RAF: this flush the stderr because the exit of the child process
        echo
        echo "WARNING: this script requires b/d/ash to run correctly."
        echo
    )
    fi
}

# FUNCTIONS OVERLOAD ###########################################################
#
# RAF: this script also defines the functions environment, which can be broken
#      for some reasons. Hence, it is not a good idea to source from outside but
#      to keep everything running from this own script, which can be entirely
#      downloaded and executed with a single wget/curl | b/ash command.
#      Instead, for the same reason the local enviroment could be fixed by hands
#      but this script functions can be still broken and ENVLOAD=1 saves us.
#
if [ ${ENVLOAD:-0} -eq 1 ]; then
    zadir=$(dirname "$0"  ||:)
    funcenv="rfos-script-functions.env"
    source "${zadir:-.}/$funcenv" ||\
        source "$HOME/bin/$funcenv" ||:
fi 2>/dev/null

# SHELL TEST ###################################################################

echo
check_running_shell

# VARIABLES DEFINITIONS ########################################################

branch="devel"
branch="${1:-$branch}"
url="https://raw.githubusercontent.com/robang74/redfishos/$branch"
dir=$HOME/bin

rfos=$(cd /etc && egrep -i "[sail|red]fish" *-release issue group passwd ||:)
if [ "$rfos" != "" ]; then ## ------------------------------------------ rfos ##
echo "Script running on mobile device"
scripts_list="
sfos/patch_dblock_functions.env
sfos/patch_installer.sh
sfos/patch_downloader.sh
sfos/setnet_postroute.sh
sfos/zram_swap_resize.sh
rfos-script-functions.env
rfos-suite-installer.sh
rfos-first-setup.sh
"
else ## ---------------------------------------------------------------- pcos ##
echo "Script running on a workstation"
scripts_list="
pcos/fastboot-usb3fix.sh
pcos/sfos-ssh-connect.env
rfos-script-functions.env
rfos-suite-installer.sh
rfos-first-setup.sh
"
fi ## ----------------------------------------------------------------------- ##

# MAIN CODE EXECUTION ##########################################################

hme=$(printf "$dir" | sed -e "s,$HOME/,~,")
brn=$(printf "$branch" | head -c6)
envirm=""

echo
mkdir -p $dir || errexit "cannot create '$dir' folder, abort."
for i in $scripts_list; do
    dst=$dir/$(basename $i)
    printf "Downloading from %s to %s: %-32s ..." $brn $hme $i
    rm -f $dst
    if ! download $url/scripts/$i $dst; then
         echo " ko"
         errexit "cannot download $i, abort."
    fi
    echo " ok"
    if echo "$i" | grep -q "\.sh$"; then
        chmod a+x $dst || errexit "cannot chmod +x $dst, abort."
    fi
done

for shellrc in $HOME/.profile $HOME/.bashrc; do
    blankline "$shellrc"
    for i in $scripts_list; do
        dst=$dir/$(basename $i)
        if echo "$i" | grep -q "\.env$"; then
            grep -q "source $dst" "$shellrc" ||\
                echo "source $dst" >> "$shellrc"
        fi
    done
    if ! grep -qe "export PATH=.*:$HOME/bin" "$shellrc"; then
        echo 'export PATH=$PATH':$HOME/bin >> "$shellrc"
    fi
    echo $shellrc | grep -q "bashrc" && \
        grep -q "export -f src_file_env" "$shellrc" ||\
            echo "export -f src_file_env" >> "$shellrc"
    blankline "$shellrc"
    envirm="$shellrc ${envirm:-}"
done

echo
echo "DONE: scripts suite for RedFish OS, installed in"
echo "      folder    : $dir"
echo "      enviroment: $envirm"

devprfl="/usr/libexec/openssh/load_developer_profile"
if [ -e "$devprfl" ]; then
    if ! grep -q '. ~/.profile' "$devprfl"; then
        echo '. ~/.profile' >>"$devprfl"
    fi 2>/dev/null
    echo "      enviroment: $devprfl"
fi

echo
echo "Please, (re)execute bash to load its enviroment, then"
echo "      rfos-first-setup.sh"
echo "to start the RedFish OS first boot setup procedure"
echo
