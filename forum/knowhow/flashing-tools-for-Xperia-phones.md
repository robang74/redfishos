## Sony Xperia flashing guide

In this page is collected some practical knowledge for integrating the Jolla's official procedure for flashing the SFOS.

These are the two tools that have been reported to work on Windows for flashing AOSP into the Sony Xperia smartphones:

* [Sony Emma flashing tool for Windows 10](https://developerworld.wpp.developer.sony.com/file/download/download-the-flash-tool/)

* [XperiFirm: a Xperia Firmware Downloader v5.6.5 on XDA Forums](https://forum.xda-developers.com/t/tool-xperifirm-xperia-firmware-downloader-v5-6-5.2834142/)

* [XperiFirm: a Xperia Firmware Downloader official website](https://xperifirmtool.com/xperifirm-v5-6-5)

The Sony `Emma` flashing tool does not seem to be able to run also on a GNU/Linux distribution, but the `XperiFirm` does.

The Sony Xperia X10 II devices comes from the factory with Android 12 pre-installed since 2021:

* [XperiCheck.com - Xperia 10 II (XQ-AU52)](https://xpericheck.com/XQ-AU52)

In particular, we are interested in the European customized version:

* [1321-6453 Customized EU 59.2.A.0.463-R14C](https://xpericheck.com/XQ-AU52/1321-6453) discovered on May 2022.

It is reasonable to claim that soon Jolla will need to add support for Android 12 based Xperia X10 II devices, which has been the default Android version for more than one year at the time of writing. Especially because the 12 version is also the end-of-life last image for such device.

---

### Flashing procedure additional information

In the Jolla flashing instructions, there is a suggestion of upgrading 11 from 10 but nothing about downgrading 12 to 11 which seems as important as the upgrading.

> :information_source: **Note**
> 
> Some users on the forum reported not having particular problems with SailFish OS in combination with Android 12.

Therefore, it seems that there is no reason not to go with the factory Android 12 or use `XperiFirm` for flashing it. Unfortunately, reality presents us with another more complex story. 

Android 11 `AOSP` is available with `XperiFirm`:

* XQ-AU52_Service Exchange Unit_59.1.A.2.192-R3B for Xperia 10 II dual SIM
* XQ-AU51_Service Exchange Unit_59.1.A.2.192-R2B for Xperia 10 II single SIM

Android 10 `AOSP` is available with `XperiFirm`:

* XQ-AU52_StoreFront_59.0.A.6.24-R4A for Xperia 10 II dual SIM
* XQ-AU51_StoreFront_59.0.A.6.24-R4A for Xperia 10 II single SIM

None of these seem suitable for end-users, but they can be fine for supporting the SailFish OS.

> :information_source: **Note**
>
> Some users on the forum reported not having particular problems with SailFish OS in combination with Android 12 especially about make working properly the A/GPS hardware subsystem.

Using a wide variaty of ASOP on which installing SFOS, the end-user support can be difficult and the community support can be hostile with those who do not pedantically follow the flashing instructions. Therefore, in order to achieve a kind of standardisation about the SFOS installation, I think that `flash.sh` should check for the correct baseband (build) before proceeding. 

> :information_source: **Note**
> 
> the `fastboot` protocol is not able to retrieve data from smartphone partitions but just some specific variable values. An alternative protocol to `fastboot` is the Android Debug protocol, which is used by /e/OS for the easy-flashing procedure of the Murena best supported smartphones. 

In fact, the baseband version could be retireved by `fastboot` with this command:

```
fastboot getvar version-baseband
```

This is the document in which is explained the procedure to bring back Sony Xperia devices working with Android:

* [Jolla reverting Xperia back to Android](https://docs.sailfishos.org/Support/Help_Articles/Managing_Sailfish_OS/Reinstalling_Sailfish_OS/#reverting-xperia-back-to-android-os)

Unfortunately only the Microsoft Windows procedure is listed. The Linux one could be easily added:

```
$ sudo apt-get install mono-complete
$ sudo cert-sync /etc/ssl/certs/ca-certificates.crt
$ sudo certmgr -ssl -m https://software.sonymobile.com
```

Despite the error message, enter Y when asked. You could be asked to do so twice from here:

 * [XperiFirm: a Xperia Firmware Downloader v5.6.5 on XDA Forums](https://forum.xda-developers.com/t/tool-xperifirm-xperia-firmware-downloader-v5-6-5.2834142/)

then download this zip and extract the binaries for the x32 and x64 platforms:

```
$ url=https://forum.xda-developers.com/attachments/xperifirm-5-6-5-by-igor-eisberg-zip.5488139/
$ wget $url -O xperifirm-5-6-5-by-igor-eisberg-zip
$ unzip xperifirm-5-6-5-by-igor-eisberg-zip
```

Then execute `XperiFirm` leveraging the `mono` framework:

```
$ mono XperiFirm-x64.exe
```

Unfortunately, `XperiFirm` can download just a few `AOSP` versions compared to Sony `Emma`. Therefore I did not go with it because it asked me to download 2.66Gb of Android 12 firmware. In fact, it is the same build release that I had before the installation of Sailfish OS:

```
Device: Xperia 10 II (XQ-AU52)
CID: 1321-6453
Market: Europe
Operator: Customized EU
Version: 59.2.A.0.463-R14C
Size: 2.66 GB
```

Instead, if we are planning to bring back our Xperia smartphones to work with Android 12 only then `XperiFirm` is perfectly fine.

Finally, Sony `Emma` allowed me to downgrade the smartphone OS to Android 11 but it works only on Microsoft Windows.

---

### SailFish OS images

The Open Source archive of the baseband build required by Sailfish OS is downloadable from here:

* [Open source archive for 59.1.A.2.169 from Sony Developer World](https://developer.sony.com/file/download/open-source-archive-for-59-1-a-2-169/)

This link below is reported just for sake of completeness, but it does not work unless the download is started by a registered user within the Jolla shop.

* [SailFish OS v4.5.0.19 for xqau52](https://d2lokee10frdc2.cloudfront.net/images/4.5.0.19/Sailfish_OS-Jolla-4.5.0.19-xqau52-1.0.0.19.zip)

Instead downloading the Android 10 binaries image does not require any credentials, and it should be immediately available:

* [Sony binaries for AOSP Android 10](https://developer.sony.com/file/download/software-binaries-for-aosp-android-10-0-kernel-4-14-seine)

The first link contains the sources while the other two the images which are related to the Sony Xperia 10 II.

---

### SailFish OS fastboot

What is above is related to Android, but to flash SailFish OS onto the smartphone, another tool is used that leverages the fastboot mode.

* [Jolla how to flash SFOS with Linux](https://jolla.com/how-to-install-sailfish-x-on-xperia-10-ii-on-linux/)

I have tried to erase all the partitions before re-flashing Sailfish OS, plus I flashed the secondary `OEM` partition:

```
fastboot erase dtbo_a
fastboot erase dtbo_b
fastboot erase boot_a
fastboot erase boot_b
fastboot erase oem_a
fastboot erase oem_b
fastboot erase userdata

bash flash.sh
fastboot flash oem_b ./*_v12b_seine.img
fastboot reboot
```

Erasing the partitions before flashing is not strictly necessary, but considering that spare images skip those blocks that are not allocated, it is the quickest way to ensure that no fragment of the previous data remains. However, that erasing process cannot be considered safe from a forensic point of view, possibly but not necessarily.

Also, flashing the secondary OEM partition is optional because `flash.sh` does not do it by default. However, doing this ensures us that SailFish OS will run on the correct OEM binaries, whatever the partition is selected.

In the future, [having a recovery image that can fulfill its duty](../todo/recovery-image-refactoring.md) also having an `OEM` partition with a backup of the original data will be a great advantage.
