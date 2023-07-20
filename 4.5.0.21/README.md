## SailFish OS root filesystem

There are many ways to detect changes on a filesystem and keeping the changes of the root filesystem under strict control is essential to carry on any serious debug activity. Even if this is not a strictly requirement, it is something that can help a lot expecially when the systems are smartphones in the hands of end-users or apps-developers which may lack of system administration skills and it is absolutely reasonable that they lack of that skills. Otherwise the referring market sector will be too small to be profitable.

#### Newer than a reference file

The most straigforward is using `find` with the option `-newer` which requires a reference file and the choose of that reference is the almost the only thing that affects the result:

```
find $(cat root-dir-folders-list.txt) -newer config/usb_gadget/g1/idProduct
```

This example seems to work. However, without an analisys we do not know when or if the reference file will be updated and this is clearly a sweak point of this approach. Obviously, we can circumvent this shortcoming creating a specific reference file which we will be never updated anymore. Again, this is a supposition because into a RW filesystem cannot provide us that grants even if we reset the all the writing permission: it will be less probable that it will happen by mistake but it is not an assumption that can be granted by itself alone.

Moreover, we are used to rely on the assumption that the system date and time are always correct and reasonably updated. It is not true in the most general case: an embedded system may not have an RTC which keeps the timeflow when the system is powered-off and this is also true for smartphone when the system goes down because the battery is completely discharged.

Usually, it does not happen that a smartphone reach the 0% of the battery. In fact, I saw SFOS shutting down at 2% of battery which is enough to keep the internal RTC working for a decent long period of time. Despite this, at the first boot without any network connection active and no any way to synchronise the date/time there is no any chance to fully trust the system time.

A possible solution is to create the reference file as `/etc/.reference/.file` with `-r--r--r--` permissions set and provide a backup tarball for it in such a way time/date can be restored or check at any time in the future. Instead, there is no a definitive solution about the RTC time flowing but at least about making the time/data flow a monotonic function saving at shutdown the last date/time to read it at the next reboot. This also fail when the user act on the hardware keys to force an emergency immediate shutdown. An alternative approach is to find into filesystem the most recent file/folder and use such date/time in case it is newer than the current date/time.


