## SailFish OS refactoring (1st stage)

This is the [-1day pre-lauch announcement](../sfos-refactoring-announce.md) which contains a brief presentation of the project with the the current state (updated at 25th Jul 2023) of the tasks completion. In the following sections you can read  about the refactoring **first stage** of [four stages refactoring plan](../../README.md#about-sfos-refactoring).

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

There is no viable way to debug and fix SFOS until these three facilities will be fully functional in place unless you wish to waste your time as if you were an immortal highlander.

* **1st** - make the recovery image working because it is the starting point for everyone that seriously wants debugging / fixing their OS and for everyone that wishes to experiment with the system but having a quick recovery option. For this reason the recovery boot image should be the standard and only one. Obviously, the recovery boot mode should start ONLY when the users ask for it (*e.g.: USB cable connected at boot time could be a way*) or when the system is bricked badly (*e.g.: the UI cannot rise up, a file-format flag is set after a watchdog expired*).

* **2nd** - provide a reliable system patch manager because people who wants debug and fix their OS - included them - need to track down and revert the changes they made on the system otherwise every time is a start from scratch which currently means flash.sh because recovery does not even reset the system to SFOS factory state.

* **3rd** - provide a reliable back-up system to let everyone debug and fix their OS to quickly be back to a previous snapshot for users because the two points above should be a good starting point to deal with the root filesystem.

---

### About backup

The `rsync` is our friend but a script user-friendly interface is needed and moreover `rsync` is not available in the userdata image and cannot be installed until the device is registered with Jolla and related repositories are available.

This means that for OS early-boot hackers the `rsync` is not an immediate option to go for especially because also no internet access can be available. Therefore a backup / restore script suite to be useful on early-boot stages should necessarily rely on `tar` an `gzip` because also `pigz` nor `xz` are not available nor installable even if `xz-libs` are installed.

---

### Working in progress

Which is exactly what I am doing by now:

- A shell scripts suite for `tar`/`gzip` backup/restore has been tested but some more development and tests are needed (cfr. users backup section in the [Quick Start Guide](../quick-start-guide.md).

- A system patch manager by shell script that can un/apply permanent patches on rootfs has been used successfully to recover the system by a faulty patch installation but not released, yet

- A system patch manager last version patch downloader has been implemented and successfully tested but not released, yet. It creates also a list of patch installed on the system a repository of them for future recovery or removal even in emergency off-line cases and can restart system services or daemon on-demand using a [special formatted patch header](../knowhow/system-patch-manager-p1.md#technical-approach).

- Preparing the system for the first installation after having flashed the SFOS, a minimal debug suite tools and to adapt the recovery image to be the default one and working as it supposed to do, a minimal advanced tools suite for smart system backup and integrity check ([here](../../recovery/README.md)).

To be continued, stay tuned.
