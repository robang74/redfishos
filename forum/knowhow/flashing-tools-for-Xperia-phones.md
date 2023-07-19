## Sony Xperia flashing guide

Some pratical knowledge for integrating the Jolla's official procedure.

---

### Flashing tools

These are the flashtools that has been reported to work for flashing the Sony Xperia smartphones serie, with windows:

* [Sony Emma flashing tool for Windows 10](https://developerworld.wpp.developer.sony.com/file/download/download-the-flash-tool/)

* [XperiFirm: a Xperia Firmware Downloader v5.6.5 on XDA Forums](https://forum.xda-developers.com/t/tool-xperifirm-xperia-firmware-downloader-v5-6-5.2834142/)

* [XperiFirm: a Xperia Firmware Downloader official website](https://xperifirmtool.com/xperifirm-v5-6-5)

The Sony Emma flashing tool does not seems able to run on a GNU/Linux distribution but the XperiFirm does:

```
$ sudo apt-get install mono-complete
$ sudo cert-sync /etc/ssl/certs/ca-certificates.crt
$ sudo certmgr -ssl -m https://software.sonymobile.com

$ url=https://forum.xda-developers.com/attachments/xperifirm-5-6-5-by-igor-eisberg-zip.5488139/
$ wget $url -O xperifirm-5-6-5-by-igor-eisberg-zip
$ unzip xperifirm-5-6-5-by-igor-eisberg-zip

$ mono XperiFirm-x64.exe
```

Unfortunately, XperiFirm can download just few AOSP versions compared to Sony Emma.

---

### Android version

The Xperia X10 II by factoy cames with Android 12 since 2021 but it will be probably the last major release update that they will receive:

* [XperiCheck.com - Xperia 10 II (XQ-AU52)](https://xpericheck.com/XQ-AU52)

In particular we are insterested into the European customised version:

* [1321-6453 Customized EU 59.2.A.0.463](https://xpericheck.com/XQ-AU52/1321-6453)

This version presents itself in this way:

```
Device: Xperia 10 II (XQ-AU52)
CID: 1321-6453
Market: Europe
Operator: Customized EU
Version: 59.2.A.0.463-R14C
Size: 2.66 GB
```

In the installation instructions by Jolla there is the suggestion of to upgrade to Android 11 from 10 but nothing about downgrading 12 to 11. There is also no any warning about the imperative need of having Android 11, like DO NOT INSTALL UNLESS Andorid 11 is flashed before into the device.

Therefore, it seems that there is not any reason to not go with the factory Andorid 12 or using XperiFirm for flashing it. Unfortunately the reality presents us another story but further investigation can be conducted to check if Android 12 can be supported as well 11 and 10.

Android 11 AOSP available on XperiFirm:

* XQ-AU52_Service Exchange Unit_59.1.A.2.192-R3B for Xperia 10 II dual SIM
* XQ-AU51_Service Exchange Unit_59.1.A.2.192-R2B for Xperia 10 II single SIM

Android 10 AOSP available on XperiFirm:

* XQ-AU52_StoreFront_59.0.A.6.24-R4A for Xperia 10 II dual SIM
* XQ-AU51_StoreFront_59.0.A.6.24-R4A for Xperia 10 II single SIM

None of these seems suitable for end-users but they can be fine for supporting the SailFish OS.

> __Note__: some users on the forum reported to not having particular problems with SailFish OS in combination with Android 12. However, end-user support can be difficult and community support can be hostile for those did not followed pedantically the flashing instructions.

Instead, if you are planning to bring back your Xperia smartphone to work with Andorid only, then XperiFirm is fine

* [Jolla reverting Xperia back to Android](https://docs.sailfishos.org/Support/Help_Articles/Managing_Sailfish_OS/Reinstalling_Sailfish_OS/#reverting-xperia-back-to-android-os)

This is the page in which you can find the Android restore procedure using Sony Emma flashing tool.

---

### SailFish OS images

* [SailFish OS v4.5.0.19 for xqau52](https://d2lokee10frdc2.cloudfront.net/images/4.5.0.19/Sailfish_OS-Jolla-4.5.0.19-xqau52-1.0.0.19.zip)
* [Sony binaries for AOSP Android 10](https://developer.sony.com/file/download/software-binaries-for-aosp-android-10-0-kernel-4-14-seine)

---

### SailFish OS fastboot

What is above is related to Andorid but to flash SailFish OS into the smartphone another tool is used which leverate the fastboot mode.

* [Jolla how to flash SFOS with Linux](https://jolla.com/how-to-install-sailfish-x-on-xperia-10-ii-on-linux/)

I have tried to erase all the partition before reflashing Sailfish OS plus I flashed also the secondary OEM partition:

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

Erasing the partitions before flashing is not strict necessesary but considering that spare images skip those block that are not allocated, it is the quickest way to ensure that no any fragment of the previous data remains. However, that erasing process should not considered safe from a forensic point of view - possibly but not necessarly.

Also flashing the secondary OEM partition is optional because flash.sh does not do but doing it ensure us that SailFish OS will run on the correct OEM binaries whatever the partition is going to be selected. In the future, [having a recovery image that can fulfill its duty](../todo/recovery-image-refactoring.md) also having an OEM partition with a backup of the original data will be a great advantage.

