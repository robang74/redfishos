#!/bin/sh
# bash or ash is required but sh for universal compatibility.
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
#
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
# TODO
#
# Repository to add in combination or in alternative a CentOS 8 stream
#
# https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/31/
#	Everything/aarch64/os/ fedora-31-release-everything
#	Modular/aarch64/os/ fedora-31-release-modular
# https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/31/
#	Everything/aarch64/ fedora-31-updates-everything
#	Modular/aarch64/ fedora-31-updates-modular
#
################################################################################
# release: 0.1.5

if ! type get_this_shell_name 2>&1 | head -n1 | grep -q "is a function"; then
	shn=$(cat /proc/$$/cmdline | tr '\0' '\n' | grep -v busybox | head -n1)
	if [ -x "$shn" ]; then
		shx=$(basename "$shn")
		shn=$(readlink -f "$shn")
		shn=$(basename "$shn")
		if [ "$shn" = "busybox" ]; then
			shn=$shx
		fi
	fi
else
	shn=$(get_this_shell_name)
fi
echo
echo "Script running on shell: $shn"
echo
if [ "$shn" = "bash" -o "$shn" = "ash" ]; then
	:
elif [ "$shn" = "dash" ]; then
    echo "ERROR: this script cannot run on dash, abort."
    echo
    exit 1
else
	echo "WARNING: this script requires bash or ash or dash and may not work."
	echo
fi >&2

################################################################################
set -u

set_battery_lcr_params() {
	# RAF: this should be refresh each boot
	echo 1 >/sys/class/power_supply/battery_ext/lrc_enable
	echo 95 >/sys/class/power_supply/battery_ext/lrc_socmax
	echo 90 >/sys/class/power_supply/battery_ext/lrc_socmin
	echo 1 >/sys/class/power_supply/battery/lrc_enable
}

rpms_install() {
	test $# -ge 4 || return 1
	
	local filter_4="sed -ne 's/<solvable \(.*\)>/\1/p'"
	local filter_5="sed 's/$/;echo ${type:-} ${name:-} ${edition:-} installed/'"
	local dname="${1:-all}" dvern="${2:+ v$2}" rlist="${3:-}" opts ret str cmd
	local type name edition arch summary # because eval sovable defines these
	shift 3

#	echo
#	echo "=> Packages installation..."
	echo "  \_ Packages from ${dname}${dvern} repositiries:"
	opts=$(for i in $rlist; do echo "-r $i"; done)
	output=$(zypper $zopts -x install $opts -y "$@")
	ret=$?
	output=$(echo "$output" | eval "$filter_4")
	if [ -n "$output" ]; then
		cmd=$(echo "$output" | eval "$filter_5")
		eval "$cmd" | eval "$filter_b"
	fi

	pkgs=$(echo "$output" | sed -ne 's/.*name="\([^"]*\)" .*/\1/p')
	for i in "$@"; do
		echo "$pkgs" | grep -qe "^$i$" ||\
			echo "last version $i already installed" | eval "$filter_b"
	done

	str="KO"; test $ret -eq 0 && str="OK"
	echo "  \_ Installation status: $str"
}

repos_check(){
	local i avail
	echo "  \_ Repositories refresh and check, wait..."

	zypper $zopts refresh 2>&1 | eval $filter_3
	test "x${1:-$rcmode}" = "x--refresh-only" && return 0

	i="dnsmasq"; avail="enabled"
	zypper se -r $rpo -xn $i 2>&1 | grep -qi " $i " \
		|| avail="available but disabled"
	echo "Repository $rpo: $avail" | eval $filter_b

	i="cronie"; avail="enabled"
	zypper se -r ${cntos}-baseos -xn $i 2>&1 | grep -qi " $i " \
		|| avail="available but disabled"
	echo "Repository ${cntos}-baseos: $avail" | eval $filter_b

	i="bcc-tools"; avail="enabled"
	zypper se -r ${cntos}-appstream -xn $i 2>&1 | grep -qi " $i " \
		|| avail="available but disabled"
	echo "Repository ${cntos}-appstream: $avail" | eval $filter_b
}

