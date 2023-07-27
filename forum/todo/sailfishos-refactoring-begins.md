## SailFish OS refactoring (1st stage)

This is the [launch announcement](../sfos-refactoring-announce.md) which contains a brief presentation of the project with the current state (updated at 25th Jul 2023) of the tasks completion. In the following sections you can read  about the refactoring **first stage** of [four stages refactoring plan](../../README.md#about-sfos-refactoring).

> :information_source: **Disclaimer**
>
> Since the beginning, the first stage has been planned in such a way to put RFOS in the most independent position from Jolla Oy - not necessarily against their interests or their profit opportunities - but because there is no reason to depend on a private company or at least as little as possible. An approach that is good for the SFOS community also because it brings more freedom for everyone wishing to continue using the apps developed for SFOS. Therefore this project is **not** directly related to Jolla Oy nor with **any** of its business affiliates.

---

### Current limitations

The current recovery image does not work on Xperia 10 II and moreover, it clearly show an early stage of development compared with the users expectations:

> **Seven.of.nine** wrote:
>
> A boot manager on the phone would be really great, that asks the user to boot the phone into normal mode or into rescue mode on powering up the phone, like a linux computer has it.
>
>Surely this could easily be implemented, because `/boot/hybris-recovery.img` is present on the phone.
>
>Worth a feature request? Or possible to be implemented by the community to not demand Jollas limited resources too much?

AFAIK, the recovery image is not present on the phone but delivered into the package which can be downloaded from the Jolla shop. Unfortunately, it seems almost useless at least on Xperia 10 II.

> **Seven.of.nine** wrote:
>
> When booting the recovery mode on the phone and using a BT keyboard, then rescue operations could be done without having a computer.

AFAIK, no because there is no reasonable way to deal with the display after the recovery boot, e.g. cfr. `yamui` part in the link above. Also the telnet IPv4 address is not shown properly in a manner that can be read easily.

---

### More in general

There is no viable way to refactoring SFOS until these three facilities will be fully functional and in their place, unless you wish to waste your time as if you were an immortal highlander:

* **1st** - making the recovery image working because it is the starting point for everyone that seriously wants to debug & fix their OS and for everyone that wishes to experiment with the operative system but having a quick recovery option. For this reason the recovery boot image should be the standard and only one. Obviously, the recovery boot mode should start ONLY when the users ask for it (*e.g.: USB cable connected at boot time*) or when the system is bricked badly (*e.g.: the UI cannot rise up, a file-format flag is set after a watchdog expired*).

* **2nd** - providing a reliable System Patch Manager because people who wants debug & fix their SFOS need to track down and revert the changes they made on the system otherwise every time is a start from scratch which currently means using `flash.sh` because recovery does not even reset the system to SFOS factory state.

* **3rd** - providing a fast and reliable back-up system to let everyone debug & fix their SFOS to quickly revert it to a previous snapshot, including the home folders for every user enabled and for the root filesystem, as well.

---

### About backup

The `rsync` is our friend but a script user-friendly interface is needed and moreover `rsync` is not available in the userdata image and cannot be installed until the device is registered with a Jolla account and the related repositories are made available and fetched.

This means that for SFOS early-boot hackers the `rsync` is not an immediate option to go for especially because the internet access can be unavailable. Therefore a backup & restore script suite available on early-boot stage should necessarily rely on `tar` an `gzip` because also `pigz` and `xz` are unavailable nor installable even if `xz-libs` are installed by default.

---

### Working in progress

Considering the shortcomings above and the related needs, the following is going to be provided:

- A shell scripts suite using `tar` and `gzip` for backup & restore has been tested but some more development is needed (cfr. users backup section in the [Quick Start Guide: users backup](../quick-start-guide.md#user-backup).

- A System Patch Manager provided by shell script suite that can un/apply permanent patches on root filesystem has been used successfully to recover the system by a faulty patch installation but not released, yet

- A shell script for downloading automatically the last version of patch has been implemented and successfully tested. It also creates a list of patches that can be installed on the system and a repository of them for future needs of recovering or removing even in emergency off-line cases. This script can on-demand restarting the system services configured by the patch using a [special formatted patch header](../knowhow/system-patch-manager-p1.md#technical-approach).

- A shell script for automatising the first installation after having flashed the SFOS has been developed and it is under testing.

- A minimal suite of tools which immediately after the `flash.sh` first reboot can be installed in order to provide `pigz` and `rsync` to speed up the system data recovery as fast as possible, has been created and tested about shared library dependencies fulfillment. Moreover, it can be created automatically using a shell script running on any GNU/Linux distribution with Internet access.

- A more comprehensive suite of tools for advanced system, application and network debugging has been created and tested about shared library dependencies fulfillment. Also this suite can be created by a shell script running on any GNU/Linux distribution with Internet access.

Almost of this material is available in the [recovery folder](../../recovery/README.md). To be continued, stay tuned :exclamation:
