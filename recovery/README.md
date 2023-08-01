> # :warning: WARNING 
> 
> The scripts in `recovery` folder are still in alpha or beta testing. Do not use it if you are sure about what you are doing.
> 
> Here below are a couple of exceptions to this general rule: the scripts to generate the `recovery` and `sysdebug` archives.
> 
> However, these two archives installed in the root filesystem can brick your system. Hence, you have been warned.

---

## About recovery package

To create this package, `aarch64` binaries and libraries from a `Centos 8` RPM repository have been used.

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

To create this package, `aarch64` binaries and libraries from `Centos 8` and `Fedora 8` RPM repositories have been used.

This below is the list of the main binaries, while some others, which are their helpers, have been not reported:

* `arp-scan`, `tcpdump`, `tcpslice`, `ntpdate`, `tcptraceroute`, `traceroute`, `ncat`, `dig`, `host`, `nslookup`, `strace`, `stress-ng`.

The script that downloads and creates the `sysdebug` tarball is here:

* [do_sysdebug-utils_tgz.sh](do_sysdebug-utils_tgz.sh)

The created tarball size is about 7.2Mb. Therefore, it is not included in this repository.

Moreover, due to its nature, it is not immediate - at the moment - to deploy somewhere else than the root filesystem:

```
tar -k xvzf $PWD/sysdebug-utils.tar.gz -C /
```

The `-k` avoids overwriting the original files, but it is supposed that they were not in place if you need this tarball.

---

### Scripts dependencies

Both scripts requires some extra dependencies, if they are executed with `--ssh-test` as command line parameter:

* [do_ssh_ldd_test_utils.env](do_ssh_ldd_test_utils.env) - it contains the code to make the `ldd` libraries test via SSH 

* [pcos / sfos-ssh-connect.env](../scripts/pcos/sfos-ssh-connect.env) - it is the bash environment required by the script above for SSH automatic connection.

* [sfos-ssh-connect-env patch](https://coderus.openrepos.net/pm2/project/sfos-ssh-connect-env) - it is the script that enable the quick & safe password-less root-login via SSH, a system setup-up required by the environment above. 

The `--ssh-test` enables shell script code which copy and test via SSH the tarball content about libraries dependency with `ldd`.

---

### Full features busybox

Most - but not all - the command-line binaries included into these tarballs can be replaced by those available into the full features busybox statically linked available at the link here below:

* [sailfish-os-busybox 1.36.1-git2-raf3 all-arch .zip archive](https://github.com/robang74/sailfish-os-busybox/suites/14532585331/artifacts/822197317)

Before installing any of the RPM package contained in that .zip archive read [this page](https://github.com/robang74/sailfish-os-busybox#readme).
