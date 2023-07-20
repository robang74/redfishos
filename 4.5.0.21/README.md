## SailFish OS root filesystem integrity check

There are many ways to detect changes on a filesystem and keeping the changes of the root filesystem under strict control is essential to carry on any serious debug activity. Even if this is not a strictly requirement, it is something that can help a lot especially when the systems are smartphones in the hands of end-users or apps-developers which may lack of system administration skills and it is absolutely reasonable that they lack of that skills. Otherwise the referring market sector will be too small to be profitable.

### Newer than a reference file

The most straightforward is using `find` with the option `-newer` which requires a reference file and the choose of that reference is the almost the only thing that affects the result:

```
find $(cat root-dir-folders-list.txt) -newer config/usb_gadget/g1/idProduct
```

This example seems to work. However, without an analysis we do not know when or if the reference file will be updated and this is clearly a weak point of this approach. Obviously, we can circumvent this shortcoming creating a specific reference file which we will be never updated anymore. Again, this is a supposition because into a RW filesystem cannot provide us that grants even if we reset the all the writing permission: it will be less probable that it will happen by mistake but it is not an assumption that can be granted by itself alone.

Moreover, we are used to rely on the assumption that the system date and time are always correct and reasonably updated. It is not true in the most general case: an embedded system may not have an RTC which keeps the time-flow when the system is powered-off and this is also true for smartphone when the system goes down because the battery is completely discharged.

Usually, it does not happen that a smartphone reach the 0% of the battery. In fact, I saw SFOS shutting down at 2% of battery which is enough to keep the internal RTC working for a decent long period of time. Despite this, at the first boot without any network connection active and no any way to synchronize the date/time there is no any chance to fully trust the system time.

A possible solution is to create the reference file as `/etc/.reference/.file` with `-r--r--r--` permissions set and provide a backup tarball for it in such a way time/date can be restored or check at any time in the future. Instead, there is no a definitive solution about the RTC time flowing but at least about making the time/data flow a monotonic function saving at shutdown the last date/time to read it at the next reboot. This also fail when the user act on the hardware keys to force an emergency immediate shutdown. An alternative approach is to find into filesystem the most recent file/folder and use such date/time in case it is newer than the current date/time.

### File tree checksum

Another approach is to have a reference {files, links, folders} tree and for every file its checksum. The `md5sum` utility produces a forensic weak checksum but good enough for an integrity filesystem check which do not consider malicious MD5 collisions into the picture.

The obvious shortcoming about this approach is that: we are aware about what we know, we are aware about what we do not know but we do not know what we are not aware about. In other words, without a tracking system for every future changes we cannot apply the same strategy again: create a trustworthy checksums list but just update it better if we do in an incremental way.

For example, we can add more information to the list of checksum like a alphabetically sorted list of {files, links, folders} which will help us to check for the differences. Plus a list of packages installed with and without their version. The version is important because the updates will changes the root filesystem while the list of package name is useful to re-install an updated system.

Also this information is subject to change in the time and it should keep updated as much as possible. This is the challenge about this approach but by itself it has not any intrinsic shortcomings like `find` with `-newer`.

### Hashing performances

Usually the `md5sum` is about 2x faster than `sha1sum` on 32-bit devices and 33% faster on 64-bit devices in creating the checksum even if we are much more interested in verifying the checksum which is almost the same because the checksum is re-created and then compared. However, specific implementations of md5sum can greatly vary in their performance and can be slower or faster depending also on the use of the `libcrypto.so` which gives the fastest implementation. In SFOS, both `md5sum` and `sha1sum` are those from the busybox which does not recall the `libcrypto.so` among its dependencies.

The following tests cannot be affected by the disk reading performance because `busybox` and `bash` executable are just loaded in memory and anyway they will be cached at the first reading and a preliminary reading has be done, in fact, just in case:
```
[root@Xperia10II-DualSIM ~]# time bash -c \
'for i in $(seq 1 1000); do sha1sum /usr/bin/busybox >/dev/null; done'
real	0m 18.14s
user	0m 12.75s
sys	0m 3.34s

[root@Xperia10II-DualSIM ~]# time bash -c \
'for i in $(seq 1 1000); do md5sum /usr/bin/busybox >/dev/null; done'
real	0m 11.72s
user	0m 5.42s
sys	0m 4.28s
```
The results clearly indicated that `md5sum` is 1.55x faster than `sh1sum` in our default case.

### Differential backups

[Writing about backup](../forum/users-backup-analisys.md), we noticed that some advanced command line utilities like `rsync` and `pigz` are missing from the root filesystem after the first boot and they are missing as well into the recovery boot image. Until that utilities will not introduced as default part of `usedata` and `recovery boot` images, we cannot rely on them for the SailFish OS refactoring.

However a wise combination of `find` with `-newer` and `md5sum` filesystem integrity check will helps us to deliver a reliable differential backup system that can be adopted for the SailFish OS refactoring, also. 

An alternative approach is to build and deliver an off-line tiny set of packages to install immediately after the first boot in such a way that `rsync` and `pigz` will be a granted as facilities. Obviously, the recovery image refactoring should include these tools, as well.
