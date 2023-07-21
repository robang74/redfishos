#!/bin/bash

url="https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/"

rpm_list="
strace-5.7-3.el8.aarch64.rpm
traceroute-2.1.0-6.el8.aarch64.rpm
elfutils-libelf-0.185-1.el8.aarch64.rpm
keyutils-libs-1.5.10-9.el8.aarch64.rpm
elfutils-libs-0.185-1.el8.aarch64.rpm
krb5-libs-1.18.2-14.el8.aarch64.rpm
json-c-0.13.1-2.el8.aarch64.rpm
libidn2-2.2.0-1.el8.aarch64.rpm
"

name="sysdebug-utils"
tgz="$name.tar.gz"
dir="$name.dir"

set -e

mkdir -p $dir && cd $dir
for i in $rpm_list; do 	wget -c $url/$i; done

url="https://vault.centos.org/centos/8/AppStream/aarch64/os/Packages/"

rpm_list="
tcpdump-4.9.3-2.el8.aarch64.rpm
nmap-ncat-7.70-6.el8.aarch64.rpm
bind-utils-9.11.26-6.el8.aarch64.rpm
bind-libs-9.11.26-6.el8.aarch64.rpm
bind-libs-lite-9.11.26-6.el8.aarch64.rpm
libmaxminddb-1.2.0-10.el8.aarch64.rpm
protobuf-c-1.3.0-6.el8.aarch64.rpm
fstrm-0.6.1-2.el8.aarch64.rpm
"

for i in $rpm_list; do wget -c $url/$i; done
for i in *.rpm; do rpm2cpio $(basename $i) | sudo cpio -idmu -R root.root; done

usr_bin="
nsupdate delv arpaname mmdblookup dnstap-read
genrandom named-checkzone nsec3hash isc-hmac-fixup
"
for i in $usr_bin; do sudo rm -f usr/*bin/$i; done
#rm -rf usr/lib/ usr/share/ usr/sbin/dns* #*.rpm

#sudo chown -R root.root *
sudo tar cvzf ../$tgz --exclude="usr/lib" --exclude="usr/share" \
	$(for i in $usr_bin; do echo --exclude=usr/*bin/$i; done) \
	--exclude="usr/sbin/dns*" etc usr var bin
cd ..
#sudo rm -rf $dir
sudo chown -R $USER.$USER $tgz
du -ks $tgz