system_timedate_sync() {
	test -n "$tserv" || return 1
	which sntp >/dev/null || return 1

	echo
	m=$((m+1))
	echo "=> $m. System time/date syncronisation"
	echo
	mkdir -p /var/lib/sntp
	touch /var/lib/sntp/kod
	sntp -4 $tserv 2>&1 | sed "s/ \($tserv\)/\n\\1/" | eval $filter_a
	n=$((n+1))
	sysdttm=1
	tserv=""
	return 0
}

printline() { printf -- "$1%.0s" $(seq 1 80); printf "\n"; }

rmme="" n=0 m=0 sysdttm=0 rmtdttm=0
rcmode="--refresh-only"
rfos_hostname="redfishos"
tref_filename="/etc/.time/.refernce"
zopts="--no-color -nq"
tserv="time.ien.it"

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

rpm_list_0_rmv="
busybox-symlinks-vi
busybox-symlinks-bash
"

rpm_list_0_add="
vim-minimal
gnu-bash
"

rpm_list_1="
pigz tcpdump bind-utils htop zypper zypper-aptitude rsync patch patchmanager
xz mce-tools sailfish-filemanager sailfish-filemanager-l10n-all-translations
sailfish-utilities usb-moded-connection-sharing-android-connman-config strace
sailfishos-chum-gui harbour-dool binutils
"

rpm_list_2="
gpstoggle harbour-file-browser harbour-todolist harbour-qrclip harbour-gpsinfo
"

rpm_list_3="cronie dnsmasq sntp"

#TODO: harbour-file-browser harbour-todolist harbour-qrclip harbour-gpsinfo
#      ofono ofono-binder-plugin ofono-modem-switcher-plugin 
#      ofono-vendor-qti-radio-plugin

filter_a="grep . | sed -e 's,^,\ \ \ ,'"
filter_b="grep . | sed -e 's,^,\ \ |\ \ ,'"
filter_c="grep -Ev 'Status:|Percentage:|Results:'"
filter_d="cut -d'[' -f1 | sed -e 's/No update candidate for \(.*\). The .*/'\
'The update for \1 is already installed./'"

filter_1="$filter_c | $filter_a | uniq"
filter_2="$filter_c | $filter_b | uniq"
filter_3="$filter_d | $filter_2"

runby=${2:+pcos:$2}
runby=${runby:-localhost}
echo "Shell script execution by $runby"
printline '-'
echo

m=$((m+1))
if [ -n "${1:-}" ]; then
	echo "=> $m. Updating date time from the pcos-host"
	echo "  \_ current date/time: $(TZ=UTC date '+%F %H:%M:%S') UTC"
	TZ=UTC date -s @"$1" >/dev/null
	echo "  \_ updated date/time: $(TZ=UTC date '+%F %H:%M:%S') UTC"
	tref_dir=$(dirname "$tref_filename")
	if [ ! -s "$tref_filename" ]; then
		mkdir -p "$tref_dir"
		echo "$1">"$tref_filename"
		chmod a-w "$tref_filename" "$tref_dir"
	fi
	rmtdttm=1
	sysdttm=1
	n=$((n+1))
else
	echo "=> $m. Printing date time from the localhost"
	echo "  \_ current date/time: $(TZ=UTC date '+%F %H:%M:%S') UTC"
fi

if [ -n "${4:-}" ]; then
	md5str=$(md5sum $0 | cut -d' ' -f1)
	m=$((m+1))
	echo
	echo "=> $m. Checking the MD5sum of the two scripts"
	echo "  \_ remote: $4"
	echo "  \_ locale: $md5str"
	if [ "$4" = "$md5str" ]; then
		echo "  \_ check : OK"
		n=$((n+1))
	else
		echo "  \_ check : KO"
		exit 1
	fi
fi

echo
m=$((m+1))
rfos_hostname=${3:-$rfos_hostname}
echo "=> $m. Refresh library cache and set the hostname: $rfos_hostname"
ldconfig
hostname "$rfos_hostname"
hostname  >/etc/hostname
n=$((n+1))

echo
m=$((m+1))
echo "=> $m. Internet connection verification"
icst=KO; curl -sL https://google.com/404 >/dev/null 2>&1 && icst=OK
echo "  \_ Internet connectivity: $icst"
n=$((n+1))

if [ "$icst" = "OK" ]; then # w/ internet ######################################

system_timedate_sync ||:

sha=devel
fle=rfos-suite-installer.sh
url=https://raw.githubusercontent.com/robang74/redfishos
url=$url/$sha/scripts/$fle

