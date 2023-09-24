#!/bin/bash
#
# (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
#           Released under the GPLv2 license terms.
#
################################################################################
# release: 0.0.6

set -e

# VARIABLES DEFINITION #########################################################

tar_dir="etc bin usr var"
name="recovery-image"
tgz="$name.tar.gz"
dir="$name.dir"


url_1="http://mirror.centos.org/centos/8-stream/BaseOS/aarch64/os/Packages/"
rpm_list_1="
glibc-2.28-234.el8.aarch64.rpm

pigz-2.4-4.el8.aarch64.rpm libgcc-8.5.0-20.el8.aarch64.rpm zlib-1.2.11-25.el8.aarch64.rpm
parted-3.2-39.el8.aarch64.rpm
lvm2-2.03.14-9.el8.aarch64.rpm
gdisk-1.0.3-11.el8.aarch64.rpm
rsync-3.1.3-19.el8.1.aarch64.rpm
libzstd-1.4.4-1.el8.aarch64.rpm

e2fsprogs-1.45.6-5.el8.aarch64.rpm e2fsprogs-libs-1.45.6-5.el8.aarch64.rpm
cryptsetup-2.3.7-5.el8.aarch64.rpm cryptsetup-libs-2.3.7-5.el8.aarch64.rpm

libacl-2.2.53-1.el8.aarch64.rpm
libaio-0.3.112-1.el8.aarch64.rpm
libattr-2.4.48-3.el8.aarch64.rpm
libblkid-2.32.1-42.el8.aarch64.rpm
libmount-2.32.1-42.el8.aarch64.rpm
libselinux-2.9-8.el8.aarch64.rpm
libgcrypt-1.8.5-7.el8.aarch64.rpm
libpng-1.6.34-5.el8.aarch64.rpm
libcap-2.48-4.el8.aarch64.rpm
libcap-ng-0.7.11-1.el8.aarch64.rpm
libgpg-error-1.31-1.el8.aarch64.rpm
libcom_err-1.45.6-5.el8.aarch64.rpm
libpwquality-1.4.4-6.el8.aarch64.rpm
libsepol-2.9-3.el8.aarch64.rpm
libstdc++-8.5.0-20.el8.aarch64.rpm
libxcrypt-4.1.1-6.el8.aarch64.rpm
libuuid-2.32.1-42.el8.aarch64.rpm

popt-1.18-1.el8.aarch64.rpm
readline-7.0-10.el8.aarch64.rpm
audit-libs-3.0.7-5.el8.aarch64.rpm
device-mapper-event-libs-1.02.181-9.el8.aarch64.rpm
device-mapper-libs-1.02.181-9.el8.aarch64.rpm
ncurses-libs-6.1-9.20180224.el8.aarch64.rpm
openssl-libs-1.1.1k-9.el8.aarch64.rpm
cracklib-2.9.6-15.el8.aarch64.rpm
lz4-libs-1.8.3-3.el8_4.aarch64.rpm
xz-libs-5.2.4-4.el8.aarch64.rpm
pcre2-10.32-3.el8.aarch64.rpm
pam-1.3.1-27.el8.aarch64.rpm
krb5-libs-1.18.2-25.el8.aarch64.rpm
keyutils-libs-1.5.10-9.el8.aarch64.rpm
systemd-libs-239-76.el8.aarch64.rpm
nss_db-2.28-236.el8.aarch64.rpm
"

url_2=${url_1/BaseOS/AppStream}
rpm_list_2="
libdrm-2.4.115-2.el8.aarch64.rpm
netpbm-progs-10.82.00-7.el8.aarch64.rpm
netpbm-10.82.00-7.el8.aarch64.rpm
i2c-tools-4.0-12.el8.aarch64.rpm
"

