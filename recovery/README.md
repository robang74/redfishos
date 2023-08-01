> # :warning: WARNING 
> 
> The scripts in `recovery` folder are still in alpha or beta testing. Do not use it if you are sure about what you are doing.
> 
> Here below are a couple of exceptions to this general rule: the scripts to generate the `recovery` and `sysdebug` archives.
> 
> However, these two archives installed in the root filesystem can brick your system. Hence, you have been warned.

---

## About recovery package

To create this package, the `Centos 8` binary `aarch64` RPM repository was used:

* https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/

  * libattr-2.4.48-3.el8.aarch64.rpm
  * patch-2.7.6-11.el8.aarch64.rpm
  * rsync-3.1.3-12.el8.aarch64.rpm
  * pigz-2.4-4.el8.aarch64.rpm

Just the essential utilities packaged into a gzip tarball:

* [recovery-utils.tar.gz](recovery-utils.tar.gz)

to explode directly on the root filesystem:

```
tar -k xvzf $PWD/recovery-utils.tar.gz -C /
```

The `-k` avoids overwriting the original files, but it is supposed that they were not in place if you need this tarball.

Or it can be exploded into the volatile `/tmp` exporting these variables:

```
export PATH=$PATH:/tmp/usr/bin LD_LIBRARY_PATH=/tmp/usr/lib64:$LD_LIBRARY_PATH
```

to set properly the shell environment for using the imported binaries in `/tmp`.

The script that downloads and creates this tarball is here:

* [do_recovery-utils_tgz.sh](do_recovery-utils_tgz.sh)

The created package is less than 450Kb and it is included in this repository due to its relatively small size.

What is missing is `strings` because its dependency will have brought this package to a size of 1.5Mb while a 2x faster 16Kb version of `strings` can be compiled from [this source](strings.c) presented in the busybox developers m-list in [this thread](https://lists.busybox.net/pipermail/busybox/2023-July/090396.html).

---

## About sysdebug package

To create this package, it has been used `Centos 8` and `Fedora 8` `aarch64` binary RPM repositories:

* https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/

  * strace-5.7-3.el8.aarch64.rpm
  * traceroute-2.1.0-6.el8.aarch64.rpm
  * libunistring-0.9.9-3.el8.aarch64.rpm
  * elfutils-libelf-0.185-1.el8.aarch64.rpm
  * keyutils-libs-1.5.10-9.el8.aarch64.rpm
  * krb5-libs-1.18.2-14.el8.aarch64.rpm
  * libverto-0.3.0-5.el8.aarch64.rpm
  * json-c-0.13.1-2.el8.aarch64.rpm
  * libidn2-2.2.0-1.el8.aarch64.rpm

* https://vault.centos.org/centos/8/AppStream/aarch64/os/Packages/

  * tcpdump-4.9.3-2.el8.aarch64.rpm
  * nmap-ncat-7.70-6.el8.aarch64.rpm
  * bind-libs-9.11.26-6.el8.aarch64.rpm
  * bind-utils-9.11.26-6.el8.aarch64.rpm
  * compat-openssl10-1.0.2o-3.el8.aarch64.rpm
  * bind-libs-lite-9.11.26-6.el8.aarch64.rpm
  * libmaxminddb-1.2.0-10.el8.aarch64.rpm
  * protobuf-c-1.3.0-6.el8.aarch64.rpm
  * fstrm-0.6.1-2.el8.aarch64.rpm
 
* http://mirror.centos.org/altarch/7/os/aarch64/Packages/"

  * ntpdate-4.2.6p5-29.el7.centos.2.aarch64.rpm

* https://dl.fedoraproject.org/pub/epel/8/Everything/aarch64/Packages/a/

  * arp-scan-1.10.0-1.el8.aarch64.rpm

The script that downloads and creates the `sysdebug` tarball is here:

* [do_sysdebug-utils_tgz.sh](do_sysdebug-utils_tgz.sh)

The created tarball size is about 6.4Mb. Therefore, it is not included in this repository.

Moreover, due to its nature, it is not immediate - at the moment - to deploy somewhere else than the root filesystem:

```
tar -k xvzf $PWD/sysdebug-utils.tar.gz -C /
```

The `-k` avoids overwriting the original files, but it is supposed that they were not in place if you need this tarball.
