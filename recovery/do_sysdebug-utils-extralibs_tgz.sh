#!/bin/bash
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released under the GPLv2 license terms.
#
################################################################################
# release: 0.0.1

tar_dir="etc bin usr var"
name="sysdebug-utils-extralibs"
tgz="$name.tar.gz"
dir="$name.dir"

url_1="http://mirror.centos.org/centos/8-stream/BaseOS/aarch64/os/Packages/"
rpm_list_1="
libcap-2.48-4.el8.aarch64.rpm
glibc-2.28-228.el8.aarch64.rpm
libpcap-1.9.1-5.el8.aarch64.rpm
libselinux-2.9-8.el8.aarch64.rpm
openssl-libs-1.1.1k-9.el8.aarch64.rpm
bzip2-libs-1.0.6-26.el8.aarch64.rpm
libibverbs-46.0-1.el8.1.aarch64.rpm
libxml2-2.9.7-16.el8.aarch64.rpm
libzstd-1.4.4-1.el8.aarch64.rpm
libgcc-8.5.0-20.el8.aarch64.rpm
libnl3-3.7.0-1.el8.aarch64.rpm
pcre2-10.32-3.el8.aarch64.rpm
"

set -e
mkdir -p $dir && cd $dir && sudo rm -rf $tar_dir

if [ "x$1" = "x--no-download" ]; then shift
else #==========================================================================

for i in $rpm_list_1; do wget -c $url_1/$i; done

fi #============================================================================

for i in $rpm_list_1; do
	rpm2cpio $(basename $i) | sudo cpio -idmu -R root.root
done; echo

bin_excl=""

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