url_3=$url_1
rpm_list_3="
strace-5.18-2.el8.aarch64.rpm
elfutils-libs-0.189-3.el8.aarch64.rpm
elfutils-libelf-0.189-3.el8.aarch64.rpm
cryptsetup-reencrypt-2.3.7-7.el8.aarch64.rpm
openssh-server-8.0p1-17.el8.aarch64.rpm
glibc-common-2.28-234.el8.aarch64.rpm
bzip2-libs-1.0.6-26.el8.aarch64.rpm
coreutils-8.30-15.el8.aarch64.rpm
binutils-2.30-123.el8.aarch64.rpm
procps-ng-3.3.15-14.el8.aarch64.rpm
iw-5.19-1.el8.1.aarch64.rpm
libnl3-3.7.0-1.el8.aarch64.rpm
"

url_4="https://dl.fedoraproject.org/pub/epel/8/Everything/aarch64/Packages/"
rpm_list_4="
htop-3.2.1-1.el8.aarch64.rpm
dropbear-2019.78-5.el8.aarch64.rpm
libtommath-1.1.0-4.el8.aarch64.rpm
libtomcrypt-1.18.2-5.el8.aarch64.rpm
android-tools-33.0.3p1-3.el8.aarch64.rpm
pv-1.6.6-7.el8.aarch64.rpm
"

none="
glib2-2.56.4-161.el8.aarch64.rpm
util-linux-2.32.1-42.el8.aarch64.rpm

openssh-clients-8.0p1-17.el8.aarch64.rpm
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

fi #============================================================================

for i in $rpm_list_1 $rpm_list_2 $rpm_list_3 $rpm_list_4; do
    rpm2cpio $(basename $i) | sudo cpio -idmu -R root.root
done; echo

# PACKAGES MANAGEMENT ##########################################################

bin_excl="
addr2line ar as c++filt dwp elfedit gprof ld.bfd size
ld.gold nm objcopy objdump ranlib readelf
"

lib_escl="libopcodes"

sudo bash +e <<'EOF'
    test "x$(pwd)" = "x/" && exit 1

    rm -f usr/lib64 usr/bin
    mkdir -p usr/bin/ usr/lib64/

    cd usr/bin; ln -sf unpigz pigz; cd - >/dev/null

    mv -f bin/* sbin/* usr/sbin/* usr/bin/
    rmdir bin sbin usr/sbin

#    find . -name ld-linux-aarch64.so.1 | xargs ls -al

    rm -f lib/ld-linux-aarch64.so.1 etc/ld.so.conf
    mv -f lib/* lib64/* usr/lib/* usr/lib64/
    rmdir lib lib64 usr/lib

    for i in $(cat ../bb.list); do
        ln -sf /sbin/busybox-static usr/$i
    done

    true
EOF

read -p "press enter"

sudo tar cvzf ../$tgz --exclude="usr/lib" --exclude="usr/share" \
    --exclude=.MTREE --exclude=.BUILDINFO --exclude=.PKGINFO \
    $(for i in $lib_excl; do echo --exclude={,usr/}lib*/$i*; done; \
      for i in $bin_excl; do echo --exclude={,usr/}*bin/$i; done;) \
    $(find ./ -maxdepth 1 ! -name \*.rpm |cut -d/ -f2-)
cd ..

sudo chown -R $USER.$USER $tgz
echo; du -ks $tgz | tr '\t' ' '

echo '
rm -rf lib* usr/lib* usr/*bin *bin
rm -rf etc/lvm/ etc/mke2fs.conf etc/pam.d/ etc/sysconfig/ssh*
git reset --hard HEAD

tar xvzf /home/roberto/r/recovery/recovery-image.tar.gz -C .

res usr/bin/partprobe
res usr/bin/chattr
res usr/bin/lsattr
res etc/ld.so.conf
res etc/ssh/sshd_config
mv -f usr/sbin/* usr/bin
res usr/sbin sbin
res usr/bin/fsck.ext?
res usr/bin/mke2fs usr/bin/mkfs.ext2
mv -f lib/* lib64/* usr/lib64
ln -sf ld-2.28.so lib/ld-linux-aarch64.so.1
res lib lib64
'

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
