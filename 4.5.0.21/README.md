## SailFish OS root filesystem integrity check

There are many ways to detect changes on a filesystem, and keeping the changes to the root filesystem under strict control is essential to carrying out any serious debugging activity.

Even if this is not a strict requirement, it is something that can help a lot, especially when the systems are smartphones in the hands of end-users or apps developers who may lack system administration skills, and it is absolutely reasonable that they lack those skills.

Otherwise, the referring market sector will be too small to be profitable.

---

### Newer than a reference file

The most straightforward is using `find` with the option `-newer` which requires a reference file, and the choice of that reference is the only thing that affects the result keeping constant the other `find` parameters:

```
find $(cat /tmp/root-dir-folders-list.txt) -newer config/usb_gadget/g1/idProduct

find / ! -type d -xdev ! -path "/root/*" -newer /root/.ssh/authorized_keys
```

This example seems to work. However, without an analysis, we do not know when or if the reference file will be updated, and this is clearly a weak point of this approach. Obviously, we can circumvent this shortcoming by creating a specific reference file that we will never update again. Again, this is a supposition because a RW filesystem cannot provide us with this as a given.

Even if we reset all the writing permissions, it will be less probable that it will happen by mistake, but again it is an assumption that cannot be granted by itself alone. Moreover, we are used to relying on the assumption that the system date and time are always correct and reasonably updated.

This is not true in the most general case: an embedded system may not have an RTC that keeps the time flow when the system is powered off. This is also true for smartphones when the system goes down because the battery is completely discharged and the smartphone remains in that state for too long.

Usually, it does not happen that a smartphone reaches 0% of its battery. In fact, I saw SFOS shutting down at 2% battery, which is enough to keep the internal RTC working for a decently long period of time. Despite this, at the first boot, without any network connection active and no way to synchronize the date and time, there is no chance to fully trust the system time.

Therefore, there is not a definitive solution to the RTC time flow. However, we can make the time/data flow a monotonic function, saving at shutdown the last date/time to read at the next reboot. Unfortunately, this approach fails when the user acts on the hardware keys to force an immediate emergency shutdown.

An alternative solution is to find the last time/date written on the filesystem and use it to update the RTC every time its value is newer than the system time/date. This works unless someone changes a {file, link, folder} time/date using a value in the future, which is an unlikely case but possible.

```
findlast_datetime()
{
    dir="/"
    while [ -d "$dir" ]; do
        old=$dir
        dir=$(find "$dir" -type d ! -path "/root/.*" -xdev -maxdepth 1 -print0 \
            | xargs -0 stat -c '%Z:%n' | sort -nr | head -n1 | cut -d: -f2-)
        test "$old" = "$dir" && break
    done
    find "$dir" ! -type d ! -path "/root/.*" -xdev -maxdepth 1 -print0 \
        | xargs -0 stat -c '%Z:%n' | sort -nr | head -n1
}
```

Another way is to create the reference file as `/etc/.reference/.file` with `-r--r--r--` permissions set and provide a backup tarball for it in such a way that time/date can be restored or checked at any time in the future. Which tells us that for every modification that can be done on the root filesystem by unpackaging a tarball containing older files, these files would not be found with `find -newer`. You might think that this is an usual case but it is not at all. In fact, an RPM is like any other archive: every file date will be the date of the file was built on the RPM building machine.

As we can see, it seems that `find -newer` is a good way to learn a lot of details, but it is not a viable solution to find the changes that happened on the root filesystem recently.

---

### File tree checksum

Another completely different approach is to have a reference {files, links, folders} tree and for every file in it, a checksum.

The `md5sum` utility produces a forensically weak checksum, but it is good enough for an integrity filesystem check that does not consider MD5 collisions, in particular those which are artificially created by a malicios attacker.

The obvious shortcoming about this approach is:

* we are aware of what we know; we are aware of what we do not know; but we do not know what we are not aware of.

In other words, without a real-time tracking system for every future filesystem change, we cannot apply the same strategy again: create a trustworthy list of checksums. What we can do is compare the filesystem md5sums list done at a certain time with the current state of the filesystem. You might wonder what the difference is. It is about accepting the current state as the new status-quo without knowing anything about when, who, or why a change occurred and therefore fully trusting in those changes unless we did so with our own bare hands.

Therefore, we can try to keep the md5sums list updated as best we can and in an incremental way. Under this point of view, a user-space application might not be the definitive solution because it can crash and, therefore, some changes may be lost in the meantime that it restarts. Hence, for a secure and definitive solution, a filesystem that offers this feature or a fuse-fs overly is the best approach, but it is not immediate to develop from scratch.

Back to the checksum tree, we can add more information to the list of checksums, like

* an alphabetically sorted list of {files, links, folders}
* a list of packages installed with and without their version.

The version is important because future updates will change the root filesystem, while the list of package names is useful to reinstall or update the system without the need for regular expressions to have a simple list of packages. Also, this information is subject to change over time, and it must be kept updated as much as possible.

Therefore, this approach without a dedicated filesystem layer shows intrinsic shortcomings, but it is better than what `find` with `-newer` can do because at least it can deliver a reliable list of {file, link, folder} that have been changed, added, or removed since the last verification took place.

---

### Hashing performances

Usually the `md5sum` is about 2x faster than `sha1sum` on 32-bit devices and 33% faster on 64-bit devices in creating the checksum, even if we are much more interested in the shorting the time of verifying the checksum, which is almost the same because the checksum is re-created and then compared.

However, specific implementations of md5sum can greatly vary in their performance and can be slower or faster depending on the use of `libcrypto.so` which gives the fastest implementation.

In SFOS, both `md5sum` and `sha1sum` are those from the busybox which does not recall the `libcrypto.so` among its dependencies.

The following tests cannot be affected by the disk reading performance because `busybox` and `bash` executables are just loaded in memory, and anyway they will be cached at the first reading, and a preliminary reading has been done, in fact, just in case:

```
[root@Xperia10II-DualSIM ~]# time bash -c \
'for i in $(seq 1 1000); do sha1sum /usr/bin/busybox >/dev/null; done'
real 0m 18.14s
user 0m 12.75s
sys 0m 3.34s
 
[root@Xperia10II-DualSIM ~]# time bash -c \
'for i in $(seq 1 1000); do md5sum /usr/bin/busybox >/dev/null; done'
real 0m 11.72s
user 0m 5.42s
sys 0m 4.28s
```

The results clearly indicated that `md5sum` is 1.55x faster than `sh1sum` in our default case.

---

### Differential backups

[Writing about backup](../forum/todo/users-backup-analysis.md), we noticed that some advanced command line utilities like `rsync` and `pigz` are missing from the root filesystem after the first boot, and they are missing as well from the recovery boot image.
