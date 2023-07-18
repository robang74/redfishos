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
# release: 0.0.1

bsfish() { ssh_opts="$ssh_opts -o BatchMode=yes" sfish "$@"; }

spcmd=""
set_key_login="no"
sfos_hostname="redfishos"
setup_file="/tmp/initial.setup"
rpm_list="
rpm pigz xz bind-utils htop vim-minimal harbour-gpsinfo zypper zypper-aptitude
mce-tools harbour-file-browser harbour-todolist sailfish-filemanager tcpdump
sailfish-filemanager-l10n-all-translations harbour-qrclip patch
"

# ofono ofono-binder-plugin ofono-modem-switcher-plugin ofono-vendor-qti-radio-plugin

rm -f $setup_file
if [ -e $setup_file ]; then
	echo
	echo "ERROR: $setup_file exists but it should not, abort"
	echo
	exit 1
fi

source /usr/bin/sfos-ssh-connect.env
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

echo "
echo
echo shell script execution by pcos:$(whoami)
echo ---------------------------------------
echo '=> Refresh library cache and set the hostname: $sfos_hostname'
ldconfig
hostname $sfos_hostname
hostname >/etc/hostname

echo
echo '=> Repository selection'
echo '   \_this operation will take a minute, wait...'
echo
ssu status | tee /tmp/ssu.status
repo_list='adaptation0 aliendalvik sailfish-eas xt9'
if grep -q 'status: not registered' /tmp/ssu.status; then
	for i in $repo_list; do ssu disablerepo $i; done
else
	for i in $repo_list; do ssu enablerepo $i; done
fi
rm -f /tmp/ssu.status
ssu repos

echo
echo '=> Repository and packages update'
echo '   \_this operation will take a minute, wait...'
echo
ssu updaterepos
pkcon -yp refresh
pkcon -yp update

echo
echo '=> Packages installation'
echo
pkcon -yp remove busybox-symlinks-vi
pkcon -yp install --allow-reinstall $(echo $rpm_list)

echo
echo '=> Initial setup completed, end.'
echo
" >$setup_file

echo
echo '=> Script transfer'
echo
echo "pcos: $(md5sum $setup_file)"

if scp $setup_file root@$sfos_ipaddr:$setup_file >/dev/null; then
	sfish "echo 'sfos: $(md5sum $setup_file)';
		/bin/bash $setup_file; 
		rm -f '$setup_file'"
fi
rm -f $setup_file