echo
m=$((m+1))
echo "=> $m. RedFish OS script suite install"
echo "  \_ Running the suite installer script, wait..."
if curl -sL $url | bash; then
	echo "$fle.OK" >&2
else
	echo "$fle.KO" >&2
fi 2>/tmp/$fle.err | eval $filter_2

if grep -q "$fle.OK" /tmp/$fle.err; then
	sret="OK"
	n=$((n+1))
else
	sret="KO"
fi
echo "  \_ Installation status: $sret"

else # no internet #############################################################

echo
m=$((m+1))
echo "=> $m. RedFish OS script suite install"
echo "  \_ Installation status: skipped, no Internet"
echo "  \_ Alternative install: TODO"

fi #############################################################################

echo
m=$((m+1))
echo "=> $m. Repositories selection and addition"
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

source /etc/os-release
arch=$(uname -m)
url="https://repo.sailfishos.org/obs/sailfishos:/chum"
url="${url}/${VERSION_ID}_${arch}/"
rpo="harbour-storeman-obs"
echo "  \_ Adding $rpo repository, wait..."
ssu addrepo $url $rpo 2>&1 | eval $filter_2

centos_repos=""
cntos="Centos/8-stream"
url="https://ftp.uni-bayreuth.de/linux" 			# backup
url="https://www.nic.funet.fi/pub/Linux/INSTALL"	# current
echo "  \_ Adding $cntos repositories, wait..."
for i in $cntos/BaseOS $cntos/AppStream; do
	ctrp=$(echo $i | tr / - | tr [A-Z] [a-z])
	ssu addrepo $url/$i/$arch/os/ $ctrp 2>&1 | eval $filter_2
	ssu enablerepo $ctrp 2>&1 | eval $filter_2
	centos_repos="$ctrp $centos_repos"
done
cntos=$(echo $cntos | tr / - | tr [A-Z] [a-z])
ssu updaterepos 2>&1 | eval $filter_2
repos_check
echo "  \_ Showing the repositories list:"
echo
ssu repos 2>&1 | sed -e "s,^,   ," -e "s,\(.*\) ... .*,\\1,"
n=$((n+1))

if [ "$icst" = "OK" ]; then # w/ internet ######################################

echo
m=$((m+1))
echo "=> $m. System packages install"
echo "  \_ This operation will take a minute, wait..."
if ! which zypper >/dev/null; then
	echo "  \_ Installing zypper, wait..."
	pkcon -py zypper --allow-reinstall 2>&1 | eval $filter_2
fi
if [ -n "$rpm_list_3" ]; then
	rpms_install "" "" "" $rpm_list_3
fi
n=$((n+1))

if ! system_timedate_sync; then
	if ! which sntp >/dev/null; then
		echo
		m=$((m+1))
		echo "=> $m. System time/date syncronisation"
		echo "  \_ System tool sntp is missing, skip."
	fi
fi

echo
m=$((m+1))
echo "=> $m. Installed packages update"
for i in $centos_repos; do ssu disablerepo $i; done
repos_check
if false; then
	pkcon -yp refresh 2>&1 | eval $filter_1
	pkcon -yp update  2>&1 | eval $filter_1
else
	zypper $zopts refresh 2>&1 | eval $filter_a
	zypper $zopts update  2>&1 | eval $filter_a
fi
str=KO; test $? -eq 0 && str=OK
echo "  \_ Update status: $str"
n=$((n+1))

echo
m=$((m+1))
echo "=> $m. Application packages install"
echo "  \_ Conflicting package removal"
if [ -n "$rpm_list_0_add" ]; then
	zypper $zopts remove -y $rpm_list_0_rmv 2>&1 | eval $filter_b
	rpm_list_1="$rpm_list_0_add $rpm_list_1"
fi
if [ -n "$rpm_list_1" ]; then
#	zypper $zopts install -y $rpm_list_1 $rpm_list_2 2>&1 | eval $filter_1
	rpms_install "" "" "" $rpm_list_1 $rpm_list_2
fi
n=$((n+1))

echo
m=$((m+1))
echo "=> $m. Updating CA-trust, wait..."
if update-ca-trust; then
	echo "  \_ update-ca-trust: OK"
else
	echo "  \_ update-ca-trust: KO"
fi
n=$((n+1))

else # no internet #############################################################

