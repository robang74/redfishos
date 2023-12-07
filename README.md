# RedFish OS

```diff
 
+ Refactoring SailFish OS while it is running on a Sony Xperia 10 II
 
```

**Update, 24.09.2023** - After having realised the potential of having an advanced rescue image, a fleet management tool, a supervising OS, and how far RedFish OS can be customised to bring added value to vendors, distributors, and professional modders of mobile devices, the refactoring of SailFish OS has been set aside.

Support for other smartphones like the Sony Xperia 10 III or IV, Gigaset GS5 and its variants, in particular the Rephone, can be added as long as concrete support is specifically received. While support for open hardware platforms like Pine64 or Librem smartphones can be added depending on the availability of developers and maintainers.

> :warning: **Warning**
> 
> Despite the same name, this project is **NOT** related to this one: [RedFishOS by Richard Guerci](https://redfish.github.io/redfish-os/).

---

### Index

1. [Fund raising](#fund-raising)
2. [About RedFish OS](#about-redfish-os)
3. [About Xperia 10 II](#about-xperia-10-ii)
4. [About SFOS refactoring](#about-sfos-refactoring)
5. [About SailFish OS](#about-sailfish-os)
6. [About Open Device program](#about-open-device-program)
7. [Useful documentation](#useful-documentation)
8. [List of components](#list-of-components)
9. [News and updates](#news--updates)
10. [Forum, no thanks](#forum)
11. [License](#license)

---

### Fund raising

As much as you are interested in this project, you can concretely support a specific task or just provide a free donation.

* [PayPal.me](https://www.paypal.com/paypalme/rfoglietta) to Roberto Foglietta aka @rfoglietta on PayPal Me platform
* [Donation Form](https://tinyurl.com/robang74) to Roberto Foglietta aka @robang74 on PayPal Italia

Roberto Foglietta is the document-id real persona name behind on-line `Roberto A. Foglietta` authorship brand, usually presented as:

      (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>

in the files headers, in the Change Logs, in the documents authorship or referal sections, on the websites footers, etc.

> :information_source: **Note**
> 
> The report of activities and related proof of expenses will be submitted only to those who contributed. On a regular basis: monthly, quarterly, or yearly, depending on the amount of support. Those nominative reports will be sent with the friendly clause to not publicly disclose those data before three years from the date of the report.

Keep visiting this page to be updated about the project evolution. Technical progression is reported in the [news and updates](#news--updates) section. 

---

### About RedFish OS

First of all, it is important to notice that this project does not aim to reach the end-user market directly. The RFOS marketing targets are the vendors, the distributors, the engineers, and the modders, including those who are doing such activities as hobbies. More information are available in the [marketing page](marketing.md).

Just to give you an idea: a Linux-based OS is about 1.5GB, while a modern Android system (10+) is about 2.5GB. The RedFish OS image is less than 30MB and includes the kernel with all the drivers compiled in, the vendor's binary firmwares, the command-line applications, and the networking services. The Sony firmware boot takes 20 seconds, while RedFish OS takes 5 seconds from when the Linux kernel starts to run and when all the services are ready.

To learn how your business can benefit from the RedFish OS adoption, check this [PDF presentation](RedFishOS-presentation-A4.pdf) introduced by a less than 200 words executive summary.

About the logo and the product branding, check the [logo folder](logo#redfish-os-logo). It contains the logo in several options, the pantones, the animation, how the textual menu interface presents itself and a couple of videos.

---

### About Xperia 10 II

The Sony Electronics Xperia 10 II has an easy grip due to its unusual long bar ratio OLED 6" display (1080x2520) equipped with an ARM64 8-cores @2GHz, 4GB of RAM and 128GB of internal flash storage with a real writing speed above 100MB/s. On the communication side, it is a LTE 4G with GNSS/AGPS/GPS subsystem that also supports the Galileo constellation with a firmware upgrade (tested and working).

The [Sony Xperia 10 II](https://www.gsmarena.com/compare.php3?idPhone1=10095&idPhone2=10698) (codename `pdx201`) is a mid-range smartphone which was announced in February 2020, released in May 2020 and included [in June 2020](https://developer.sony.com/posts/xperia-10-ii-added-to-sonys-open-devices-program/) in the [Sony Open Device program](https://developer.sony.com/open-source/aosp-on-xperia-open-devices).

---

### About SFOS refactoring

> :information_source: **Disclaimer**
> 
> Since the beginning, the first stage has been planned in such a way to put RFOS in the most independent position from Jolla Oy, not necessarily against their interests or their profit opportunities. This is because there is no reason to depend on a private company, or at least as little as possible, as short as possible. An approach that is good for the SFOS community because it brings more freedom for everyone wishing to continue using the apps developed for SFOS. Therefore, this project is **not** directly related to Jolla Oy nor with **any** of its business affiliates.

Refactoring the SFOS is the main aim of this project, and therefore it deserves a [dedicated page](forum/todo/sailfishos-refactoring-begins.md). In brief, the list of macro-activities for the **first stage**:

* 1.1. a recovery boot mode always available on-demand at users request or automatically when the system is badly bricked;

* 1.2. a system patch manager that can un/apply persistent patches on the root filesystem for system services configuration;

* 1.3. a early-boot backup/restore scripts suite with the related after-flashing system configuration shell script.
  

Without these facilities fully working, there is no reasonable chance to operate in a traceable and efficient way at OS level.

<sup>________</sup>

The **second stage** of the refactoring process can be divided into a few other macro-activities:

* 2.1. using the recovery image to create a basic root filesystem from scratch based on the full features of the busybox;

* 2.2. including an advanced RPM tool like `yum` in order to leverage the CentOS 8 and Fedora 31 repositories to install a set of packages that will create a fully working root filesystem back-compatible with the last available version (4.5.0.21) of SaiFish OS;

* 2.3. adding on top of the RedFish OS the Jolla software layer related to the graphics UI, apps markets, and Alien Dalvik support (optional) in order to provide a fully back-compatibility system, at least for the most significant SFOS apps currently available.

<sup>________</sup>

Regarding the **third stage**, the agenda is still not fully defined, but these macro-activities should be accounted for:

* 3.1. about the Jolla software layer, considering that `devel-su` and partially `silica` are closed source proprietary software that cannot be further developed, customised, bug-fixed, or adapted/ported without the support of Jolla Oy, a SWOT analysis needs to be conducted in order to evaluate alternatives that can reasonably support the apps developed for SFOS with a {zero, minimal, automatic} adaptation.

  > :information_source: **Note**
  > 
  > Thanks to Jonas Karlsson aka @Mohjive, [Glacier](https://nemomobile.net/glacier-home/) has been identified as an alternative UI that has not been evaluated yet.
  > Thanks to Jörg Wurzer [Cutie Shell](https://cutie-shell.org/) has been identified as an Open Source alternative to SFOS UI but it is still in alpha testing and declared not ready for end-users yet.

* 3.2. about the support for Android apps, a SWOT analysis needs to be conducted in order to evaluate alternatives to Alien Dalvik + MicroG and their effective impact in separating the RedFish OS from the SailFish OS user experience, as little as possible and, for the better, as much as possible.

  > :information_source: **Note**
  > 
  > Some SFOS end-users reported that [WayDroid](https://waydro.id/) can be a feasible alternative to Alien Dalvik, but currently it is not completely supported by SFOS which seems reasonable considering that SFOS is bounded with Alien Dalvik (included in the per-users-per-device paying licence) and SFOS runs on a customised root filesystem, which may imply a sort of adaptation or integration for WayDroid smooth functioning. While [AnBox](https://anbox.io/) was offering the container approach for running an Android system on a GNU/Linux distribution but unfortunately its development has been discontinued in favor of a cloud solution provided by Canonical. 

* 3.3. about the [SailJail](https://github.com/sailfishos/sailjail) based on [FireJail](https://github.com/netblue30/firejail) approach to constraining the apps privileges and user approval for accessing the hardware functionalities, a SWOT analysis needs to be conducted in order to evaluate a less work-intensive alternative.

  > :information_source: **Note**
  > 
  > At the moment, a SFOS app to be compliant with SailJail needs to use a limited set of API validated by Jolla. This approach has two great shortcomings, which are quite obvious: 1. the app developers are supposed to collaborate to keep SFOS secure and end-users data private; 2. the API validation is a skilled work-intensive task with hopfully frequently and never-ending updates. It is crystal clear that this design cannot scale up in any profitable nor sustainable way.

<sup>________</sup>

Finally, the **fourth stage** will be about:

* 4.1. developing and testing alternatives to every closed source software running on top of RedFish OS; 

* 4.2. granting a good enough bug-free maturity level, starting from the OS level up to the apps level;

* 4.3. moving in the direction to emancipate the hardware support from binary proprietary closed-source firmware and blobs mainly included in the AOSP trying to leverage the [DivestOS Mobile support for Sony smartphones](https://divestos.org/pages/devices):

    * [Sony Xperia XA2 and XA2 Ultra](https://www.gsmarena.com/compare.php3?idPhone1=8986&idPhone2=8985) (sony legacy, jolla supported)

    * [Sony Xperia 10 and 10 plus](https://www.gsmarena.com/compare.php3?&idPhone1=9353&idPhone2=9591) (sony legacy, jolla supported)

    * [Sony Xperia XZ2 and XZ3](https://www.gsmarena.com/compare.php3?idPhone1=9081&idPhone2=9232) (sony maintained)

    which unfortunately at the moment supports few [Sony Open Devices](https://developerworld.wpp.developer.sony.com/open-source/aosp-on-xperia-open-devices/get-started/supported-devices-and-functionality/) smartphones and not the most recent [supported by Jolla](https://shop.jolla.com/).

As you can see, the first stage is well defined in its aims and partially completed, while the others are progressively less and less granularly defined. As usual in modern project management best practises, the next stages of product development will be completely defined when the previous ones are completed.

Moreover, some tasks can be moved from the current stage to the next if a scope change or integration need arises. In the moment that some people join the developing team, a project management tool will be used.

<sup>________</sup>

#### Rationale about SFOS refactoring

> How to refactoring SFOS can be approached?

The most effective approach is:

- do **not** reinvent the wheel --> moving to a Linux distribution just supported by its community
- do **not** create further barriers --> choosing such distribution for binary compatibility
- do **not** create useless stress --> among those distributions choosing one that uses RPMs

These three points brings us to the conclusion that SFOS refactoring is necessary and it is the premise to keep it updated with as less as possible effort.

However, there are still in place 2 more HUGE issues:

- bring value for a customers niche to support a business and/or intercept interested developers
- deal with the closed source blobs which mainly are about hardware firmware and its support

This requires an architectural change of the system in order to introduce another PoV into this sector. Hence, the following question was: 

> what is missing and it would important to have?

A recovery image was missing, clearly. This lack has been fulfill. At least, I did. A recovery image is an essential tool for everything above but also a tool that have brought in another PoV, and this is its the most of its value. Because another PoV was more essential than a tool. Everything else was a mere conseguence.

---

### About SailFish OS

> :warning: **Warning**
> 
> The SailFish OS is **not** *open source* **nor** *software libre* but largely based on several FOSS projects.

* [SailFish OS on Wikipedia](https://en.wikipedia.org/wiki/Sailfish_OS)

Therefore, it cannot be *almost* redistributed AS-IS even if can be downloaded for free (gratis) from the Jolla Shop: 

* [Jolla SailFish OS shop](https://shop.jolla.com/) for downloading the image
* [Jolla how to flash SFOS with Linux](https://jolla.com/how-to-install-sailfish-x-on-xperia-10-ii-on-linux/) or its [backup](./Jolla)
* [SailFish OS official documentation](https://docs.sailfishos.org/) or its [mirror](https://github.com/robang74/docs.sailfishos.org)
* [SailFish OS official website](https://sailfishos.org/)

The paid licenced version adds support for Android apps, integrates the proprietary [Alien Dalvik](https://en.wikipedia.org/wiki/Dalvik_Turbo_virtual_machine) middleware framework, and some other features like support for Microsoft Exchange. Instead, the zero-budget version is supported by the SFOS community:

* [Community Forum](https://forum.sailfishos.org/)
* [Community apps repository](https://sailfish.openrepos.net/)
* [Patch Manager Web Catalog](http://coderus.openrepos.net/pm2/)
* [Patches by robang74](patches/README.md)

Few components in the SailFish OS are proprietary, and the package downloaded from Jolla shop contains such proprietary software and vendor firmware. While the framework to build the images is an Open Source project:

* [MER project Wiki page](https://wiki.merproject.org/wiki/Main_Page)

Some other proprietary software and vendor firmwares came from Sony Open Device AOSP. Instead, the boot images are compositions of binaries from open source and software libre projects only. Therefore, the boot images can be freely redistributed as long as those redistributing them fulfil the FOSS licence obligations related to those binaries.

> :information_source: **Note**
> 
> In case you wish to redistribute the SFOS images, the alternative to fulfilling those obligations by yourself is to link to this page, whose aim is to collect all those FOSS contributions. However, you have to check for yourself if this list of resources is complete and updated with respect to the boot image that you wish to distribute. Usually, it is not unless you have paid for it.

---

### About Open Device program

* [ASOP on Xperia Open Devices](https://developerworld.wpp.developer.sony.com/open-source/aosp-on-xperia-open-devices)
* [Open Devices at ix5.org](https://opendevices.ix5.org)

---

### Useful documentation

* [Sony Xperia flashing guide](forum/knowhow/flashing-tools-for-Xperia-phones.md) - Some practical knowledge about flashing tools.
* [Quick First Setup Guide](forum/quick-first-setup-guide.md) - A step-by-step guide for the first setup after SFOS flashing.
* [Quick Start Guide](forum/quick-start-guide.md) - An end-users step-by-step guide for a quick start with SailFish OS.
* [SFOS install on Xperias](https://gitlab.com/Olf0/sailfishX) - A guide for installing SailFish OS on Sony Xperias by Olf0.
* [de-google](https://github.com/robang74/degoogle) - A huge list of alternatives to Google products. Privacy tips, tricks, and links.
* [Awesome SFOS](https://github.com/robang74/awesome-sailfishos) - A curated list of awesome Sailfish OS resources.
* [Equivalents in SFOS](https://github.com/robang74/equivalentsinsailfish): A list of Android apps and their Sailfish equivalents.
* [FAQ for SFOS porting guide](https://github.com/robang74/hadk-faq) - A collection of knowledge about the HADK guide.
* [SFOS community forum know-how](./forum/README.md) - A collection of yet unorganised posts and documents.
* [SFOS rootfs integrity check](4.5.0.21/README.md) - An analysis about how to keep root filesystem changes under control.

---

### List of components

* [hybris boot](https://github.com/robang74/hybris-boot) - This project enables the building of boot images for Google Android fastboot based devices.
* [yamui](https://github.com/robang74/yamui) - Yet Another Minimal UI. Tool for displaying graphical notifications in minimal environments like early boot/initrd, build-able by Github action :exclamation:
* [busybox for SFOS](https://github.com/robang74/sailfish-os-busybox) - The busybox config and RPM spec for SailFish OS, buildable by Github action :exclamation:
* [fsck.auto](https://github.com/robang74/fsck.auto) - This is a simple b/ash script for busybox fsck.auto to check the block device partition file system type.
* [Patch Manager](https://github.com/robang74/patchmanager) - The Patch Manager page in Settings:System for Sailfish OS, buildable by Github action :exclamation:
* [lipstick](https://github.com/robang74/lipstick) - The lipstick aims to offer an easy to modify user experiences for varying mobile device form factors, e.g. handsets, netbooks, tablets. User interface components are written in [QML](https://doc.qt.io/qt-6/qml-tutorial.html). Here is an example of a QML application: [home example](https://github.com/robang74/lipstick-example-home). Here is another simple one with instructions: [hello world](https://github.com/robang74/hello-world-for-sailfish).
* [device tree](https://github.com/robang74/android_device_sony_pdx201) - The device tree for the Sony Xperia 10 II
* [vendor's blobs](https://github.com/robang74/proprietary_vendor_sony_pdx201) - Vendor's proprietary blobs for the Sony Xperia 10 II
* [patches by ichthyosaurus](https://github.com/robang74/sailfish-public-patch-sources) - Sources for all ichthyosaurus Sailfish OS patches
* [Waydroid packaging](https://github.com/robang74/waydroid) - Waydroid packaging for Sailfish OS
* [SailJail sandbox](https://github.com/robang74/sailjail) - SailJail is a thin Firejail wrapper, and its command is used to create Sailfish OS application sandboxes.
* [SailJail permissions](https://github.com/robang74/sailjail-permissions) - SailFish OS application sandboxing and permissions system built on top of FireJail.This project enables the building of boot images for Google Android fastboot based devices.
* [mce-tools](https://github.com/robang74/mce) - mcetool command line executable to set some SailFish OS parameters about timeouts and power management.
* [Advanced Camera](https://github.com/robang74/harbour-advanced-camera) - Advanced Camera application for SailFish OS.
* [Sony Open Telephony](https://github.com/robang74/SonyOpenTelephony) - A boot-time modem flasher for the appropriate firmware configurations for SIMs subscriptions.
* [ofono fork](https://github.com/robang74/ofono) - An oFono fork with QRTR support, the Qualcomm IPC router protocol, which is used to communicate with services provided by other hardware blocks in the system.
* [connman iptables](https://github.com/robang74/sailfish-connman-plugin-iptables) - The connman plugin that provides a d-bus API for controlling iptables rules. 
* [Github actions for SFOS apps](https://github.com/robang74/github-sfos-apps-build) - Github actions for building SailFish OS apps  :exclamation:
* [SailFish OS git repositories](https://github.com/sailfishos) - A collection of 907 github repositories about SailFish OS.
* [SailFish OS git mirrors](https://github.com/sailfishos-mirror) - A collection of 517 github repository mirrors for SailFish OS.
* [SailFish OS porting](https://gitlab.com/sailfishos-porters-ci) - Gitlab page that contains several unofficial SFOS portings.
* [Hello Volla repositories](https://github.com/HelloVolla) - A collection of 42 github repositories and mirrors for SailFish OS.
* [Sony Xperia repositories](https://github.com/sonyxperiadev) - A collection of 212 github repositories about Sony Xperia devices.
* [SFOS dcaliste repositories](https://github.com/dcaliste) - A collection of 61 github repositories about SFOS various components.
* [CPU governor manager for SFOS](https://github.com/robang74/zgovernor) - A mirror of a github project dedicated to a CPU power management.

---

### Older versions

> ### :warning: WARNING
>
> For its own P2P nature, there is no way to grant that the image downloaded is the original one unless you have a couple of strong hashes based on different algorithms of the original image that allow you to check such a download within a reasonable range of security. By the way, the same applies for every download from an untrusted website (no https, ssl off-loading, man-in-the-middle), and sometimes also for those in https that have been hacked. As you can imagine, this implies almost every piece of software that we are currently running on our system. Hence, IT is an act of trust (demanding computation and sharing data) as much as any other religion... LOL.

* [Sailfish OS older versions images](https://github.com/robang74/sailfish-os-torrents/tree/main) - A list of torrents files that might provide older SailFish OS images.

---

### News & updates

After the first stage was completed, the review of the backlog suggested that RedFish OS can offer huge opportunities by itself and not as a refactoring project. Therefore it started a phase of marketing specifically oriented to technical people:

* 24.09.2023, [RedFish OS marketing page](marketing.md) for engineers, developers and professional modders.

Please check the [same section](https://github.com/robang74/redfishos/tree/devel#news--updates) in the `devel` branch for a more up-to-date list. The following is about those development that are push in `main` for the users.

* 31.08.2023, [RedFish OS project first stage](#about-sfos-refactoring) **completed**.

  **description**: the RedFish OS project first stage has been completed: marketing starts.

* 31.08.2023, [RedFish OS recovery image](recovery/ramdisk#a-tool-for-factory-reset)

  **description**: the RedFish OS recovery image can install SailFish OS and prepare its 1st boot.

  **status**: ready for advanced users adoption, but it is not publicly available.

* 29.08.2023, [RedFish OS recovery image](recovery/ramdisk#a-multi-boot-image)

  **description**: the RedFish OS recovery image can boot SailFish OS in normal mode (no USB data link).

  **status**: ready for advanced users adoption, but it is not publicly available.

* 26.08.2023, [RedFish OS recovery image](recovery/ramdisk#the-binary-compatibility)

  **description**: the RedFish OS recovery image supports CentOS and SFOS apps running, both.

  **status**: ready for advanced users adoption, but it is not publicly available.

* 24.08.2023, [RedFish OS recovery image](recovery/ramdisk#quality-and-scalability)

  **description**: the RedFish OS recovery image reached the levels of quality and scalability targeted.

  **status**: ready for advanced users testing, but it is not publicly available.

* 21.08.2023, [RedFish OS recovery telnet menu](recovery/ramdisk#the-recovery-menu-on-telnet)

  **description**:  the RedFish OS recovery menu has been re-organised, some items need to be worked deeply.

  **status**: ready for advanced users adoption, telnet recovery menu has a new style.

* 19.08.2023, [RedFish OS logo and animation](logo#redfish-os-logo)

  **description**:  the RedFish OS logo has been created and added to the recovery image with animations.

  **status**: ready for advanced users adoption, telnet recovery menu has been reworked.

* 18.08.2023, [RedFish OS recovery image](recovery/ramdisk/#the-recovery-ramdisk) 

  **description**: this boot image check for a USB data connection with a Laptop/PC for deciding about going for the recovery or normal boot mode

  **status**: ready for advanced users adoption, supports restore and backup shell scripts suite.

* 15.08.2023, [user and system backup suite](scripts/pcos#the-users-and-system-backup-suite)

  **description**: this shell scripts running on the laptop/PC provide backup and restore capabilities by SSH via USB.

  **status**: ready for advanced users adoption, full root filesystem backup in 1 minute.

* 12.08.2023, [system patch manager suite](scripts/sfos#system-patch-manager-suite)

  **description**: the system patch manager scripts suite in its basic features has been completed.

  **status**: ready for advanced users usage, in particular about the Patch Manager role overlapping.

* 08.08.2023, [RedFish OS suite installation](scripts/README.md#installation)
* 08.08.2023, [udhcpd tether config fixing patch](patches/udhcpd-tether-config-fixing/description.md)
* 08.08.2023, [system patches reworked and updated](patches/README.md)
* 08.08.2023, [patch downloader and installer](scripts/README.md)

  **description**: patch downloader and installer integrated into the RFOS scripts suite + DHCP service fixed.

  **status**: ready for advanced users adoption, add CentOS repositories, patch remover yet to do.

* 06.08.2023, [patch downloader and installer](scripts/README.md)

  **description**: patch downloader and installer alpha-development completed.

  **status**: ready for advanced users testing, patch remover yet to do.

* 05.08.2023, [RedFish OS suite installation](scripts/README.md#installation)

    **description**: the scripts suite has two distinct instances workstation and mobile device.

    **status**: ready for advanced users testing, on-the-fly installation script.

* 03.08.2023, [first boot setup after flashing](scripts/README.md)

    **description**: shell scripts suite for the first boot setup after flashing.

    **status**: ready for advanced users adoption.

* 01.08.2023, [sysdebug and recovery tarballs](recovery/README.md)

    **description**: shell scripts that produce tarballs for debugging and recovering.

    **status**: ready for advanced users testing.

* 31.07.2023, [all .md files: content review and reorganisation, v3](https://github.com/robang74/redfishos/commit/d28fae223e2be655e5adf46d986abd83d05cb26d)

    **description**: review and reorganisation of all .md files collected since the beginning.

    **status**: ready for everybody, documents collection continues. 

* 25.07.2023, this repository has been public and the RedFish OS project launched.

* 21.07.2023, [busybox v1.36.1+git2-raf3 for SFOS](https://github.com/robang74/sailfish-os-busybox#readme)

    **description**: full features static and dynamic linked busybox build RPMs correctly for all the architectures.

    **status**: ready for advanced users testing.

* 13.07.2023, [github SFOS apps build](https://github.com/robang74/github-sfos-apps-build)

    **description**: github action for building SailFish OS apps and other RPM packages.

    **status**: ready for app developers, easy to deploy, with SDK 4.5.0.16 container mirror.

* 12.07.2023, this repository has been created as a private project.

* 01.07.2023, a Jolla SFOS license bought to install the Android Support.

* 26.05.2023, a second hand Sony Xperia 10 II arrived in excellent conditions.

---

### Forum, no thanks

RedFish OS will probably (*never say never*) never have a dedicated forum, and the reason is that the "*forum*" is a Latin word that, in its etymological roots, is equivalent to "*agorà*" in ancient Greek meaning: a public physical place where people living in the same geographical area are used to meet each other for a variety of social activities, and not all of those activities are reputable as good, also for the moral and ethical of that time.

Therefore, if you like the "forum" concept, embrace it in its original meaning and go out of your home or office and make friends in the real world. The only reasonable way to use a platform like a virtual e-forum is to use it as a wiki or a bulletin board, and also for these purposes, it is not the best tool because it easily drives people out of their tracks. In fact, in a virtual environment, the social dynamics are different.

**Update, 24.09.2023** - The plan for SFOS refactoring has been set aside, as stated at the beginning of this page, and therefore every need for dealing with any e-forum platform is gone, completely.

---

### License

Almost all the files are under one of many FOSS licenses, and the others are in the public domain. Instead, the composition of these files is protected by the GPLv3 license under the effects of the Copyright Act, title 17. U.S.C. § 101.

> Under the Copyright Act, a compilation [EdN: "composition" is used here as a synonym because compilation might confuse the technical reader about code compiling] is defined as the "collection and assembling of preexisting materials or of data [EdN: data includes source code, as well] that are selected in such a way that the resulting work as a whole constitutes an original work of authorship."

This means, for example, that everyone can use a single MIT-licensed file or a part of it under the MIT license terms. Instead, using two of them or two parts of them implies that you are using a subset of this collection, which is a derived work of this collection, which is licensed under the GPLv3 too.

The GPLv3 license applies to the composition unless you are the original author of a specific, unmodified file. This means that everyone who can legally claim rights to the original files maintains those rights, obviously. Therefore, the original authors do not need to undergo the GPLv3 license applied to the composition, and they maintain their original rights in full. Unless they use the entire composition or a part of it for which they had no rights before.

Some files, documents, software, or firmware components can make an exception to the above general approach due to their specific copyright and license restrictions. In doubt, follow the thumb rule of fair use. Here is a list of them:

* Vendor's proprietary blobs for Sony Xperia 10 II ([github repository fork](https://github.com/robang74/proprietary_vendor_sony_pdx201))
* Jolla's copyright backup documentation ([Jolla folder](Jolla#about-jolla-folder))
* RedFish OS logo which is all rights reserved and a trademark ([logo folder](logo#redfish-os-logo))
* RedFish OS recovery www folder content which is all rights reserved ([www folder](recovery/ramdisk/var/www#about-www-folder))

For further information or requests about licensing and how to obtain a fork suitable for your own business, please write to the project maintainer and copyleft owner:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 💙 [Roberto A. Foglietta](roberto.foglietta@gmail.com)

**Have fun!** R-
