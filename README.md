# RedFish OS

```diff
+ Refactoring SailFish OS 4.5.0.21 while it is running on a Sony Xperia 10 II smartphone.
```

Support for other smartphones like Sony Xperia 10 III or IV, Gigaset GS5 and its variants in particular the Volla and the Rephone ones, could be added as far as concrete support and mainteners will be available.

> :warning: **Warning**
> 
> this project is **NOT** related to this one: [RedFishOS by Richard Guerci](https://redfish.github.io/redfish-os/).

---

### Fund raising

As much as you are interested in this project, you can concretely support a specific task or just provide a free donation.

* [PayPal.me](https://www.paypal.com/paypalme/rfoglietta) to Roberto Foglietta aka @rfoglietta on PayPal Me platform
* [Donation Form](https://tinyurl.com/robang74) to Roberto Foglietta aka @robang74 on PayPal Italia

Roberto Foglietta is the document-id real persona name behind on-line `Roberto A. Foglietta` authorship brand, usually presented as:

```
(C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
```

in the files headers, in the ChangeLogs, in the documents authorship or referal sections, at the end of websites, etc.

> :information_source: **Note**
> 
> The report of activities and related proof of expenses will be submitted to those contributed, only. On a regular basis monthly, quarterly or yearly depending on the amount of support they trusted to delegate to my management. Those nominative reports will be sent with the friendly clause to not publicly disclose those data before three years the date of the report.

---

### About SFOS refactoring

Refactoring the SFOS is the main aim of this project and therefore it deserves a [dedicated page](forum/todo/sailfishos-refactoring-begins.md), in brief:

1. a recovery boot mode always available on-demand at users request or automatically when the system is badly bricked;
2. a system patch manager that can un/apply persistent patches on the root filesystem for system services configuration;
3. a early-boot backup/restore script suite with the related after-flashing system configuration shell script.

Without these facilities fully working, there is no reasonable chance to operate in a traceable and efficient way at OS level. Everything else will follow and be added here depending also on the supporters and contributors agendas.

---

### About SailFish OS

> :warning: **Warning**
> 
> __Warning__: the SailFish OS is **not** *open source* **nor** *software libre* but largely based on several FOSS projects.

* [SailFish OS on Wikipedia](https://en.wikipedia.org/wiki/Sailfish_OS)

Therefore it cannot be *almost* redistributed AS-IS even if can be downloaded for free (gratis) from the Jolla Shop:  

* [Jolla SailFish OS shop](https://shop.jolla.com/) for downloading the image
* [Jolla how to flash SFOS with Linux](https://jolla.com/how-to-install-sailfish-x-on-xperia-10-ii-on-linux/) or its [backup](./Jolla)
* [SailFish OS official documentation](https://docs.sailfishos.org/) or its [mirror](https://github.com/robang74/docs.sailfishos.org)
* [SailFish OS official website](https://sailfishos.org/)

The paid licensed version adds the support for Android integrating the proprietary [Alien Dalvik](https://en.wikipedia.org/wiki/Dalvik_Turbo_virtual_machine) middle-ware framework plus some others features. The zero-budget version is supported by its related community:

* [Community Forum](https://forum.sailfishos.org/)
* [Community apps repository](https://sailfish.openrepos.net/)
* [Patch Manager Web Catalog](http://coderus.openrepos.net/pm2/)

Few components in SailFish OS are proprietary and the package downloaded from their shop contains such proprietary software and vendor firmware. The framework to build the images is an open source project:

* [MER project Wiki page](https://wiki.merproject.org/wiki/Main_Page)

Some other proprietary software and vendor firmwares came from Sony Open Device AOSP. Instead, the boot images are compositions of binaries from open source and software libre projects, only. Therefore the boot images can be freely redistributed as long as those redistributing them fulfil the FOSS licenses obligations related to that binaries. 

> :information_source: **Note**
>
> The alternative to fulfill by yourself those obligations is to link this page which the aim is to collect all those FOSS contributions. However, you have to check by yourself if this list of resources is complete and updated with respect to the boot image that you wish to distribute.

---

### About Xperia 10 II

The Sony Xperia 10 II (codename `pdx201`) is a mid-range smartphone from Sony. It was announced in February 2020 and released in May 2020 and it [has been added](https://developer.sony.com/posts/xperia-10-ii-added-to-sonys-open-devices-program/) on Sony Open Device program in June 2020.

---

### About Open Device program

* https://developerworld.wpp.developer.sony.com/open-source/aosp-on-xperia-open-devices

* https://opendevices.ix5.org

---

### Useful documentation

* [Sony Xperia flashing guide](forum/knowhow/flashing-tools-for-Xperia-phones.md) - Some practical knowledge about flashing tools.

* [Quick First Setup Guide](forum/quick-first-setup-guide.md) - A step-by-step guide for the first setup after SFOS flashing.

* [Quick Start Guide](forum/quick-start-guide.md) - An end-users step-by-step guide for a quick start with SailFish OS.

* [SFOS install on Xperias](https://gitlab.com/Olf0/sailfishX) - A guide for installing SailFish OS on Sony Xperias by Olf0.

* [de-google](https://github.com/robang74/degoogle) - A huge list of alternatives to Google products. Privacy tips, tricks, and links.

* [Awesome SFOS](https://github.com/robang74/awesome-sailfishos) - A curated list of awesome Sailfish OS resources.
  
* [Equivalents in SFOS](https://github.com/robang74/equivalentsinsailfish): A list of Android apps and their Sailfish equivalents.

* [FAQ for SFOS porting guide](https://github.com/robang74/hadk-faq) - A collection of knowledge about HADK guide.

* [SFOS community forum know-how](./forum/README.md) - A collection of yet un-organised posts and documents.

* [SFOS rootfs integrity check](4.5.0.21/README.md) - An analysis about how to keep root filesystem changes under control.

---

### List of components available on Github

* [hibrys boot](https://github.com/robang74/hybris-boot) - This project enables the building of boot images for Google Android fastboot based devices.

* [yamui](https://github.com/robang74/yamui) - Yet Another Minimal UI. Tool for displaying graphical notifications in minimal environments like early boot/initrd, build-able by Github action :exclamation:

* [busybox for SFOS](https://github.com/robang74/sailfish-os-busybox) - The busybox config and RPM spec for SailFish OS, buildable by Github action :exclamation:

* [fsck.auto](https://github.com/robang74/fsck.auto) - This is a simple b/ash script for busybox fsck.auto to check block device partition file system type.

* [Patch Manager](https://github.com/robang74/patchmanager) - The Patch Manager page in Settings:System for Sailfish OS, buildable by Github action :exclamation:

* [lipstick](https://github.com/robang74/lipstick) - The lipstick aims to offer an easy to modify user experiences for varying mobile device form factors, e.g. handsets, netbooks, tablets. User interface components are written in [QML](https://doc.qt.io/qt-6/qml-tutorial.html). Here is an example of a QML application: [home example](https://github.com/robang74/lipstick-example-home). Here is another simple one with instructions: [hello world](https://github.com/robang74/hello-world-for-sailfish).

* [device tree](https://github.com/robang74/android_device_sony_pdx201) - The device tree for the Sony Xperia 10 II

* [vendor's blobs](https://github.com/robang74/proprietary_vendor_sony_pdx201) - Vendor's proprietary blobs for Sony Xperia 10 II

* [patches by ichthyosaurus](https://github.com/robang74/sailfish-public-patch-sources) - Sources for all ichthyosaurus Sailfish OS patches

* [Waydroid packaging](https://github.com/robang74/waydroid) - Waydroid packaging for Sailfish OS

* [SailJail sandbox](https://github.com/robang74/sailjail) - SailJail is a thin Firejail wrapper and it command is used to create Sailfish OS application sandboxes

* [SailJail permissions](https://github.com/robang74/sailjail-permissions) - SailFish OS application sandboxing and permissions system built on top of FireJail.This project enables the building of boot images for Google Android fastboot based devices.

* [mce-tools](https://github.com/robang74/mce) - mcetool command line executable to set some SailFish OS parameters about timeouts and power management.

* [Advanced Camera](https://github.com/robang74/harbour-advanced-camera) - Advanced Camera application for SailFish OS.

* [Sony Open Telephony](https://github.com/robang74/SonyOpenTelephony) - A boot-time modem flasher for the appropriate firmware configurations for SIMs subscriptions.

* [ofono fork](https://github.com/robang74/ofono) - An oFono fork with QRTR support, the Qualcomm IPC router protocol which is used to communicate with services provided by other hardware blocks in the system.

* [connman iptables](https://github.com/robang74/sailfish-connman-plugin-iptables) - The connman plugin that provides d-bus API for controlling iptables rules. 

* [Github actions for SFOS apps](https://github.com/robang74/github-sfos-apps-build) - Github actions for building SailFish OS apps  :exclamation:

* [SailFish OS git repositories](https://github.com/sailfishos) - A collection of 907 git repositories about SailFish OS.

* [SailFish OS git mirrors](https://github.com/sailfishos-mirror) - A collection of 517 git repository mirrors for SailFish OS.

* [SailFish OS porting](https://gitlab.com/sailfishos-porters-ci) - Gitlab page that contains several unofficial SFOS portings.

---

## License

Almost all the files are under MIT license or GPLv2 or v3 and the others are in the public domain. Instead, the composition of these files is protected by the GPLv3 license under the effects of the Copyright Act, title 17. U.S.C. § 101.

> Under the Copyright Act, a compilation [EdN: "composition" is used here as synonym because compilation might confuse the reader about code compiling] is defined as a "collection and assembling of preexisting materials or of data [EdN: source code, as well] that are selected in such a way that the resulting work as a whole constitutes an original work of authorship."

This means that everyone can use a single MIT licensed file or a part of it under the MIT license terms. Instead, using two of them or two parts of them implies that you are using a subset of this collection. Thus a derived work of this collection which is licensed under the GPLv3 also.

The GPLv3 license applies to the composition unless you are the original copyright owner or the author of a specific unmodified file. This means that every one that can legally claim rights about the original files maintains its rights, obviously. So, it should not need to complain with the GPLv3 license applied to the composition. Unless, the composition is adopted for the part which had not the rights, before.

Some pages, documents, software or firmware components can make an exception to the above general approach due to their specific copyright and license restriction. In doubt, follow the thumb rule of fair-use. Here a list of them: 

* Vendor's proprietary blobs for Sony Xperia 10 II (github repository)

For further information or requests about licensing and how to obtain your own business-like fork, please write to the project maintainer:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 💙 [Roberto A. Foglietta](roberto.foglietta@gmail.com)

**Have fun!** R-
