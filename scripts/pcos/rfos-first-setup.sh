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
# release: 0.0.6

# WARNING NOTE
#
# These `adaptation0`, `aliendalvik`, `sailfish-eas` and `xt9` repositories are
# enabled by default, but it is wrong because they can be refreshed only when
# the device has a Jolla account. Otherwise, a relative long timeout for each of
# them keeps the refresh procedure stuck. Therefore, the Jolla account creation
# and deletion actions must take care of enabling and disabling them, which must
# be set as disabled by default. Until this fix will be implemented and provided
# this script deal with this aspect enabling or disabling those repositories.
#
################################################################################

set -u
rfos_hostname="redfishos"

rfos=$(cd /etc && egrep -i "sailfish|redfish" *-release mtab issue group passwd)
if [ "$rfos" != "" ]; then ## pcos #############################################

test -n "${2:-}" || exit 1

rpm_list_1="
pigz tcpdump bind-utils htop vim-minimal zypper zypper-aptitude rsync patch
xz mce-tools sailfish-filemanager sailfish-filemanager-l10n-all-translations
"

# ofono ofono-binder-plugin ofono-modem-switcher-plugin ofono-vendor-qti-radio-plugin

#TODO: harbour-file-browser harbour-todolist harbour-qrclip harbour-gpsinfo
rpm_list_2="gpstoggle"

echo
echo shell script execution by pcos${1:+:$1}
echo ---------------------------------------
echo "=> Updating date time from the host"
echo "\_ current date/time: $(TZ=UTC date '+%F %H:%M:%S') UTC"
TZ=UTC date -s @"$2"
echo "\_ updated date/time: $(TZ=UTC date '+%F %H:%M:%S') UTC"
mkdir -p /etc/.time/
touch /etc/.time/.refernce
chmod a-w /etc/.time/.refernce
echo
echo "=> Refresh library cache and set the hostname: $3"
ldconfig
hostname "$rfos_hostname"
hostname  >/etc/hostname
echo
echo "=> Repository selection"
echo "   \_this operation will take a minute, wait..."
repo_list='adaptation0 aliendalvik sailfish-eas xt9'
if ssu repos | grep -q "[ -]* store ..."; then
	echo "   \_jolla store: found, enabling all repositories..."
	for i in $repo_list; do ssu enablerepo $i; done
	ssu_status="Jolla"
else
	echo "   \_jolla store: not found, disabling some repositories..."
	for i in $repo_list; do ssu disablerepo $i; done
	ssu_status="Linux"
    rpm_list_2=""
fi
echo; ssu repos

echo
echo "=> Repository and packages update"
echo "   \_this operation will take a minute, wait..."
echo
ssu updaterepos
pkcon -yp refresh 2>&1 | grep -v Status | sed -e "s,^,   ,"
pkcon -yp update  2>&1 | grep -v Status | sed -e "s,^,   ,"

echo
echo "=> Packages installation"
echo

if [ -n "$rpm_list_1" ]; then
	rpm -qi busybox-symlinks-vi 2>&1 | grep -q "not installed" ||\
		pkcon -yp remove busybox-symlinks-vi 2>&1 | grep -v Status
	pkcon -yp install --allow-reinstall $(echo $rpm_list_1 $rpm_list_2) \
        2>&1 | grep -v Status | sed -e "s,^,   ,"
fi

echo
echo "=> Enable auto-brightness"
echo

mcetool \
--set-brightness-fade-dim=1000 \
--set-brightness-fade-als=1000 \
--set-brightness-fade-blank=1000 \
--set-brightness-fade-unblank=150 \
--set-als-autobrightness=enabled \
--set-brightness-fade-def=150

mcetool | grep -i brightness | sed -e "s,^,   ,"

echo
echo "=> Set balanced-interactive governor"
echo

for i in /sys/devices/system/cpu/cpu?/cpufreq/scaling_governor; do
    echo "schedutil" >$i
done
mcetool -S interactive \
	--set-power-saving-mode=enabled \
	--set-low-power-mode=disabled \
	--set-ps-on-demand=enabled \
	--set-forced-psm=disabled \
	--set-psm-threshold=100

mcetool | grep -iE "power|ps" | grep -v "dbus" | sed -e "s,^,   ,"

echo
echo "=> Initial setup of a $ssu_status device completed."
echo

else ## pcos ###################################################################

bsfish() { ssh_opts="$ssh_opts -o BatchMode=yes" sfish "$@"; }

spcmd=""
set_key_login="no"

set -em
src_file_env "sfos-ssh-connect"
echo; afish getip

if [ "x${1:-}" = "x--key-login" ]; then
	set_key_login="yes"
else
	bsfish "echo 'root password-less access: OK'" 2>/dev/null \
		|| set_key_login="yes"
fi

if [ "$set_key_login" = "yes" ]; then
	if [ ! -s ~/.ssh/id_rsa.pub ]; then
		ssh-keygen -t rsa -b 4096 -C "$(whoami)@rfos.local"
	fi
	if which sshpass >/dev/null; then
		IFS= read -s -p 'Using sshpass, RFOS password: ' passwd; echo
		spcmd="sshpass -p '$passwd'"
		passwd=""
	fi
	hostnm="defaultuser@$sfos_ipaddr"
	$spcmd ssh-copy-id -fi ~/.ssh/id_rsa.pub $hostnm
	$spcmd ssh $hostnm devel-su install -Dpo root -g root \
		-m 600 -t '~root/.ssh/ ~defaultuser/.ssh/auth*keys'
	spcmd=""
	sfish "echo 'PermitRootLogin without-password' >> /etc/ssh/sshd_config;" \
	      "echo 'root password-less access: OK'"
fi

setup_file=$0
setup_name=$(basename $setup_file)

echo
echo '=> Script transfer'
echo
echo "pcos: $(md5sum $setup_file)"

if scp $setup_file root@$sfos_ipaddr:~ >/dev/null; then
	sfish 'echo rfos: $(md5sum '$setup_name'); /bin/bash '$setup_name \
        $(whoami) $(TZ=UTC date "+%s") $rfos_hostname
fi

fi #############################################################################
