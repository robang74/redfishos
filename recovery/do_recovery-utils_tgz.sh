#!/bin/bash
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released under the GPLv2 license terms.
#
################################################################################
# release: 0.0.1

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
	$(for i in $lib_excl; do echo --exclude={,usr/}lib*/$i*; done; \
	  for i in $bin_excl; do echo --exclude={,usr/}*bin/$i; done;) \
	$(find ./ ! -name \*.rpm -maxdepth 1|cut -d/ -f2-)
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

do_ssh_ldd_test_utils

fi #============================================================================
