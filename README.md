# RedFish OS

Refactoring SailFish OS 4.5.0.19 while it is running on a Sony Xperia 10 II smartphone.

---

### About SailFish OS

The SailFish OS is not open-source nor software libre and cannot be redistributed but can be downloaded for free (gratis) from the Jolla Shop:  

* [Jolla SailFish OS download shop](https://shop.jolla.com/)
* [Jolla SailFish OS website](https://sailfishos.org/)
* [Jolla offial documentation](https://docs.sailfishos.org/)

The licensed version adds the supports for Android by Alien Dalvik proprietary middle-ware framework plus some others features. The zero-budget version is supported by its related community:

* [Community Forum](https://forum.sailfishos.org/)
* [Community apps repository](https://sailfish.openrepos.net/)
* [Patch Manager Web Catalog](http://coderus.openrepos.net/pm2/)

Few components in SailFish OS are proprietary and because the package downloaded from their shop contains such proprietary software, it cannot considered open-source nor software libre. Some other proprietary software cames from Sony Open Device AOSP, instead.

Instead, the boot images are compositions of binaries from on open source and software libre projects, only. Therefore the boot images can be freely redistribute as far as those redistribuite them fulfil the FOSS licenses obbligations related to that binaries. 

The alternative is to link this page which the aim is to collect all those FOSS contributes. However, you have to check by yourself if these list of resources is complete and updated respect the boot image that you wish to distribute.

---

### About Xperia 10 II

The Sony Xperia 10 II (codename `pdx201`) is a mid-range smartphone from Sony. It was announced in February 2020 and released in May 2020 and it [has been added](https://developer.sony.com/posts/xperia-10-ii-added-to-sonys-open-devices-program/) on Sony Open Device program on June 2020.

---

### About Open Device program

* https://developerworld.wpp.developer.sony.com/open-source/aosp-on-xperia-open-devices

* https://opendevices.ix5.org

---

### List of components available on Github

* [yamui](https://github.com/robang74/yamui) - Yet Another Minimal UI. Tool for displaying graphical notifications in minimal evironments like early boot / initrd

* [busybox-static](https://github.com/robang74/sailfish-os-busybox) - The busybox config and RPM spec for SailFish OS

* [fsck.auto](https://github.com/robang74/fsck.auto) - This is a simple b/ash script for busybox fsck.auto to check block device partition file system type.

* [Patch Manager](https://github.com/robang74/patchmanager) - The Patch Manager page in Settings:System for Sailfish OS

* [lipstick](https://github.com/robang74/lipstick) - The lipstick aims to offers an easy to modify user experiences for varying mobile device form factors, e.g. handsets, netbooks, tablets. User interface components are written in [QML](https://doc.qt.io/qt-6/qml-tutorial.html). Here an example of QML application: [home-example](https://github.com/robang74/lipstick-example-home).

---

## License

Almost all the files are under MIT license or GPLv2 and the others are in the public domain. Instead, the composition of these files is protected by the GPLv3 license under the effects of the Copyright Act, title 17. U.S.C. § 101.

> Under the Copyright Act, a compilation [NDR: "composition" is used here as synonym because compilation might confuse the reader about code compiling] is defined as a "collection and assembling of preexisting materials or of data [NDR: source code, as well] that are selected in such a way that the resulting work as a whole constitutes an original work of authorship."

This means that everyone can use a single MIT licensed file or a part of it under the MIT license terms. Instead, using two of them or two parts of them implies that you are using a subset of this collection. Thus a derived work of this collection which is licensed under the GPLv3 also.

The GPLv3 license applies to the composition unless you are the original copyright owner or the author of a specific unmodified file. This means that every one that can legally claim rights about the original files maintains its rights, obviously. So, it should not need to complain with the GPLv3 license applied to the composition. Unless, the composition is adopted for the part which had not the rights, before.

An exception is this specific file which is "all rights reserved, but fair use allowed", here:

* none for now but just in case, it will be listed here

For further information or requests about licensing and how to obtain your own business-like fork, please write to the project maintainer:

[Roberto A. Foglietta](roberto.foglietta@gmail.com)
Have fun! <3 
