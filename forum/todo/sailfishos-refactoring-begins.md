## SailFish OS refactoring (1st stage)

This is the [launch announcement](../sfos-refactoring-announce.md) which contains a brief presentation of the project with the current state (updated at 25th Jul 2023) of the progress of the tasks in the list (backlog).

> :information_source: **Disclaimer**
>
> Since the beginning, the first stage has been planned in such a way to put RFOS in the most independent position from Jolla Oy - not necessarily against their interests or their profit opportunities - but because there is no reason to depend on a private company or at least as little as possible. An approach that is good for the SFOS community because it brings more freedom for everyone wishing to continue using the apps developed for SFOS. Therefore, this project is **not** directly related to Jolla Oy nor with **any** of its business affiliates.

In the following sections, you can read about the refactoring **first stage** of the [four stages refactoring plan](../../README.md#about-sfos-refactoring).

---

### Current limitations

The current recovery image does not work on the Xperia 10 II and moreover, it clearly shows an early stage of development compared with the users' expectations.

> @Seven.of.nine wrote:
>
> A boot manager on the phone would be really great, that asks the user to boot the phone into normal mode or into rescue mode on powering up the phone, like a linux computer has it.
>
>Surely this could easily be implemented, because `/boot/hybris-recovery.img` is present on the phone.
>
>Worth a feature request? Or possible to be implemented by the community to not demand Jollas limited resources too much?

AFAIK, the recovery image is not present on the phone but delivered into the package, which can be downloaded from the Jolla shop. Unfortunately, it seems almost useless, at least on the Xperia 10 II.

> @Seven.of.nine wrote:
>
> When booting the recovery mode on the phone and using a BT keyboard, then rescue operations could be done without having a computer.

AFAIK, the answer is no because there is no reasonable way to deal with the display after the recovery boot, e.g. cfr. `yamui` part in the link above. Also, the telnet IPv4 address is not shown properly in a manner that can be read easily.

---

### More in general

There is no viable way of refactoring SFOS until these three facilities are fully functional and in their place, unless you wish to waste your time as if you were an immortal highlander:

* **1st** - make the recovery image work because it is the starting point for everyone who seriously wants to debug and fix their OS and for everyone who wishes to experiment with the operating system but has a quick recovery option. For this reason, the recovery boot image should be the standard and only one. Obviously, the recovery boot mode should start ONLY when the users ask for it (*e.g.: USB cable connected at boot time*) or when the system is bricked badly (*e.g.: the UI cannot rise up, a file-format flag is set after a watchdog expires*).

* **2nd** - providing a reliable System Patch Manager because people who want to debug and fix their SFOS need to track down and revert the changes they made to the system; otherwise, every time is a start from scratch, which currently means using `flash.sh` because recovery does not even reset the system to its factory state.

* **3rd** - providing a fast and reliable backup system to let everyone debug and fix their SFOS to quickly revert it to a previous snapshot, including the home folders for every user enabled and for the root filesystem as well.

---

### About backup

The `rsync` is our friend, but a script with a user-friendly interface is needed, and moreover, the `rsync` is not available in the userdata image and cannot be installed until the device is registered with a Jolla account and the related repositories are made available and fetched.

This means that for SFOS early-boot hackers, the `rsync` is not an immediate option to go for, especially because internet access can be unavailable.

Therefore, a backup and restore script suite available at the early-boot stage should necessarily rely on `tar` and `gzip` because `pigz` and `xz` are neither available nor installable, even if `xz-libs` are installed by default.

---

### Working in progress

Considering the shortcomings above and the related needs, the following is going to be provided:

- A shell scripts suite using `tar` and `gzip` for backup and restore has been tested, but some more development is needed (cfr. the users backup section in the [Quick Start Guide: Users Backup)(../quick-start-guide.md#user-backup).

- A System Patch Manager provided by a shell script suite that can un/apply permanent patches to the root filesystem has been successfully used to recover the system from a faulty patch installation but has not yet been released.

- A shell script for downloading the last version of the patch has been implemented and successfully tested. It also creates a list of patches that can be installed on the system and a repository of them for future recovery or removal, even in emergency off-line cases. This script can on-demand restart the system services configured by the patch using a [special formatted patch header](../knowhow/system-patch-manager-p1.md#technical-approach).

- A shell script for automating the first installation after having flashed the SFOS has been developed and is under testing.

- For the fulfilment of shared library dependencies, a minimal suite of tools that can be installed immediately after the 'flash.sh' first reboot in order to provide 'pigz' and 'rsync' to speed up the system's data recovery as quickly as possible has been created and tested. Moreover, it can be created automatically using a shell script running on any GNU/Linux distribution with Internet access.

- A more comprehensive suite of tools for advanced system, application, and network debugging has been created and tested for the fulfilment of shared library dependencies. Also, this suite can be created by a shell script running on any GNU/Linux distribution with Internet access.

Almost all of this material is available in the [recovery folder](../../recovery/README.md). To be continued, stay tuned :exclamation:

---

### News & updates

* 01.08.2023, [1st-boot setup after flashing](https://github.com/robang74/redfishos/blob/main/scripts/pcos/README.md) - shell scripts suite available for advanced users testing
