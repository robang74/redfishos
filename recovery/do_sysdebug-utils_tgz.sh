#!/bin/bash

tar_dir="etc bin usr var"
name="sysdebug-utils"
tgz="$name.tar.gz"
dir="$name.dir"

url_1="https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/"
rpm_list_1="
strace-5.7-3.el8.aarch64.rpm
traceroute-2.1.0-6.el8.aarch64.rpm
libunistring-0.9.9-3.el8.aarch64.rpm
elfutils-libs-0.185-1.el8.aarch64.rpm
elfutils-libelf-0.185-1.el8.aarch64.rpm
keyutils-libs-1.5.10-9.el8.aarch64.rpm
krb5-libs-1.18.2-14.el8.aarch64.rpm
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

set -e
mkdir -p $dir && cd $dir && sudo rm -rf $tar_dir

if [ "x$1" = "x--no-download" ]; then shift
else #==========================================================================

for i in $rpm_list_1; do wget -c $url_1/$i; done

for i in $rpm_list_2; do wget -c $url_2/$i; done

for i in $rpm_list_3; do wget -c $url_3/$i; done

for i in $rpm_list_4; do wget -c $url_4/${i:0:1}/$i; done

fi #============================================================================ 

for i in $rpm_list_1 $rpm_list_2 $rpm_list_3 $rpm_list_4; do
	rpm2cpio $(basename $i) | sudo cpio -idmu -R root.root
done; echo

bin_excl="
nsupdate arpaname mmdblookup dnstap-read named-compilezone ddns-confgen
genrandom named-checkzone nsec3hash isc-hmac-fixup delv tsig-keygen
arp-fingerprint get-iab get-oui
"

usr_excl="man locale licenses"

sudo tar cvzf ../$tgz --exclude="usr/lib/.build-id" --exclude="usr/share/doc" \
	$(for i in $usr_excl; do echo --exclude="usr/share/$i"; done;
	  for i in $bin_excl; do echo --exclude={,usr/}*bin/$i; done;) \
	--exclude="usr/sbin/dns*" $(ls -1d $tar_dir 2>/dev/null)
cd ..

sudo chown -R $USER.$USER $tgz
echo; du -ks $tgz | tr '\t' ' '

if [ "x$1" = "x--ssh-test" ]; then shift #======================================

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

tmpf=$(mktemp -p ${TMPDIR:-/tmp} -t lddout.XXXX)

scp $tgz root@${sfos_ipaddr}:/tmp;
sfish 'cd /tmp; rm -rf tb; mkdir -p tb; tar xzf '$tgz' -C tb; (export'\
' LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-/tmp/tb}:/tmp/tb/lib64:/tmp/tb/lib:'\
'/tmp/tb/usr/lib:/tmp/tb/usr/lib64; find tb -type f | xargs ldd) 2>&1 |'\
' egrep ":|found" | grep -v "warning:"' >$tmpf

if grep -q "found" $tmpf; then
	echo -e "\nldd check: KO\n"
	cat $tmpf
	echo
else
	echo -e "\nldd check: OK\n"
fi
rm -f $tmpf

fi #============================================================================
