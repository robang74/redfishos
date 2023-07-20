## SailFish OS root filesystem

There are many ways to detect changes on a filesystem and keeping the changes of the root filesystem under strict control is essential to carry on any serious debug activity. Even if this is not a strictly requirement, it is something that can help a lot expecially when the systems are smartphones in the hands of end-users or apps-developers which may lack of system administration skills and it is absolutely reasonable that they lack of that skills. Otherwise the referring market sector will be too small to be profitable.

### Newer than a reference file

The most straigforward is using `find` with the option `-newer` which requires a reference file and the choose of that reference is the almost the only thing that affects the result:

```
find $(cat root-dir-folders-list.txt) -newer config/usb_gadget/g1/idProduct
```

This example seems to work. However, without an analisys we do not know when or if the reference file will be updated and this is clearly a sweak point of this approach. Obviously, we can circumvent this shortcoming creating a specific reference file which we will be never updated anymore. Again, this is a supposition because into a RW filesystem cannot provide us that grants even if we reset the all the writing permission: it will be less probable that it will happen by mistake but it is not an assumption that can be granted by itself alone.

Moreover, we are used to rely on the assumption that the system date and time are always correct and reasonably updated. It is not true in the most general case: an embedded system may not have an RTC which keeps the timeflow when the system is powered-off and this is also true for smartphone when the system goes down because the battery is completely discharged.

Usually, it does not happen that a smartphone reach the 0% of the battery. In fact, I saw SFOS shutting down at 2% of battery which is enough to keep the internal RTC working for a decent long period of time. Despite this, at the first boot without any network connection active and no any way to synchronise the date/time there is no any chance to fully trust the system time.

A possible solution is to create the reference file as `/etc/.reference/.file` with `-r--r--r--` permissions set and provide a backup tarball for it in such a way time/date can be restored or check at any time in the future. Instead, there is no a definitive solution about the RTC time flowing but at least about making the time/data flow a monotonic function saving at shutdown the last date/time to read it at the next reboot. This also fail when the user act on the hardware keys to force an emergency immediate shutdown. An alternative approach is to find into filesystem the most recent file/folder and use such date/time in case it is newer than the current date/time.

### File tree checksum

Another approach is to have a reference {files, links, folders} tree and for every file its checksum. The `md5sum` utility produces a forensic waek checksum but good enough for an integrity filesystem check which do not consider malicious MD5 collisions into the picture. 

Usually the `md5sum` is about 2x faster than `sha1sum` on 32-bit devices and 33% faster on 64-bit devices in creating the checksum even if we are much more interested in verifying the checksum which is almost the same because the checksum is re-created and then compared. However, specific implementations of md5sum can greatly vary in their performance and can be slower or faster depending also on the use of the `libcrypto.so` which gives the fastest implementation. In SFOS, both `md5sum` and `sha1sum` are those from the busybox which does not recall the `libcrypto.so` among its dependencies.

The following tests cannot be affected by the disk reading perfomance because `busybox` and `bash` executables are just loaded in memory and anyway they will be cached at the first reading and a preliminary reading has be done, in fact, just in case:
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



