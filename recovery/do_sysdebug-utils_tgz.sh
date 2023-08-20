#!/bin/bash
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released under the GPLv2 license terms.
#
################################################################################
# release: 0.0.2

set -e

# VARIABLES DEFINITION #########################################################

tar_dir="etc bin usr var"
name="sysdebug-utils"
tgz="$name.tar.gz"
dir="$name.dir"

url_1="https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/"
rpm_list_1="
strace-5.7-3.el8.aarch64.rpm
libaio-0.3.112-1.el8.aarch64.rpm
traceroute-2.1.0-6.el8.aarch64.rpm
libunistring-0.9.9-3.el8.aarch64.rpm
elfutils-libs-0.185-1.el8.aarch64.rpm
elfutils-libelf-0.185-1.el8.aarch64.rpm
keyutils-libs-1.5.10-9.el8.aarch64.rpm
lksctp-tools-1.0.18-3.el8.aarch64.rpm
libatomic-8.5.0-4.el8_5.aarch64.rpm
krb5-libs-1.18.2-14.el8.aarch64.rpm
libxcrypt-4.1.1-6.el8.aarch64.rpm
libverto-0.3.0-5.el8.aarch64.rpm
json-c-0.13.1-2.el8.aarch64.rpm
libidn2-2.2.0-1.el8.aarch64.rpm
"

url_2="https://vault.centos.org/centos/8/AppStream/aarch64/os/Packages/"
rpm_list_2="
tcpdump-4.9.3-2.el8.aarch64.rpm
nmap-ncat-7.70-6.el8.aarch64.rpm
bind-libs-9.11.26-6.el8.aarch64.rpm
bind-utils-9.11.26-6.el8.aarch64.rpm
compat-openssl10-1.0.2o-3.el8.aarch64.rpm
bind-libs-lite-9.11.26-6.el8.aarch64.rpm
libmaxminddb-1.2.0-10.el8.aarch64.rpm
protobuf-c-1.3.0-6.el8.aarch64.rpm
fstrm-0.6.1-2.el8.aarch64.rpm
"

url_3="http://mirror.centos.org/altarch/7/os/aarch64/Packages/"
rpm_list_3="
ntpdate-4.2.6p5-29.el7.centos.2.aarch64.rpm
"

url_4="https://dl.fedoraproject.org/pub/epel/8/Everything/aarch64/Packages/"
rpm_list_4="
arp-scan-1.10.0-1.el8.aarch64.rpm
"

url_5="http://mirror.centos.org/centos/8-stream/AppStream/aarch64/os/Packages/"
rpm_list_5="
stress-ng-0.15.00-1.el8.aarch64.rpm
Judy-1.0.5-18.module_el8.5.0+728+80681c81.aarch64.rpm
"

# PACKAGES PROVIDING ###########################################################

echo "This script requires the root priviledges"
mkdir -p $dir && cd $dir && sudo rm -rf $tar_dir

if [ "x$1" = "x--no-download" ]; then shift
else #==========================================================================

for i in $rpm_list_1; do wget -c $url_1/$i; done

for i in $rpm_list_2; do wget -c $url_2/$i; done

for i in $rpm_list_3; do wget -c $url_3/$i; done

for i in $rpm_list_4; do wget -c $url_4/${i:0:1}/$i; done

for i in $rpm_list_5; do wget -c $url_5/$i; done

fi #============================================================================

for i in $rpm_list_1 $rpm_list_2 $rpm_list_3 $rpm_list_4 $rpm_list_5; do
    rpm2cpio $(basename $i) | sudo cpio -idmu -R root.root
done; echo

# PACKAGES MANAGEMENT ##########################################################

bin_excl="
nsupdate arpaname mmdblookup dnstap-read named-compilezone ddns-confgen
genrandom named-checkzone nsec3hash isc-hmac-fixup delv tsig-keygen
arp-fingerprint get-iab get-oui
"

usr_excl="man locale licenses"

sudo tar cvzf ../$tgz --exclude="usr/lib/.build-id" --exclude="usr/share/doc" \
    $(for i in $usr_excl; do echo --exclude="usr/share/$i"; done;
      for i in $bin_excl; do echo --exclude={,usr/}*bin/$i; done;) \
    --exclude="usr/sbin/dns*" $(find ./ ! -name \*.rpm -maxdepth 1|cut -d/ -f2-)
cd ..

sudo chown -R $USER.$USER $tgz
echo; du -ks $tgz | tr '\t' ' '

if [ "x$1" = "x--ssh-test" ]; then shift #======================================

pcos_source_env() {
    local srcfile="$(dirname $0)/$1.env"
    if [ ! -r "$srcfile" ]; then
        srcfile="/usr/bin/$1.env"
    fi
    if [ ! -r "$srcfile" ]; then
        echo
        echo "ERROR: $1.env not found, abort."
        echo
        return 1
    fi >&2
    source $1.env
}

pcos_source_env do_ssh_ldd_test_utils

echo; afish getip

scp $tgz root@${sfos_ipaddr}:/tmp;

tmpf=$(mktemp -p ${TMPDIR:-/tmp} -t lddout.XXXX)
ldpath="/tmp/tb/lib:/tmp/tb/lib64:/tmp/tb/usr/lib:/tmp/tb/usr/lib64"
ldpath="$ldpath:/tmp/tb/usr/local/lib:/tmp/tb/usr/local/lib64"
sfish 'cd /tmp; rm -rf tb; mkdir -p tb; tar xzf '$tgz' -C tb; export'\
' LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-/tmp/tb}:'$ldpath'; { find tb -type f |'\
' xargs ldd; } 2>&1 | egrep ":|found" | grep -v "warning:"' >$tmpf

if grep -q "found" $tmpf; then
    echo -e "\nldd check: KO\n"
    cat $tmpf
    echo
else
    echo -e "\nldd check: OK\n"
fi
rm -f $tmpf

fi #============================================================================
