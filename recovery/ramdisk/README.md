## The recovery ramdisk

This folder contains - by now - just few scripts about early `init` process which are part of a broader recovery image rework.

- [init](init) - this is the first script that runs after the kernel
- [init.usb](init.usb) - this is the script that configure the USB gadget
- [init.hr](init.hr) - this is the script for the recovery mode if a USB connection is found
- [init.hb](init.hb) - this is the script for the normal boot mode, otherwise

The new recovery image is less than 1Mb bigger than the original while the boot partition is 64 Mb. There is a lot of space which is still available for future expansions and the [system debug package](../#about-sysdebug-package) is about 20 Mb uncompressed. The following sizes are shown in Kb, instead:

```
20616 hybris-recovery.img
21068 rfos-boot-image.img
```

This recovery image is plenty of fine-tuned¹ details, and includes an [image to display](../../forum/todo/recovery-telnet-phonescreen.jpeg) properly the IP address telnet message. Plus it automatically goes into recovery mode when the smartphone is connected to a laptop/PC USB but not if it is connected to a power source. Otherwise, it boots normally. Therefore it can be the default and the only one boot image.

The most interesting feature is that the image can be re-packaged and flashed on both `boot_a`, `boot_b` in just two seconds. The trick? The use of the SSH to flash the partitions: the recovery image can update itself.

Obviously, it can also delivers a restore of a previous backup for any partition, and it can also flash every partition even if an image is `spare`. A task that usually requires `fastboot` on the Laptop/PC installed and the smartphone in its special mode. Because the boot partitions can be updated with the `ADB` protocol - which seems much more reliable with USB v3.x-only hardware than `fastboot` - the full installation procedure can also be done via this recovery image. Potentially, the up/downgrade or a restore of the Android system can also be done in this way.

Hence, there are out there tools that have a good chance to collect dust in the future like fastboot, Sony Emma, XperiFirm, etc.

The day the recovery image will be able to establish a LTE or a WLAN connection², it can potentially do the entire SFOS {installation, recovery, restore, mainteinance, debugging, etc.} by remote also and in live with someone else from remote, properly authorized by an one-single-time-use RSA key. 

The final outcome is that we will connect our smartphone to our laptop/PC and ask for a reboot. Soon after, the smartphone will enter recovery mode, and potentially, with our browser, we can manage the entire system, including flashing partitions.

---

### A supervising firmware

In the [recovery image refactoring](../../forum/todo/recovery-image-refactoring.md) page was highlighted some shortcomings about the SailFish OS recovery image which properly reworked, instead, it rappresents a great opportunity to do much more stuff than a rare-events fallback minimal system but an ordinary tool for system mainteinance.

![](https://raw.githubusercontent.com/robang74/redfishos/main/forum/todo/recovery-telnet-phonescreen.jpeg)

Obviously, having a full suite of scripts that can run on `busybox ash` with no adaptation or a little of adaptation, make this image even more intriguing. On the long-term, we can see it as a supervising firmware composed by three main components: a monolithic Linux kernel dedicatd for a specific device, a full-features statically linked busybox and a minimal graphical interface like [yamui](https://github.com/robang74/yamui).

---

### A system configurations manager

About the first stage of the SailFish OS [refactoring](../../#about-sfos-refactoring) described in three points, the 1.2 is the combination of the 1.1 and 1.3 because when we have a recovery image always available that can run in RAM and manage filesystems and partitions, backups, and restores, applying a system patch is just a matter of keeping a local database of them and their backup. It is just a matter of perspective: 

- patch manager runs on SFOS and applies volatile patches on SFOS mainly for UI or system services like SSH which do not specifically require a reboot, or connman (in particular about firewalling rules), which require a SFOS utilities restart.

- system patch manager can run on the recovery image and therefore can safely handle any system patch before the SFOS boot or after its end of work.

You can object that a system patch manager, which is a set of shell scripts, forces the end-users to cope with a console, SSH, telnet, etc. but I never wrote that. I wrote that being able to operate with a bare minimum running system like shell scripts is a **must** for a system patch manager³. I never wrote that end-users should cope with a console but suggested that they use their laptop/PC browser which is not something immediate to develop but feasible in a reasonable terms.

*After all, Rome has not been built during a night, but block by block with a plan in mind.*

*After all, Rome has not been built during a night, but block by block with a plan in mind.*

---

**Notes**

1. Among those details, there is also the `telnet` menu item `4) Perform file system check` that is doing its duty properly now.

2. Rather than establishing an autonomous connection to the internet, much more practical and easier is leveraging the GNU/Linux laptop/PC as a proxy in such a way that the recovery image can have an Internet connection using the one available on the workstation, which seems more appropriate after all.

3. or a system configuration manager that can develop (or integrate) a IoT fleet manager as soon as the recovery image is able to access an Internet connection independently, which can be a technical challenge for a software/service company but not for vendors like Sony or Qualcomm. Again, it is just a matter of perspective.
