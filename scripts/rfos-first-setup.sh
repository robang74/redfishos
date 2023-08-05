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
# release: 0.1.0

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

rmme="" n=0 m=0
rfos_hostname="redfishos"
tref_filename="/etc/.time/.refernce"

rfos=$(cd /etc && egrep -i "[sail|red]fish" *-release issue group passwd ||:)
if [ "$rfos" != "" ]; then ## rfos #############################################

if [ -s "$tref_filename" ]; then
	:
elif [ ! -n "${1:-}" ]; then
	echo
	echo "ERROR: file '$tref_filename' or data/time needed, abort."
	echo
	exit 1
fi

rpm_list_0="
busybox-symlinks-vi
busybox-symlinks-bash
"

rpm_list_1="
pigz tcpdump bind-utils htop vim-minimal zypper zypper-aptitude rsync patch
xz mce-tools sailfish-filemanager sailfish-filemanager-l10n-all-translations
sailfish-utilities usb-moded-connection-sharing-android-connman-config strace
gnu-bash
"

rpm_list_2="gpstoggle"

#TODO: harbour-file-browser harbour-todolist harbour-qrclip harbour-gpsinfo
#      ofono ofono-binder-plugin ofono-modem-switcher-plugin 
#      ofono-vendor-qti-radio-plugin

filter="grep -Ev 'Status:|Percentage:|Results:'"
filter="$filter | sed -e 's,^,\ \ \ ,' | uniq"

echo
runby=${2:+pcos:$2}
runby=${runby:-localhost}
echo shell script execution by $runby
echo "---------------------------------------"
echo

m=$((m+1))
if [ -n "${1:-}" ]; then
	echo "=> Updating date time from the pcos-host"
	echo "  \_ current date/time: $(TZ=UTC date '+%F %H:%M:%S') UTC"
	TZ=UTC date -s @"$1" >/dev/null
	echo "  \_ updated date/time: $(TZ=UTC date '+%F %H:%M:%S') UTC"
	tref_dir=$(dirname "$tref_filename")
	if [ ! -s "$tref_filename" ]; then
		mkdir -p "$tref_dir"
		echo "$1">"$tref_filename"
		chmod a-w "$tref_filename" "$tref_dir"
	fi
	n=$((n+1))
else
	echo "=> Printing date time from the localhost"
	echo "  \_ current date/time: $(TZ=UTC date '+%F %H:%M:%S') UTC"
fi

if [ -n "${4:-}" ]; then
	md5str=$(md5sum $0 | cut -d' ' -f1)
	echo
	echo "=> Checking the MD5sum of the two scripts"
	echo "  \_ remote: $4"
	echo "  \_ locale: $md5str"
	if [ "$4" = "$md5str" ]; then
		echo "  \_ check : OK"
	else
		echo "  \_ check : KO"
		exit 1
	fi
fi

echo
rfos_hostname=${3:-$rfos_hostname}
echo "=> Refresh library cache and set the hostname: $rfos_hostname"
ldconfig
hostname "$rfos_hostname"
hostname  >/etc/hostname
m=$((m+1))
n=$((n+1))

echo
echo "=> Internet connection verification"
icst=KO; curl -sL https://google.com/404 >/dev/null 2>&1 && icst=OK
echo "  \_ Internet connectivity: $icst"

echo
echo "=> RFOS script suite install"
m=$((m+1))

if [ "$icst" = "OK" ]; then # w/ internet ######################################

sha=devel
fle=rfos-suite-installer.sh
url=https://raw.githubusercontent.com/robang74/redfishos
url=$url/$sha/scripts/$fle

echo "  \_ Starting the script {} wait..."
rsst=/tmp/1stup.fifo; rm -f $rsst; mkfifo $rsst; {
 	set -mo pipefail
	exec 2>/dev/null
	{ wget $url -qO - || curl -sL $url; } | bash | grep . | sed -e "s,^,  | ,"
	{ if [ $? -eq 0 ]; then echo OK; else echo KO; fi >$rsst; } &
}  
disown &>/dev/null
echo "  \_ Reading the fifo..."
read sret < $rsst; rm -f $rsst
echo "  \_ Installation status: $sret"
test "$sret" = "OK" && n=$((n+1))

else # no internet #############################################################

echo "  \_ Installation status: skipped, no Internet"
echo "  \_ Alternative install: TODO"

fi #############################################################################