echo
m=$((m+1))
echo "=> $m. System packages install"
m=$((m+1))
echo "=> $m. Installed packages update"
m=$((m+1))
echo "=> $m. Application packages install"
m=$((m+1))
echo "=> $m. Updating CA-trust, wait..."
echo "  \_ Install status: skipped, no Internet"
echo "  \_ Alternative install: TODO"

fi #############################################################################


if which mcetool >/dev/null; then ##############################################

echo
m=$((m+1))
echo "=> $m. Enable auto-brightness"
echo
mcetool \
	--set-brightness-fade-dim=1000    \
	--set-brightness-fade-als=1000    \
	--set-brightness-fade-blank=1000  \
	--set-brightness-fade-unblank=150 \
	--set-als-autobrightness=enabled  \
	--set-brightness-fade-def=150
mcetool | grep -i brightness | sed -e "s,^,   ,"
n=$((n+1))

echo
m=$((m+1))
echo "=> $m. Set balanced-interactive governor"
echo
for i in /sys/devices/system/cpu/cpu?/cpufreq/scaling_governor; do
    echo "schedutil" >$i
done
mcetool -S interactive \
	--set-power-saving-mode=enabled \
	--set-low-power-mode=disabled   \
	--set-ps-on-demand=enabled      \
	--set-forced-psm=disabled       \
	--set-psm-threshold=100
mcetool | grep -iE "power|ps" | grep -v "dbus" | sed -e "s,^,   ,"
n=$((n+1))

echo
m=$((m+1))
echo "=> $m. Set battery charging thresholds"
echo
set_battery_lcr_params
mcetool \
	--set-forced-charging=disabled  \
	--set-charging-enable-limit=95  \
	--set-charging-disable-limit=90 \
	--set-charging-mode=apply-thresholds
mcetool | grep -i charging | eval $filter_1
n=$((n+1))

else # no mce-tools installed ##################################################

echo
m=$((m+1))
echo "=> $m. Enable auto-brightness"
m=$((m+1))
echo "=> $m. Set balanced-interactive governor"
m=$((m+1))
echo "=> $m. Set battery charging thresholds"
echo "  \_ Setting status: skipped, no mce-tools"

fi #############################################################################

echo
m=$((m+1))
echo "=> $m. Activate the /etc/rc.local by crontab"
if which crontab >/dev/null; then
	tmpfile=$(mktemp -p ${TMPDIR:-/tmp} -t crontab.XXXXXX)
	crontab -l >$tmpfile 2>/dev/null
	echo "@reboot test -x /etc/rc.local && /etc/rc.local" >>$tmpfile
	grep . $tmpfile | sort | uniq | crontab -
	if [ ! -x /etc/rc.local ]; then
		touch /etc/rc.local
		chmod a+x /etc/rc.local
	fi
	f="set_battery_lcr_params"
	if ! grep -q "$f" /etc/rc.local; then
		type $f | grep -v "$f is a function" >> /etc/rc.local
		echo $f >> /etc/rc.local
	fi
	crontab -l | eval $filter_1
	n=$((n+1))
else
	echo "  \_ Activation status: skipped, no crontab"
fi

echo
m=$((m+1))
echo "=> $m. System patches application, start"

if [ "$icst" = "OK" ]; then # w/ internet ######################################

export PATH=$HOME/bin:$PATH
source $HOME/bin/rfos-script-functions.env
if [ $? -eq 0 ]; then
	printline '-'
	if patch_installer.sh --all; then
		n=$((n+1))
		printline '-'
		echo "=> $m. System patches application, end"
		echo "  \_ Install status: OK"
	else
		printline '-'
		echo "=> $m. System patches application, end"
		echo "  \_ Install status: KO"
	fi
else
	echo "  \_ Install status: KO, no functions"
fi

else # no internet #############################################################

echo "  \_ Install status: skipped, no Internet"
echo
echo "=> $m. Create $HOME/bin and replicate me there"
rmme="$0"
mkdir -p $HOME/bin
cp -arf $0 $HOME/bin 2>/dev/null || rmme=""

fi #############################################################################

test "$rmtdttm" = "0" -a "$sysdttm" = "1" && n=$((n+1))

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
afish getip

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
	sfish /bin/ash $setup_name $dttmsc $usrstr $rfos_hostname $md5str
fi

fi #############################################################################
