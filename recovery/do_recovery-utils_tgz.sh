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
name="recovery-utils"
tgz="$name.tar.gz"
dir="$name.dir"

url_1="https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/"
rpm_list_1="
libattr-2.4.48-3.el8.aarch64.rpm
patch-2.7.6-11.el8.aarch64.rpm
rsync-3.1.3-12.el8.aarch64.rpm
pigz-2.4-4.el8.aarch64.rpm
"

url_2="https://dl.fedoraproject.org/pub/epel/8/Everything/aarch64/Packages/"
rpm_list_2="
dd_rescue-1.99.12-3.el8.aarch64.rpm
"

url_3="http://mirror.centos.org/centos/8-stream/BaseOS/aarch64/os/Packages/"
rpm_list_3="
parted-3.2-39.el8.aarch64.rpm
gdisk-1.0.3-11.el8.aarch64.rpm
libsepol-2.9-3.el8.aarch64.rpm
readline-7.0-10.el8.aarch64.rpm
libgcc-8.5.0-20.el8.aarch64.rpm
libselinux-2.9-8.el8.aarch64.rpm
libstdc++-8.5.0-20.el8.aarch64.rpm
ncurses-libs-6.1-9.20180224.el8.aarch64.rpm
"

# PACKAGES PROVIDING ###########################################################

echo "This script requires the root priviledges"
mkdir -p $dir && cd $dir && sudo rm -rf $tar_dir

if [ "x$1" = "x--no-download" ]; then shift
else #==========================================================================

for i in $rpm_list_1; do wget -c $url_1/$i; done

for i in $rpm_list_2; do wget -c $url_2/${i:0:1}/$i; done

for i in $rpm_list_3; do wget -c $url_3/$i; done

fi #============================================================================

for i in $rpm_list_1 $rpm_list_2 $rpm_list_3; do
    rpm2cpio $(basename $i) | sudo cpio -idmu -R root.root
done; echo

# PACKAGES MANAGEMENT ##########################################################

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
