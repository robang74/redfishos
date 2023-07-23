#!/bin/bash

url="https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/"

# binutils-2.30-108.el8_5.1.aarch64.rpm

rpm_list="
libattr-2.4.48-3.el8.aarch64.rpm
patch-2.7.6-11.el8.aarch64.rpm
rsync-3.1.3-12.el8.aarch64.rpm
pigz-2.4-4.el8.aarch64.rpm
"

tar_dir="etc bin usr var"
name="recovery-utils"
tgz="$name.tar.gz"
dir="$name.dir"

set -e

mkdir -p $dir && cd $dir && sudo rm -rf $tar_dir
for i in $rpm_list; do wget -c $url/$i; done
for i in $rpm_list; do 
	rpm2cpio $(basename $i) | sudo cpio -idmu -R root.root
done; echo

bin_excl="
addr2line ar as c++filt dwp elfedit gprof ld.bfd size
ld.gold  nm objcopy objdump ranlib readelf strip
"
lib_escl="libopcodes"

#for i in $usr_bin $usr_lib64; do sudo rm -rf usr/bin/$i usr/lib64/$i*; done
#rm -rf usr/lib/ usr/share/ #*.rpm

#sudo chown -R root.root *
#set -x

cd usr/bin; sudo ln -sf unpigz pigz; cd - >/dev/null
sudo tar cvzf ../$tgz --exclude="usr/lib" --exclude="usr/share" \
	$(for i in $bin_excl; do echo --exclude=usr/*bin/$i --exclude=*bin/$i; \
	done) $(for i in $lib_excl; do echo --exclude=usr/lib*/$i*; done) \
	$(ls -1d $tar_dir 2>/dev/null)
cd ..
#sudo rm -rf $dir
sudo chown -R $USER.$USER $tgz
echo; du -ks $tgz | tr '\t' ' '

