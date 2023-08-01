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
# release: 0.0.2

sfos=$(cd /etc && egrep -i "sailfish|redfish" *-release mtab issue group passwd)
if [ "$sfos" != "" ]; then ## pcos #############################################

test -n "${2:-}" || exit 1

rpm_list_1="
pigz tcpdump bind-utils htop vim-minimal harbour-gpsinfo zypper zypper-aptitude
mce-tools sailfish-filemanager xz sailfish-filemanager-l10n-all-translations
rsync patch
"
rpm_list_2="" #"harbour-file-browser harbour-todolist harbour-qrclip"
sfos_hostname="redfishos"

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
hostname "$sfos_hostname"
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
    rpm_list_2=''
fi
echo; ssu repos

echo
echo "=> Repository and packages update"
echo "   \_this operation will take a minute, wait..."
echo
ssu updaterepos
pkcon -yp refresh
pkcon -yp update

echo
echo "=> Packages installation"
echo

if [ -n "$rpm_list_1" ]; then
	rpm -qi busybox-symlinks-vi | grep -q "not installed$" ||\
		pkcon -yp remove busybox-symlinks-vi
	pkcon -yp install --allow-reinstall $(echo $rpm_list_1 $rpm_list_2)
fi

echo
echo "=> Initial setup of a $ssu_status device completed."
echo

else ## pcos ###################################################################

bsfish() { ssh_opts="$ssh_opts -o BatchMode=yes" sfish "$@"; }

spcmd=""
set_key_login="no"

# ofono ofono-binder-plugin ofono-modem-switcher-plugin ofono-vendor-qti-radio-plugin

srcfile="$(dirname $0)/sfos-ssh-connect.env"
if [ ! -r "$srcfile" ]; then
	srcfile="/usr/bin/sfos-ssh-connect.env"
fi
if [ ! -r "$srcfile" ]; then
	echo
	echo "ERROR: sfos-ssh-connect.env not found, abort."
	echo
fi

source $srcfile
echo; afish getip

if [ "x${1:-}" = "x--key-login" ]; then
	set_key_login="yes"
else
	bsfish "echo 'root password-less access: OK'" 2>/dev/null \
		|| set_key_login="yes"
fi

if [ "$set_key_login" = "yes" ]; then
	if [ ! -s ~/.ssh/id_rsa.pub ]; then
		ssh-keygen -t rsa -b 4096 -C "$(whoami)@sfos.local"
	fi
	if which sshpass >/dev/null; then
		IFS= read -s -p 'Using sshpass, SFOS password: ' passwd; echo
		spcmd="sshpass -p '$passwd'"
		passwd=""
	fi
	target="defaultuser@$sfos_ipaddr"
	$spcmd ssh-copy-id -fi ~/.ssh/id_rsa.pub $target
	$spcmd ssh $target devel-su install -Dpo root -g root \
		-m 600 -t '~root/.ssh/ ~defaultuser/.ssh/auth*keys'
	spcmd=""
	sfish "echo 'PermitRootLogin without-password' >> /etc/ssh/sshd_config;" \
	      "echo 'root password-less access: OK'"
fi

setup_file=$0

echo
echo '=> Script transfer'
echo
echo "pcos: $(md5sum $setup_file)"

if scp $setup_file root@$sfos_ipaddr:$setup_file >/dev/null; then
	sfish "echo 'sfos: $(md5sum $setup_file)'; /bin/bash $setup_file" \
" $(whoami) $(TZ=UTC date "+%s") $sfos_hostname;"
fi

fi #############################################################################

