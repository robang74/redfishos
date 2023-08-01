#!/bin/bash

tar_dir="etc bin usr var"
name="recovery-utils"
tgz="$name.tar.gz"
dir="$name.dir"

url="https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/"
rpm_list="
libattr-2.4.48-3.el8.aarch64.rpm
patch-2.7.6-11.el8.aarch64.rpm
rsync-3.1.3-12.el8.aarch64.rpm
pigz-2.4-4.el8.aarch64.rpm
"

set -e

mkdir -p $dir && cd $dir && sudo rm -rf $tar_dir

if [ "x$1" = "x--no-download" ]; then shift
else #==========================================================================

for i in $rpm_list; do wget -c $url/$i; done

fi #============================================================================

for i in $rpm_list; do 
	rpm2cpio $(basename $i) | sudo cpio -idmu -R root.root
done; echo

bin_excl="
addr2line ar as c++filt dwp elfedit gprof ld.bfd size
ld.gold  nm objcopy objdump ranlib readelf strip
"

lib_escl="libopcodes"

cd usr/bin; sudo ln -sf unpigz pigz; cd - >/dev/null
sudo tar cvzf ../$tgz --exclude="usr/lib" --exclude="usr/share" \
	$(for i in $bin_excl; do echo --exclude=usr/*bin/$i --exclude=*bin/$i; \
	done) $(for i in $lib_excl; do echo --exclude=usr/lib*/$i*; done) \
	$(ls -1d $tar_dir 2>/dev/null)
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
