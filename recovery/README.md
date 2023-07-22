## About recovery package

To create this package it has been used the Centos 8 binary RPMs repository:

* https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/

	* libattr-2.4.48-3.el8.aarch64.rpm
	* patch-2.7.6-11.el8.aarch64.rpm
	* rsync-3.1.3-12.el8.aarch64.rpm
	* pigz-2.4-4.el8.aarch64.rpm

Just the essential utils packaged into a gzip tarball:

* [recovery-utils.tar.gz](recovery-utils.tar.gz)

to explode directly on the root filesystem:

```
tar -k xvzf $PWD/recovery-utils.tar.gz -C /
```

The `-k` avoid to overwrite the original files but it is supposed that they were not in place if you need this tarball.

Or it can be exploded into the volatile `/tmp` exporting this variables:

```
export PATH=$PATH:/tmp/usr/bin LD_LIBRARY_PATH=/tmp/usr/lib64:$LD_LIBRARY_PATH
```

to set properly the shell enviroment for using the imported binayries in `/tmp`.

The script that downloads and create this tarball is here:

* [do_recovery-utils_tgz](do_recovery-utils_tgz)
	
The package created is less tha 450Kb and it is included in this repository due to its relatively small size.

What is missing is `strings` because with its dependency will have brought this package at the size of 1.5Mb while a 2x faster 16Kb version of `strings` can be compiled from [this source](strings.c) presented in the busybox developers m-list in [this thread](https://lists.busybox.net/pipermail/busybox/2023-July/090396.html).
 
---

## About sysdebug package

To create this package it has been used two Centos 8 binary RPMs repositories:

* https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/

	* strace-5.7-3.el8.aarch64.rpm
	* traceroute-2.1.0-6.el8.aarch64.rpm
	* elfutils-libelf-0.185-1.el8.aarch64.rpm
	* keyutils-libs-1.5.10-9.el8.aarch64.rpm
	* elfutils-libs-0.185-1.el8.aarch64.rpm
	* krb5-libs-1.18.2-14.el8.aarch64.rpm
	* json-c-0.13.1-2.el8.aarch64.rpm
	* libidn2-2.2.0-1.el8.aarch64.rpm

* https://vault.centos.org/centos/8/AppStream/aarch64/os/Packages/
	
	* tcpdump-4.9.3-2.el8.aarch64.rpm
	* nmap-ncat-7.70-6.el8.aarch64.rpm
	* bind-utils-9.11.26-6.el8.aarch64.rpm
	* bind-libs-9.11.26-6.el8.aarch64.rpm
	* bind-libs-lite-9.11.26-6.el8.aarch64.rpm
	* libmaxminddb-1.2.0-10.el8.aarch64.rpm
	* protobuf-c-1.3.0-6.el8.aarch64.rpm
	* fstrm-0.6.1-2.el8.aarch64.rpm

The script that downloads and create this tarball named sysdebug-utils.tar.gz wich its size is near 4Mb. Therefore is not included in this repository. Moreover, due to its nature it is not immediate - at the moment - to deploy somewhere else than the root filesystem:

```
tar -k xvzf $PWD/sysdebug-utils.tar.gz -C /
```

The `-k` avoid to overwrite the original files but it is supposed that they were not in place if you need this tarball.

