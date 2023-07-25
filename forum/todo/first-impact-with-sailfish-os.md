Hi, this is my feedback about the release. It is my first time with SailFish OS

## Installation:

I followed the standard installation procedure but the initial phone conditions were not completely matched: Android 12 instead of Android 11 and possibly something other like BSP/driver?

* [How to install Sailfish X on Xperia™ 10 II on Linux](https://jolla.com/how-to-install-sailfish-x-on-xperia-10-ii-on-linux/)

## System:

* Xperia X10 II dual SIM, model XQ-AU52 originally with Android 12
* Sailfish OS Jolla-4.5.0.19 qau52-1.0.0.19
* AOSP Android 10.0 kernel 4.14 seine
* Free license

## Defects:

* critical : no SIMs, GPS on, WLAN connected but no position: InfoGPS found 7 satellite 0 lock

* critical : SIM in routing, network manual selection is slow and often back to search

* annoying : automatic time zone does not work even with internet connection and GPS on

* annoying : Xperia 10 II mobile data does not work in 2G and 3G networks on SIM2 which is a known issue¹ but [it works for me](https://forum.sailfishos.org/t/release-notes-struven-ketju-4-5-0-19/15078/38) on a Xperia 10 II with 4.5.0.19 (customisations: my ofono is allowed to load the qmi plug-in which by default is disabled + the network on the SIM2 is set manually).

* function: InfoGPS installed among other default applications for GPS testing at first installation

* aesthetic: SIM renaming and signal strength bar are missing in “Mobile Network(s)” config menu

* aesthetic: in Settings:Apps page, every icon should be added a subscript-i for info²

* The GPS failure can influence the time zone as well and without a position, Finland as default?

## Software:

* [SailFish OS v4.5.0.19 for xqau52](https://d2lokee10frdc2.cloudfront.net/images/4.5.0.19/Sailfish_OS-Jolla-4.5.0.19-xqau52-1.0.0.19.zip)
* [Sony binaries for AOSP Android 10](https://developer.sony.com/file/download/software-binaries-for-aosp-android-10-0-kernel-4-14-seine)

## Suggestions:

Fixing the critical issues in same order listed above

Offer a try-and-buy-or-reset license

The try-and-buy-or-reset license would last e.g. 30gg [30days] and it might be free or cost €5. It lets the user try the Sailfish OS full license features and then decide to pay in full the license fee (€49 - €5) or having the phone reset to the free license or better locked than reset like a ransomware but legal.

Personally, I would buy it just to see if there is some way (upgrade, patch) that fixes or improves considerably the performance.
About the 2 first critical issues. I hope that 2 issues (GPS cannot lock satellites, routing manual network) are regression, is it right? Uhm, not really recent at least.

 * [GPS signal very bad](https://forum.sailfishos.org/t/gps-signal-very-bad/13026) (sept, 2022)

## Notes:

¹ [Known Issues](https://docs.sailfishos.org/Support/Releases/Known_Issues/) reported on Sailfish OS Documentation
² despite the top-menu header Apps, System, Accounts is easy to confuse the new users with the apps list from which the applications can be started instead of queried.

Now I am trying to apply this suggestion hoping that it will fix the GPS problem at reduced privacy counter-balance:

* [MLS Manager](https://forum.sailfishos.org/t/sailfish-community-news-25th-february-sdk-openssl/5179/1)

> :information_source: **Note**
>
> Back in March of last year Mozilla changed the terms of access to the Mozilla Location Service (MLS), with the unfortunate consequence that Jolla was no longer able to use it as part of the default Sailfish OS install. While GPS is still perfectly usable without MLS, it unfortunately does mean it takes longer to get a fix, especially in cases where GPS hasn’t been used for a while, or is reactivated at a significant distance from the last place it was used. Happily the ever-ingenious Sailfish community has come up with a workaround in the form of MLS Manager by Samuel Kron, which allows location data to be downloaded to your phone for offline use. Being offline this means no sensitive data is sent over the Internet, but if you use it don’t forget to alter your location settings to enable offline lookups in Settings -> Location -> Select custom settings -> Enable GPS and Offline positioning, disable Online positioning .

Obviously, downloading data that helps to get a faster localisation on the urban/city areas would not solve the problem of not having access to the real GPS.

---

In the installation instructions there is the suggestion of upgrading 11 from 10 but nothing about downgrading 12 to 11. There is also no warning about, like DO NOT INSTALL SAILFISH UNLESS bla bla.

> :information_source: **Note**
> 
> Some users on the forum reported not having particular problems with SailFish OS in combination with Android 12. However, end-user support can be difficult and community support can be hostile for those who did not pedantically follow the flashing instructions.

---

About this:

* [Jolla reverting Xperia back to Android](https://docs.sailfishos.org/Support/Help_Articles/Managing_Sailfish_OS/Reinstalling_Sailfish_OS/#reverting-xperia-back-to-android-os)

Unfortunately only the Microsoft Windows procedure is listed. The Linux one could be easily added:

```
$ sudo apt-get install mono-complete
$ sudo cert-sync /etc/ssl/certs/ca-certificates.crt
$ sudo certmgr -ssl -m https://software.sonymobile.com
```

Despite the error message, enter Y when asked, you should be asked to do so twice from here:

 * [XperiFirm: a Xperia Firmware Downloader v5.6.5 on XDA Forums](https://forum.xda-developers.com/t/tool-xperifirm-xperia-firmware-downloader-v5-6-5.2834142/)

download this zip and extract the binaries for x32 and x64 platform

```
$ url=https://forum.xda-developers.com/attachments/xperifirm-5-6-5-by-igor-eisberg-zip.5488139/
$ wget $url -O xperifirm-5-6-5-by-igor-eisberg-zip
$ unzip xperifirm-5-6-5-by-igor-eisberg-zip
$ mono XperiFirm-x64.exe
```

I did not go for it because it asked me to download 2.66Gb of Android 12 firmware. In fact, it is the same build release that I have before the installation of Sailfish OS.

```
Device: Xperia 10 II (XQ-AU52)
CID: 1321-6453
Market: Europe
Operator: Customized EU
Version: 59.2.A.0.463-R14C
Size: 2.66 GB
```

Sony Emma probably will let me downgrade to Android 11 but it does not work with mono. The Open Source archive of the baseband build required by Sailfish OS is downloadable from here:

* [Open source archive for 59.1.A.2.169 from Sony Developer World](https://developer.sony.com/file/download/open-source-archive-for-59-1-a-2-169/)

I think that flash.sh should check for the correct baseband (build) before proceeding.

Unless Emma would let me choose a downgrade, I think that there is no simple way. This means that soon Jolla will need to add the support for Android 12 based Xperia X10 II devices which is the default Android version since one year ago:

* [XperiCheck.com - Xperia 10 II (XQ-AU52)](https://xpericheck.com/XQ-AU52)

In particular the European customised version:

* [1321-6453 Customized EU 59.2.A.0.463](https://xpericheck.com/XQ-AU52/1321-6453) discovered 11 months 3 weeks ago

---

I have tried to erase all the partition before reslashing Sailfish OS plus I flashed also the secondary OEM partition:

```
fastboot -s QxxxxA erase dtbo_a
fastboot -s QxxxxA erase dtbo_b
fastboot -s QxxxxA erase oem_a
fastboot -s QxxxxA erase oem_b
fastboot -s QxxxxA erase userdata
bash flash.sh
fastboot -s QxxxxA flash oem_b ./SW_xxxx_10.0.7.1_r1_v12b_seine.img
```

I did not erase the boot partitions because they are installed in raw mode. Unfortunately the GPS problem persists and at this point I suspect that it should be configured in some way. A user find out that reverting back to Android 11 can be considered a work-around:

* [GPS Experiences after flashing with Android 11](https://forum.sailfishos.org/t/gps-experiences-after-flashing-with-android-11/11079/1)

I have tried also this, but it does not work without downgrading to Android 11:

* [Fix XA2 GNSS(GPS): Let’s Try harder](https://forum.sailfishos.org/t/how-to-hardware-fix-xa2-gnss-gps-lets-try-harder/11875/54)

---

[quote="rgp, post:39, topic:15078"]
Not a fix, but something that will make your life a little easier is a patch by @carmenfdezb which will let you add an Android Support toggle button to the Top Menu:
[https://coderus.openrepos.net/pm2/project/android-support-button ](https://coderus.openrepos.net/pm2/project/android-support-button)
[/quote]

It does not support the last version 4.5.0.19 in which there is a similar icon for the top-menu but it brings it to the Android Support page. This button is supposed to enable/disable the Android Support, instead. Is that right? Will the author update it for the last version, also?

---

[quote="carmenfdezb, post:44, topic:15078"]
and select ‘No’ in ‘Check version’ option
[/quote]

Thanks. In fact, at this time I have the *strict check version* enabled.
