#!/bin/bash

url="https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/"

rpm_list_1="
strace-5.7-3.el8.aarch64.rpm
traceroute-2.1.0-6.el8.aarch64.rpm
libunistring-0.9.9-3.el8.aarch64.rpm
elfutils-libelf-0.185-1.el8.aarch64.rpm
keyutils-libs-1.5.10-9.el8.aarch64.rpm
elfutils-libs-0.185-1.el8.aarch64.rpm
krb5-libs-1.18.2-14.el8.aarch64.rpm
json-c-0.13.1-2.el8.aarch64.rpm
libidn2-2.2.0-1.el8.aarch64.rpm
"

tar_dir="etc bin usr var"
name="sysdebug-utils"
tgz="$name.tar.gz"
dir="$name.dir"

set -e

mkdir -p $dir && cd $dir && sudo rm -rf $tar_dir
for i in $rpm_list_1; do wget -c $url/$i; done

url="https://vault.centos.org/centos/8/AppStream/aarch64/os/Packages/"


rpm_list_2="
tcpdump-4.9.3-2.el8.aarch64.rpm
nmap-ncat-7.70-6.el8.aarch64.rpm
bind-utils-9.11.26-6.el8.aarch64.rpm
bind-libs-9.11.26-6.el8.aarch64.rpm
bind-libs-lite-9.11.26-6.el8.aarch64.rpm
libmaxminddb-1.2.0-10.el8.aarch64.rpm
protobuf-c-1.3.0-6.el8.aarch64.rpm
fstrm-0.6.1-2.el8.aarch64.rpm
"

for i in $rpm_list_2; do wget -c $url/$i; done

url="https://dl.fedoraproject.org/pub/epel/8/Everything/aarch64/Packages/"

rpm_list_3="arp-scan-1.10.0-1.el8.aarch64.rpm"

for i in $rpm_list_3; do wget -c $url/${i:0:1}/$i; done

################################################################################

for i in $rpm_list_1 $rpm_list_2 $rpm_list_3; do
	rpm2cpio $(basename $i) | sudo cpio -idmu -R root.root
done; echo

bin_excl="
nsupdate arpaname mmdblookup dnstap-read named-compilezone ddns-confgen
genrandom named-checkzone nsec3hash isc-hmac-fixup delv tsig-keygen
arp-fingerprint get-iab get-oui
"

bin_incl="usr/share/arp-scan/ieee-oui.txt"

#for i in $usr_bin; do sudo rm -f usr/*bin/$i; done
#rm -rf usr/lib/ usr/share/ usr/sbin/dns* #*.rpm

#sudo chown -R root.root *
sudo tar cvzf ../$tgz --exclude="usr/lib" --exclude="usr/share" \
	$(for i in $bin_incl; do echo --exclude-ignore=$i; done; \
	$(for i in $bin_excl; do echo --exclude=usr/*bin/$i --exclude=*bin/$i; \
	done) --exclude="usr/sbin/dns*" $(ls -1d $tar_dir 2>/dev/null)
cd ..
#sudo rm -rf $dir
sudo chown -R $USER.$USER $tgz
echo; du -ks $tgz | tr '\t' ' '