echo
echo "=> Repository selection"
echo "  \_ This operation will take a minute, wait..."
repo_list='adaptation0 aliendalvik sailfish-eas xt9'
if ssu repos | grep -q "[ -]* store ..."; then
	echo "  \_ Jolla store: found, enabling all repositories..."
	for i in $repo_list; do ssu enablerepo $i; done
	ssu_status="Jolla"
else
	echo "  \_ Jolla store: not found, disabling some repositories..."
	for i in $repo_list; do ssu disablerepo $i; done
	ssu_status="Linux"
    rpm_list_2=""
fi
echo; ssu repos 2>&1 | sed -e "s,^,   ," -e "s,\(.*\) ... .*,\\1,"
m=$((m+1))
n=$((n+1))

echo
echo "=> Repository and packages update"
m=$((m+3))

if [ "$icst" = "OK" ]; then # w/ internet ######################################

echo "  \_ This operation will take a minute, wait..."
echo
#ssu updaterepos
zypper refresh  2>&1 | eval $filter
#pkcon -yp refresh 2>&1 | eval $filter
pkcon -yp update  2>&1 | eval $filter
n=$((n+1))

echo
echo "=> Packages installation"
echo

if [ -n "$rpm_list_1" ]; then
    for i in $rpm_list_0; do
        #RAF: no pipefail here
        { rpm -qi $i 2>&1 ||:; } | grep -q "not installed" \
            || pkcon -yp remove $i 2>&1 | eval $filter
    done
	pkcon -yp install --allow-reinstall $rpm_list_1 $rpm_list_2 \
        2>&1 | eval $filter
fi
n=$((n+1))

echo
echo "=> Updating CA-trust, wait..."
if update-ca-trust; then
	echo "  \_ update-ca-trust: OK"
else
	echo "  \_ update-ca-trust: KO"
fi
n=$((n+1))

else # no internet #############################################################

echo "=> Packages installation"
echo "  \_ Install status: skipped, no Internet"
echo "  \_ Alternative install: TODO"

fi #############################################################################

m=$((m+3))
if which mcetool >/dev/null; then ##############################################

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
n=$((n+1))

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
n=$((n+1))

echo
echo "=> Set battery charging thresholds"
echo

mcetool \
	--set-forced-charging=disabled  \
	--set-charging-enable-limit=95  \
	--set-charging-disable-limit=90 \
	--set-charging-mode=apply-thresholds

mcetool | grep -i charging | sed -e "s,^,   ,"
n=$((n+1))

else # no mce-tools installed ##################################################

echo
echo "=> Enable auto-brightness"
echo "=> Set balanced-interactive governor"
echo "=> Set battery charging thresholds"
echo "  \_ Setting status: skipped, no mce-tools"

fi #############################################################################

if [ "$icst" = "OK" ]; then # w/ internet ######################################
	:
else # no internet #############################################################

echo
echo "=> Create $HOME/bin and replicate me there"
rmme="$0"
mkdir -p $HOME/bin
cp -arf $0 $HOME/bin 2>/dev/null || rmme=""

fi #############################################################################

echo
echo "=> Initial setup of a $ssu_status mobile device completed."
echo "  \_ Task completed: $n of $m"
echo

rm -f "$rmme"; exit 0
else ## pcos ###################################################################

bsfish() { ssh_opts="$ssh_opts -o BatchMode=yes" sfish "$@"; }

spcmd=""
set_key_login="no"

if [ "$(dirname $0)" = "." -a ! -e "$0" ]; then
	setup_file=$(which $0)
else
	setup_file=$0
fi
if [ ! -e "$setup_file" ]; then
	echo
	echo "ERROR: file '$setup_file' not found, abort."
	echo
	exit 1
fi
setup_name=$(basename $setup_file)

set -em
src_file_env "sfos-ssh-connect"
echo; afish getip

if [ "x${1:-}" = "x--key-login" ]; then
	set_key_login="yes"
else
	bsfish "echo 'root password-less login: OK'" 2>/dev/null \
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

echo
echo '=> Script SSH transfer'
if scp $setup_file root@$sfos_ipaddr:~ >/dev/null; then
	usrstr=$(whoami)
	md5str=$(md5sum $setup_file | cut -d' ' -f1)
	dttmsc=$(TZ=UTC date "+%s")
	sfish /bin/bash $setup_name $dttmsc $usrstr $rfos_hostname $md5str
fi

fi #############################################################################
