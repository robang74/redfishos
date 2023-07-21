#!/bin/bash

url="https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/"

rpm_list="
binutils-2.30-108.el8_5.1.aarch64.rpm
libattr-2.4.48-3.el8.aarch64.rpm
patch-2.7.6-11.el8.aarch64.rpm
rsync-3.1.3-12.el8.aarch64.rpm
pigz-2.4-4.el8.aarch64.rpm
"

name="recovery-utils"
tgz="$name.tar.gz"
dir="$name.dir"

set -e

mkdir -p $dir && cd $dir
for i in $rpm_list; do wget -c $url/$i; done
for i in *.rpm; do rpm2cpio $(basename $i) | sudo cpio -idmu -R root.root; done

usr_bin="
addr2line ar as c++filt dwp elfedit gprof ld.bfd size
ld.gold  nm objcopy objdump pigz ranlib readelf strip
"
usr_lib64="libbfd libopcodes"

#for i in $usr_bin $usr_lib64; do sudo rm -rf usr/bin/$i usr/lib64/$i*; done
#rm -rf usr/lib/ usr/share/ #*.rpm

#sudo chown -R root.root *
set -x
sudo tar cvzf ../$tgz --exclude="usr/lib" --exclude="usr/share" \
	$(for i in $usr_bin $usr_lib64; do echo --exclude=usr/bin/$i  \
		--exclude=usr/lib64/$i*; done) etc usr
cd ..
#sudo rm -rf $dir
sudo chown -R $USER.$USER $tgz
du -ks $tgz

