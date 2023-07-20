## Guide: Installing SailfishX on Xperias

Local mirror with aesthetic adaptations due to different markdown syntax of the original source: 

 * https://gitlab.com/Olf0/sailfishX licensed under [CC BY-SA 4.0](LICENSE) terms

This guide aims at setting up an Xperia step by step, extending Jolla's flashing guide by preparatory and follow up measures, plus specific considerations WRT privacy.

---

### Table of content

Guide: Installing SailfishX on Xperias

* 1 - [Preparation](#1-preparation)
  - 1.1 - [First steps](#11-first-steps)
  - 1.2 - [Further preparation](#12-further-preparation-modem-initialisation) (modem initialisation)

* 2 - [Flashing Sailfish OS](#2-Flashing-Sailfish-OS)

* 3 - [Basic configuration of SailfishOS](#3-Basic-configuration-of-SailfishOS)
  - 3.1 - [First boot ("initial bring-up")](#31-First-boot-initial-bring-up)
  - 3.2 - [Enabling "developer mode"](#32-Enabling-developer-mode)
  - 3.3 - [Increasing the "root" LVM volume size](#33-Increasing-the-root-LVM-volume-size)
    - 3.3.1 - [Booting a SailfishOS recovery image via fastboot boot](#331-Booting-a-SailfishOS-recovery-image-via-fastboot-boot)
    - 3.3.2 - [Shrinking the "home" LVM volume and extending the "root" one](#332-Shrinking-the-home-LVM-volume-and-extending-the-root-one)
    - 3.3.2.a - [... on devices / SailfishOS releases without home volume encryption](#332a---on-devices--sailfishos-releases-without-home-volume-encryption)
    - 3.3.2.b - [... on devices / SailfishOS releases with home volume encryption](#332b---on-devices--SailfishOS-releases-with-home-volume-encryption)

* 4 - [Installing software](#4-Installing-software)
  - 4.1 - [Using the Jolla Store](#41-Using-the-Jolla-Store)
  - 4.2 - [Using OpenRepos (SailfishOS community repositories)](#42-using-openrepos-sailfishos-community-repositories)
  - 4.3 - [Using the SailfishOS:Chum community repository](#43-using-the-sailfishoschum-community-repository)
  - 4.4 - [Installing Patchmanager](#44-Installing-Patchmanager)
  - 4.5 - [Installing Android app stores' client apps](#45-Installing-Android-app-stores-client-apps)
    - 4.5.1 - [F-Droid](#451-F-Droid)
    - 4.5.2 - [A proper Android file-manager](#452-A-proper-Android-file-manager)
    - 4.5.3 - [Google Play Store via Aurora Store app](#453-Google-Play-Store-via-Aurora-Store-app)
    - 4.5.4 - [Other Android app sources](#454-Other-Android-app-sources)
  - 4.6 - [Installing microG](#46-Installing-microG)

- 5 - [Further recommendations](#5-Further-recommendations)
  - 5.1 - [Recommended apps from OpenRepos](#51-Recommended-apps-from-OpenRepos)
  - 5.2 - [Guides for utilising an SD card to consider](#52-Guides-for-utilising-an-SD-card-to-consider)

- 6 - [Further guidance and sources of information](#6-Further-guidance-and-sources-of-information)

---

### 1 Preparation

---

#### 1.1 First steps

1. Buy a Sony Xperia model, which is [supported by SailfishOS via the SailfishX end user license programme](https://shop.jolla.com/). More detailed lists are [provided by Jolla ("officially supported devices")](https://docs.sailfishos.org/Support/Supported_Devices/) and [the SailfishOS community: "Available devices supported by SailfishOS"](https://together.jolla.com/question/136143/wiki-available-devices-plus-rumored-and-legacy-devices-running-sailfish-os/) (this second list is outdated).

2. Unbox your Xperia, but do not insert a SIM or SD card yet.

3. Start your Xperia by pressing the power button for a few seconds. BTW, it should be charged between 40% and 55% when new.

4. Choose **No**, **Off**, **Cancel**, **Skip**, **Disable**, **Dismiss**, **Decline**, **Deny** for really everything during the initial setup: Google account, WLAN ("WiFi"), Bluetooth, GPS, Mobile network, Sony support, device **PIN** and fingerprint (because that would trigger the device encryption unnecessarily) etc.!

5. Do not blindy upgrade Android! Otherwise you may not be able to install SailfishOS or it might not run properly.
   
    Background: Because firmware blobs may become updated by Sony's Android updates and these blobs cannot be updated through SailfishOS (yet?), it makes sense to update your Xperia to the last release of Sony's Android, which is supported by SailfishOS, before flashing SailfishOS ([Reference](https://irclogs.sailfishos.org/meetings/sailfishos-meeting/2022/sailfishos-meeting.2022-11-10-08.00.log.html#l-215)).

    It might be possible to download ([Reference](https://irclogs.sailfishos.org/meetings/sailfishos-meeting/2022/sailfishos-meeting.2022-11-10-08.00.log.html#l-259)) and flash specific components of a Sony Android update with *"the (unofficial) XperiaFlashTool"* ([Reference](https://irclogs.sailfishos.org/meetings/sailfishos-meeting/2022/sailfishos-meeting.2022-11-10-08.00.log.html#l-253)), but it is unclear to me if this addresses `XperiFirm` or the slightly dubious `Flashtool@XperiaFirmware.com` (for details, see third paragraph below).
   
    Jolla provides [some guidance which Xperia models shall be upgraded to which Android version](https://docs.sailfishos.org/Support/Help_Articles/Reinstalling_Sailfish_OS/#selecting-the-version-of-android-baseband):
      - An Xperia X should be upgraded to the latest Android 8 (34.**4**.A.x.y, e.g., 34.4.A.2.118), but must not be upgraded to Android 9 (34.**5**.A.x.y).
      - An Xperia XA2 should upgraded to the latest Android 9 (50.**2**.A.x.y, e.g., 50.2.A.0.400), but must not be upgraded to Android 10 (50.**3**.A.x.y).
      - An Xperia 10 can upgraded to the latest Android 9 (53.**0**.A.x.y, e.g., 53.0.A.8.69), but must not be upgraded to Android 10 (53.**1**.A.x.y).
      - An Xperia 10 II should upgraded to the latest Android 11 (59.**1**.A.x.y, e.g., 59.1.A.0.485), but must not be upgraded to Android 12 (59.**2**.A.x.y).
      - An Xperia 10 III should upgraded to the latest Android 11 (62.**0**.A.x.y, e.g., 62.0.A.9.11), may be upgraded to Android 12 (62.**1**.A.x.y), although [Jolla does not recommend this as of mid-2022](https://forum.sailfishos.org/t/sony-xperia-iii-android-12/11029/103?u=olf).

    [XperiCheck.com](https://xpericheck.com/) can be used to discover which firmware versions exist for a specific Xperia model, but it does not offer firmware files to download.  Because Sony wants firmwares only to be downloaded by their own tools to flash an Xperia, firmware files for flashing them with XperiFirm, Newflasher or Flashtool (see next paragraph) are hard to obtain (but XperiFirm offers to download firmware files from Sony's servers, at least the latest one); if you want to separately download a specific firmware release, you must search the internet and mind that downloads from third party sources may be tainted (i.e., manipulated); for the Xperia 10 III one [might find this one](https://combinedfleet.keybase.pub/Firmware%20backups/XQ-BT52).

    For up- or downgrading your Xperia's firmware offline (from the perspective of the Xperia), use [Sony's Emma tool](https://developer.sony.com/develop/open-devices/get-started/flash-tool/download-flash-tool/) (Windows only!), the equally comfortable and mightier [XperiFirm ≥ v5.6.5](https://forum.xda-developers.com/t/tool-xperifirm-xperia-firmware-downloader-v5-6-5.2834142/) (Windows, Linux, macOS; *do read* the "INSTRUCTIONS & REQUIREMENTS" by clicking on the unhide-button) or the very basic [command-line tool Newflasher](https://forum.xda-developers.com/t/tool-newflasher-xperia-command-line-flasher.3619426/) (Windows, Linux, macOS; *do read* [the instructions](https://github.com/munjeni/newflasher#readme) and [common errors](https://forum.xda-developers.com/t/tool-newflasher-xperia-command-line-flasher.3619426/#post-72610228)), which requires to download the firmware by other means (e.g., XperiFirm).  Mind to download any of these tools solely from its original source (linked to here). All three supposedly allow to install arbitrary firmware releases for an Xperia phone (but I never used Emma and Newflasher), but [XperiFirm's ability to download arbitrary releases might be gone](https://forum.sailfishos.org/t/sony-xperia-iii-android-12/11029/16?u=olf). Sony's [Xperia Companion](https://www.sony.com/electronics/support/articles/00236877) (Windows, macOS) might be another way to upgrade your Xperia's firmware offline. [Flashtool@XperiaFirmware.com](https://xperiafirmware.com/flashtool/) (only supports [newer Xperia models](https://xperiafirmware.com/)) *seems* [to be legit](https://xperiafirmware.com/about/), but its downloads are hosted at Mega.nz and while it is stated that Flashtool versions for Windows, Linux and macOS exist, I only found those for Windows (please inform me, if you know where to obtain the Linux and macOS versions of Flashtool); this site also provides an [info-page WRT the bootloader](https://xperiafirmware.com/bootloader/).  Some experienced that Emma wants the bootloader of an Xperia to be unlocked first (see below) for flashing a new firmware.

    Alternatively, you can temporarily activate WLAN ("WiFi") on your Xperia and use its "over the air (OTA) update" function, which will [take you step by step through the various firmware releases for your Xperia](https://forum.sailfishos.org/t/sony-xperia-iii-android-12/11029/17?u=olf) (a bit tedious process).  Mind to check the installed firmware release after each update to ensure that you do not go too far! Some even used [a mix of both methods to install a specific, desired firmware release](https://forum.sailfishos.org/t/sony-xperia-iii-android-12/11029/23?u=olf).  Some experienced that the "OTA update" function wants the bootloader of an Xperia to be locked to work; it can be easily re-locked by executing a `fastboot oem lock` on your host computer.

    Simple but useful are [the key combinations documented by Sony](https://developer.sony.com/develop/open-devices/get-started/flash-tool/useful-key-combinations/). If your device refuses to reboot (e.g., after flashing), one can simply issue a `fastboot reboot` command at the host computer, when the device is still attached via USB.

    For troubleshooting USB issues, see [the introductory paragraph of section 2](#2-flashing-sailfishos).

6. Thoroughly browse through the *Settings* subsections and switch off everything with regard to online, location and other potentially privacy relevant functions / services. Pay attention to not accidentally switch *on* something which may receive or transmit data, as many functions / services are off by default.

    Note that you have to go online in part 2 of the preparation, thus do this diligently.

      - Pay special attention to the settings in the *Google* subsection.

      - Note that some settings are "logically inverted", e.g., setting *Settings -> Google -> Ads -> Opt out of Ads Personalisation* to ***on*** actually switches the personalised ads **off**!

7. Check your device hardware with Sony's device test tool via *Settings -> System -> About phone -> Support -> Decline -> Run all tests*:

      - The GPS test will fail, even if "location access" is granted (hence don't!), as it runs too briefly to obtain a GPS fix without A-GPS.

    This test will be performed in a different manner, later.

      - The "Nearby" test will fail without a location fix, location access by the Sony test tool and Google Chrome, plus acknowledging the use of Google Chrome.

    Skip it!

8. Go to *Settings -> System -> Date & Time* and switch off both "*Automatic date & time*" and "*Automatic timezone*". Then set the correct date, time and timezone in order to obtain a GPS fix (in the next step) reasonably quick. Also switch on *Settings -> Lock screen & security -> Privacy: Location -> Use location* on for the next step.

9. Open the *Service menu* as [described by Sony](https://developer.sony.com/develop/open-devices/get-started/unlock-bootloader/how-to-unlock-bootloader/), i.e., by entering `*#*#7378423#*#*` (equals `*#*#SERVICE#*#*`) in the dialler app.

    - *Service info -> Configuration -> Rooting status:* must state "*Bootloader unlock allowed: Yes*".

    - *Service tests -> GPS* runs much longer and should obtain a GPS fix within approximately 10 minutes.

    - You may perform other tests in *Service tests*, but many of them are tedious.

    - You may also look at other information in *Service info*, e.g., *SIM lock*.

10. Switch *Settings -> Lock screen & security -> Privacy: Location -> Use location* off again.

11. Go back to *Settings -> System -> About phone*
    
    - Compare the IMEI(s) with the ones on the original cardboard box from Sony (the IMEI(s) are on a printed label at its small side): They ought to be the same.  If not, you bought your Xperia from a likely fraudulent seller.

    - Tap seven times on *Settings -> About phone -> Build number* to check if you can enable the "Developer mode".  If this fails, the device is locked and SailfishOS cannot be installed.

12. Switch your Xperia off.

---

#### 1.2 Further preparation (modem initialisation)

1. Insert a working SIM card, preferably the one you will be using later.

2. Start your Xperia.

3. Enter the PIN of your SIM card.

4. Let the Xperia rest for at least 10 minutes at a location with at least medium mobile network reception.

    - The SIM card might reboot once or twice, resulting in a brief loss of mobile network connectivity; you may have to enter the SIM-PIN again.

    - You should perform a telephone call after waiting for 10 minutes to check that this is working fine.

    - You may additionally switch on mobile data and check internet access, but using any of the preinstalled apps for that will likely push device specific data (i.e., privacy relevant data) to Sony, Google etc. Hence you may as well skip this mobile data test!
  
    Or alternatively (but tediously) transfer a privacy protecting network speed test app (e.g., download the latest APK of [*Speedtest* from F-Droid](https://f-droid.org/en/packages/com.dosse.speedtest/) on your PC) via Bluetooth, install it (needs "untrusted sources" enabled) and use that. When done, switch mobile data (plus Bluetooth and "untrusted sources") off again.

Up to this point ...

- your Xperia did not have a chance to transmit privacy relevant (e.g., device specific or personal) data to a third party, except for modem specific and SIM card data to your mobile network provider (which is unavoidable when using a SIM card).

- all measures are fully reversible by performing a "factory reset" of Android: After that your Xperia will be in exactly the state, when you received it (if it was new or factory reset before).

---

### 2 Flashing Sailfish OS

Attaching your Xperia to a "USB root hub" (internal to your computer), to which no other device is attached (neither internally or externally):

* For Linux

  1. Execute `lsusb` in a terminal window, without having your Xperia connected.

  2. Look for a bus which solely has a **Linux Foundation 2.0 root hub** attached (i.e., nothing else).

  3. Connect your Xperia to a USB port, which is attached to this bus.

  4. Execute `lsusb` again; for example, an Xperia X on bus 003 then looks like this:

     `Bus 003 Device 015: ID 05c6:0afe Qualcomm, Inc. Xperia X`

     `Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub`

* For Windows you should be able to achieve the same by the help of the device manager's tree view.

* Only on Windows you shall install [the latest USB driver for your Xperia model](https://developer.sony.com/develop/drivers/) (see also [Sony's installation guide](https://www.sony.com/electronics/support/articles/SX278901)).

* An alternative way for Windows, Linux and macOS is to use the `fastboot devices` command to list the devices the fastboot program sees. As `fastboot` works on a higher level than `lsusb` or the Windows' device manager, you may just see nothing this way, if something is fundamentally wrong.

Note that:

* If there are no buses without internal USB devices attached (this is the case for many notebooks), you may disable those devices (e.g., cameras, card readers) in the firmware (UEFI- / "BIOS"-) setup and retry then.

* In general, do not put anything (e.g., an external USB hub, adapters) between your Xperia and your computer's USB port, except for a single *USB* ***2*** *cable* (or a *USB 3 cable* plugged into a *USB 2 port*) of at most 2 metres length.  The USB cable which came with your Xperia should work fine, at least at a *USB* ***2*** *port*.

* Although pure USB **2** ports are preferable, if there are none or these share a USB root hub with other devices, do try a USB port which also supports USB **3** (often colour coded in blue; on Intel machines `lsusb` may also show a "rate adaptor" attached to this bus, which is harmless) using a *USB* ***2*** *data cable:* You should still see your Xperia being attached to a USB **2** root hub.

 If it turns out to be logically attached to a USB **3** root hub then, flashing will likely fail, hence use a different USB port or try to temporarily force all USB 3 ports to USB 2 mode by executing as root user (use `sudo su` on Ubuntu and derivates):

  `for i in $(lspci -nn | fgrep USB | grep -o '[0-9a-f][0-9a-f][0-9a-f][0-9a-f]:[0-9a-f][0-9a-f][0-9a-f][0-9a-f]'); do setpci -H 1 -d $i d0.l=0; done`

 As a last resort measure, if all aforementioned measures fail, you may try putting a USB **2** hub between a USB **3** port and your Xperia.

After having determined a suitable USB port for the subsequent unlocking and flashing, unplug your Xperia from the USB cable.

Diligently follow the model specific (and host OS specific) [guide for flashing SailfishX by Jolla](https://jolla.com/sailfishxinstall/), starting with the section "Install the fastboot driver to your computer" (you have already performed actions equivalent to the steps described in Jolla's prior sections).

- An Xperia needs an internet connection for altering the "Developer options" (after enabling them) in *Settings -> System -> Advanced -> Developer options* (per Jolla's section "Enable developer options on your phone"): Deliberately switch WLAN (preferred for privacy) or alternatively mobile data on for this (and off again thereafter).

- Note that the unavoidable steps of altering the "Developer options" and (even more so) of unlocking the bootloader are not fully reversible.

For details and troubleshooting, covering the whole section 2 of this guide, see also Jolla's "[Checklist for issues in installing Sailfish&nbsp;X](https://jolla.zendesk.com/hc/en-us/articles/115003840273-Checklist-for-issues-in-installing-Sailfish-X)".

USB power saving may also cause issues, hence you can try switching USB "Autosupend" off [in the BIOS](https://github.com/openstf/stf/issues/677#issuecomment-323617121) or [at the command line](https://forum.sailfishos.org/t/linux-fastboot-error-couldnt-parse-partition-size-0x/4514/14).

---

### 3 Basic configuration of SailfishOS

---

#### 3.1 First boot ("initial bring-up")

1. Select a language, preferably English UK or English US (unfortunately English EU aka English DK is not available). Note that you can add (and remove) arbitrary languages (localisations, dictionaries and keyboard layouts) later (after the initial setup) and SailfishOS knows no "primary" language.

2. Enter a new security code.

3. Enable WLAN and log in to a WLAN network.

4. Select time and date.

5. Enter your Jolla Store credentials to log in.

6. Initial selection of Jolla provided apps:

   - Do **not** select Jolla's *Weather* app (actually by Foreca), because MeeCast is a better, Open Source and privacy conscious alternative, which can be installed later via Storeman.

   - You may select *Exchange Active Sync (EAS) support* depending on your needs.

   - Do select **everything else** for installation, even if you think you will not need them: Some other apps depend on them being installed, they do nothing if not used and they are all quite small.

   - If the XT9 support is not available (free and community versions of SailfishOS), install [Presage](https://openrepos.net/search/node/presage) via Storeman later on.

7. Do select Android App Support, depending on your preference (only offered here, if you are [entitled for it](#45-installing-android-app-stores-client-apps)). Do **not** select the "Store" app (actually a special Aptoide client version), if it is offered here (since SailfishOS 3.3.0), because of the security issues using Aptoide bears plus the multiple security breaches Aptoide had.  See also [section 4.5.4](#454-other-android-app-sources).

8. Do **not** set up the fingerprint sensor yet ("Skip"), as it may result in issues doing it now. You can perform this action any time later.

All these apps can also be installed or uninstalled (and reinstalled) later via the Jolla Store app, but privacy relevant data cannot be recalled once given away.

Note that most of them are proprietary licensed by Jolla.

---

#### 3.2 Enabling "developer mode"

Optional, but absolutely recommended!

1. Switch on *Settings -> Developer tools -> Developer mode*, followed by also switching on *Remote connection* there and setting a root password of your choice.

2. Wait for the Terminal app to become installed and open it.

3. Execute `devel-su` in the Terminal and enter your root password.

4. If becoming root in the Terminal went fine, enter **Ctrl-D** twice or type `exit` twice (or just brutally close the Terminal app).

---

#### 3.3 Increasing the "root" LVM volume size

Optional, although strongly recommended.

There are multiple descriptions of the issues the tiny (2500 MiB) default "root" volume size might cause later at Together.Jolla.com ("TJC": [[1]](https://together.jolla.com/question/156279/installing-system-updates-fails-when-there-is-not-enough-space-in-system-data-partition/?answer=156670#post-id-156670), [[2]](https://together.jolla.com/question/174491/sailfish-x-is-there-a-way-to-increase-the-size-of-the-system-data-partition/), [[3]](https://together.jolla.com/question/219469/cant-update-due-to-out-of-space-but-i-have-plenty-of-space/), [[4]](https://together.jolla.com/question/200683/sailfishx-gemini-the-rootfs-is-too-small/) etc.), which affects all devices since SailfishOS started using LVM (i.e., all since the Jolla C).  Many more such reports can be found at [Jolla's new forum "FSO"](https://forum.sailfishos.org/).  Note that the recent SailfishOS installation images (v4.x.y) for the Xperia 10 II and III (i.e., only for these two devices) seem to default to a root parition size of 4000 MB.

Side note: If you want to become familiar with the LVM (precisely: Linux LVM2) instead of blindly and indifferently following the subsequent sections 3.3.2, [this page nicely depicts the basic LVM concepts](https://christitus.com/lvm-guide/) and [the chapters 1 to 3 of the LVM page in the Arch Linux Wiki](https://wiki.archlinux.org/title/LVM) provides more comprehensive information.

---

#### 3.3.1 Booting a SailfishOS recovery image via `fastboot boot`

This is a brief, generic description of Jolla's detailed [guide of booting a SailfishOS recovery image (respectively for the Xperia II and III awkwardly flashing it, using it and then re-flashing the boot image](https://docs.sailfishos.org/Support/Help_Articles/Recovery_Mode/), until an ["embedded recovery" is deployed for the Xperia II and III](https://github.com/mer-hybris/hybris-initrd/pull/27#issuecomment-913248435)); but as the Xperia 10 II and III should have a 4000 MB root volume size after flashing (check with `lvm lvdisplay`), there is much less reason to perform section 3.3 with it and you **must** recalculate the values used in this section for it (please document them in an issue here, if you do so).

You also may apply section 3.3 to older devices (which all have an "embedded recovery"): [Jolla C / Intex Aquafish](https://jolla.zendesk.com/hc/en-us/articles/115000663928) and [Jolla Tablet](https://jolla.zendesk.com/hc/en-us/articles/208406917).  Note that the [Jolla 1 phone](https://jolla.zendesk.com/hc/en-us/articles/204709607) (which also has an "embedded recovery") does not use LVM by default, hence section 3.3 is not applicable to it (unless you have flashed [an LVM-image to it](https://talk.maemo.org/showthread.php?p=1549980#post1549980)).  Section 3.3 is also applicable to (most / all?) community ports of SailfishOS, but please check thoroughly that things really look the same as described.

1. Locate the file **hybris-recovery.img** in the unpacked SailfishX directory on your host computer.
   
2. Power down your Xperia and connect its USB cable to your host computer (but not the Xperia, yet).  Bring your Xperia into fastboot mode by pressing the "Volume up" button when plugging in your Xperia to USB.  Release the button when its LED has become blue. For devices reflashed with a community port of SailfishOS: Mind that the way to enter fastboot mode differs between brands of Android devices.

3. Execute `fastboot boot hybris-recovery.img` on your host computer.  You may need to execute the *fastboot* command as root, e.g., by prepending a `sudo`.

4. Wait until booting the recovery image finished: It displays a message in a very tiny font at the top of your Xperia's screen.

5. Execute `telnet 10.42.66.66` on your host computer. If you run into "telnet connection timed out" or "no route to host" errors, [this might be helpful](https://forum.sailfishos.org/t/resizing-root-directory-telnet-connection-problems/7067/3) (mind that these commands may also have to be executed as root).

Notes:

- Use a downloaded recovery image, which preferably matches the installed SailfishOS release, or is newer.

 Hence, if you have upgraded the SailfishOS installation on the device via OTA update (*Settings -> SailfishOS updates*, `sfos-upgrade` etc.) and want to use a recovery image, download the recent installation image, unpack it and boot this recovery image.

 Never use a significantly older recovery image than the installed SailfishOS release, because LVM commands, filesystem utilities and `cryptsetup` might be outdated!

- Do not flash an Xperia's recovery partition with it (which is technically possible and basically working), as this recovery image will be outdated and not matching anymore after a SailfishOS update on your Xperia. Furthermore you lose Sony's original Android recovery as a fallback by overwriting it with a SailfishOS recovery.

---

#### 3.3.2 Shrinking the "home" LVM volume and extending the "root" one

Do not be afraid of loosing a little space on your "home" volume, your user data (music, pictures / photos, offline maps, videos etc.) can be seamlessly outsourced to an SD card.

- For devices with 32 GiB internal FLASH memory (resulting in an original "home" volume size of approximately 20 GiB) aim at a "root" LVM size of 4 GiB for regular use respectively 6 GiB if you plan to install a lot of native software (Android APKs are installed on the "home" volume).

- For devices with 64 or 128 GiB of internal FLASH memory you might add additional 2 GiB to these values, because the "home" volume size is at least 37 GiB (even after resizing).

- If you really plan to install gcc and compile software on the device (which is technically feasible, but you should rather use the SailfishOS SDK on an x86 computer for that), add another 2 GiB or just aim at 10 GiB (the maximum for this scheme, see next point).

- As 10 GiB "root" LVM volume size is very spacious, more does not seem to make any sense. Thus the values chosen below only work for increasing the "root" volume size to at most 10 GiB (on both, 32 GiB and 64 GiB devices).

- For 64 or 128 GiB devices, the values of **10G** and **22000000** (below) should be tripled to **30G** and **66000000** in order to reduce unnecessary shrinking and expanding later on.  Solely on 128 GiB devices, multiplying the original values by 5 shall also work, i.e. using **50G** and **110000000**.

- When executing the steps of either section 3.3.2 (**a** or **b**), you may encounter the output (e.g., of a **lvm lvresize** command):

    `/dev/mmcblk0rpmb: read failed after 0 of 4096 at X: Input/output error`

  This specific error message is harmless and rather a bug. Mind that any other error message likely constitutes a real error.

- Select **3** for Shell in the recovery menu.

- Check with `lvm lvdisplay` that the "root" volume is comprised of 625 (logical) extents each 4 MiB in size.  Note that while the extent size on all devices using LVM has been 4 MiB, that may change for future devices, as the (physical) extent size shall be equal or larger than the erase block size of the device's eMMC FLASH memory (see `cat /sys/block/mmcblk0/device/preferred_erase_size` and `cat /sys/block/mmcblk0/queue/discard_granularity`).  Future device's eMMCs may have a larger erase block size, hopefully Jolla then increases the physical and consequently the logical extent size accordingly.

  If the extent size is not 4 MiB or the "root" volume is not comprised of 625 extents, do not use the **-l&nbsp;-xxxx** option for the **lvm&nbsp;lvresize&nbsp;&nbsp;sailfish/home** command (below), because the values are calculated for these preconditions, aiming at allocating an even number of extents.  You might resort to use the option **-L&nbsp;-xxxxM** instead (with one of the values given in parentheses; see [lvresize man-page](https://linux.die.net/man/8/lvresize) for details) then.

  If the "root" volume size is not 2500 MiB, you need to recalculate the value for the **lvm&nbsp;lvresize&nbsp;-l&nbsp;-xxxx&nbsp;sailfish/home** command (below).

---

##### 3.3.2.a  ... on devices / SailfishOS releases without home volume encryption

(All Xperia X and XA2 with SailfishOS 3.2.1 or lower installed, plus those Xperia X and XA2 originally flashed with SailfishOS 3.2.1 or lower which were upgraded to SailfishOS 3.3.0 or higher via OTA update (*Settings -> SailfishOS updates*) but [the device encryption was not activated](https://docs.sailfishos.org/Support/Help_Articles/Encryption_of_User_Data/#activation-from-settings))

1. `e2fsck -f /dev/mapper/sailfish-home`

2. Shrink size of "home" file-system to 10 GiB (you might use **30G** on 64&nbsp;GiB devices):

    `resize2fs /dev/mapper/sailfish-home 10G`

3. `e2fsck -f /dev/mapper/sailfish-home`

4. `lvm lvchange -a n sailfish/home`

5. Shrink "home" volume by -911 extents (=&nbsp;-3644M) for a 6 GiB, -1423 extents (=&nbsp;-5692M) for a 8 GiB, -399 extents (=&nbsp;-1596M) for a 4 GiB or -1935 extents (=&nbsp;-7740M) for a 10 GiB "root" volume size:

    `lvm lvresize -l -911 sailfish/home`

6. `lvm lvresize -l +100%FREE sailfish/root`

7. `lvm lvchange -a y sailfish/home`

8. `resize2fs /dev/mapper/sailfish-home`

9. `e2fsck -f /dev/mapper/sailfish-home`

10. `resize2fs /dev/mapper/sailfish-root`

11. `e2fsck -f /dev/mapper/sailfish-root`

12. Hit **Ctrl-D** (or type `exit`).

13. Select **2** for Reboot.

---

##### 3.3.2.b  ... on devices / SailfishOS releases with home volume encryption

([All Xperias newly flashed with SailfishOS 3.3.0 or higher, Xperia 10 series since SailfishOS 3.2.0, plus Xperia X and XA2 originally flashed with SailfishOS 3.2.1 or lower on which the device encryption was activated after being upgraded to SailfishOS 3.3.0 or higher](https://docs.sailfishos.org/Support/Help_Articles/Encryption_of_User_Data/#it-is-automatic-when-flashing))

1. Open the cryptsetup container (using your security code) per

    `cryptsetup luksOpen /dev/mapper/sailfish-home crypt-home`

2. `e2fsck -f /dev/mapper/crypt-home`

3. Shrink size of "home" file-system to 10 GiB (you might use **30G** *and* **66000000** (below) on 64&nbsp;GiB devices, respectively **50G** *and* **110000000** (below) on 128&nbsp;GiB devices):

    `resize2fs -f /dev/mapper/crypt-home 10G`

4. `e2fsck -f /dev/mapper/crypt-home`

5. Shrink size of cryptsetup container to 10,49 GiB (22000000 sectors á 512 Bytes; you might use **66000000** = 31,47 GiB on 64&nbsp;GiB devices, respectively **110000000** = 52,45 GiB on 128&nbsp;GiB devices):

    `cryptsetup resize -b 22000000 /dev/mapper/sailfish-home`

6. `cryptsetup close crypt-home`

7. `lvm lvchange -a n sailfish/home`

8. Shrink "home" volume by -911 extents (=&nbsp;-3644M) for a 6 GiB, -1423 extents (=&nbsp;-5692M) for a 8 GiB, -399 extents (=&nbsp;-1596M) for a 4 GiB or -1935 extents (=&nbsp;-7740M) for a 10 GiB "root" volume size:
   
    `lvm lvresize -l -1423 sailfish/home`

9. `lvm lvresize -l +100%FREE sailfish/root`

10. `lvm lvchange -a y sailfish/home`

11. `cryptsetup luksOpen /dev/mapper/sailfish-home crypt-home`

12. `cryptsetup resize /dev/mapper/sailfish-home`

13. `resize2fs -f /dev/mapper/crypt-home`

14. `e2fsck -f /dev/mapper/crypt-home`

15. `cryptsetup close crypt-home`

16. `resize2fs /dev/mapper/sailfish-root`

17. `e2fsck -f /dev/mapper/sailfish-root`

18. Hit **Ctrl-D** (or type `exit`).

19. Select **2** for Reboot.

---

### 4 Installing software

- Always check when the latest version of an app was released, regardless which app store you are using: If it is from before 2017 it likely does not run well.

- Also always read an app's description in any of the store client apps thoroughly before installing it.

- Additionally read the recent comments of an app in the Jolla Store client app respectively Storeman (for apps at OpenRepos).

---

#### 4.1 Using the Jolla Store

Open the Jolla Store app and install the "File Browser" (by ichthyosaurus, originally by Kari) to check if the Jolla Store is working fine (you will need a file browser sooner or later, anyway).

Advice for users of the Android runtime environment ("Android App Support"):

Do **not** install any Android apps from the Jolla Store (those with their icons labeled with a small, overlaid Android, plus the line "Android app" atop their description), not even the app stores' client apps offered there (F-Droid, Aptoide "Store", Yandex etc.), otherwise you may later run into troubles when updating these apps.  Background: Theoretically you may solely install Android apps from the Jolla Store (and never use any other Android store app, including the ones offered in the Jolla Store; only then updating APK cannot become an issue), which is not practically feasible due to the minimal and awkward selection of Android apps in the Jolla Store.

---

#### 4.2 Using OpenRepos (SailfishOS community repositories)

Optional, although strongly recommended.

1. Download the RPM of the current Storeman-Installer release from OpenRepos with the SailfishOS Browser: https://openrepos.net/content/olf/storeman-installer

2. Enable *Settings -> Untrusted software -> Allow untrusted software*.

3. Start the File Browser app and go to *Downloads*.  Tap on the downloaded Storeman-Installer RPM and wait a while (Storeman Installer 2; with Storeman-Installer 1 select *Install* in the top pulley).

4. Disable *Settings -> Untrusted software -> Allow untrusted software* again.

Alternatively you might install the downloaded RPM file at the CLI via `devel-su pkcon install-local <full-filename.rpm>`.

---

#### 4.3 Using the SailfishOS:Chum community repository

Optional, although strongly recommended, because new versions of some packages from OpenRepos are only published there.

Use Storeman to install the [SailfishOS:Chum GUI Installer](https://openrepos.net/content/olf/sailfishoschum-gui-installer), which automatically installs the correct variant of the SailfishOS:Chum GUI application for your device and installed SailfishOS release.  Alternatively you can manually download and install the [SailfishOS:Chum GUI Installer](https://openrepos.net/content/olf/sailfishoschum-gui-installer) as described for the Storeman-Installer in [section 4.2](#42-using-openrepos-sailfishos-community-repositories).

---

#### 4.4 Installing Patchmanager

Optional, although recommended.

1. Install [Patchmanager ≥ 3.2](https://openrepos.net/content/patchmanager/patchmanager) on SailfishOS ≥ 4, preferably  from SailfishOS:Chum (respectively [Patchmanager 3.0](https://openrepos.net/content/patchmanager/patchmanager-legacy) from OpenRepos on SailfishOS < 4).

2. Reboot your Xperia.

3. Browse Patchmanager's web-catalog in *Settings -> Patchmanager -> (top pulley) Web catalog* and install a Patch which sounds interesting for you and which is compatible with the installed SailfishOS release.

4. Go back to Patchmanager's main page and apply this Patch there.

5. Select *Restart preloaded services* in the top pulley and see what it does.

---

#### 4.5 Installing Android app stores' client apps

This requires the Android runtime environment ("Android App Support" / AlienDalvik) being installed and running, which is only available for paid SailfishX licenses.

- Note that installing APKs on SailfishOS does not require "Untrusted sources" enabled, because the Android runtime environment with all its installed APKs is separated from the SailfishOS installation proper and its native apps.

- Also note that APKs (Android apps) must be built for the ARMv7-A architecture (32 bit), because SailfishOS currently still solely uses 32 bit user space binaries.

Only SailfishOS (≥ 4.1.0) on an Xperia 10 II or III (out of the officially supported models) offers the ability to install and execute native apps (RPMs) and APKs (Android apps) for ARMv8-A ("aarch64", 64 bit).

---

#### 4.5.1 F-Droid

Optional, although strongly recommended, because F-Droid is the primary source of inherently privacy-friendly and FLOSS-only Android applications.

1. Download the recent F-Droid app in the SailfishOS Browser: https://f-droid.org/

  Alternatively, if you dislike the UI of the modern F-Droid app (since v0.104 / v1.0) or use an original Xperia X (because much more recent releases still run on Android 4.4), you might install the [F-Droid Classic app](https://f-droid.org/en/packages/eu.bubu1.fdroidclassic/) (which implements the classic F-Droid app UI atop a recent F-Droid client codebase), but it is less frequently updated than the regular [F-Droid app](https://f-droid.org/en/packages/org.fdroid.fdroid/). Another alternative F-Droid client for modern devices (requires Android ≥&nbsp;6) is ["Neo Store"](https://f-droid.org/en/packages/com.machiav3lli.fdroid/).  BTW, [G-Droid](https://f-droid.org/en/packages/org.gdroid.gdroid/) is very basic, but it is the only modern and maintained F-Droid client which still works on a Jolla 1, because it only requires Android ≥&nbsp;4.

2. Start the File Browser app and go to *Downloads*.

  Tap on the downloaded F-Droid client APK and select *Install* in the top pulley.

---

#### 4.5.2 A proper Android file-manager

As the "AlienDalvik" Android runtime environment does not provide any preinstalled apps, one needs a proper file-manager for Android to serve Android file intents:

Start an F-Droid client app (if it is its first start ever on this device, wait a couple of minutes for it to synchronise its repositories) and install the [OI File Manager](https://f-droid.org/en/packages/org.openintents.filemanager/).

---

#### 4.5.3 Google Play Store via Aurora Store app

For accessing the Google Play Store, install the [Aurora Store](https://f-droid.org/en/packages/com.aurora.store/) app by the F-Droid client app.

---

#### 4.5.4 Other Android app sources

Other Android apps stores or manually downloading and installing APKs is not recommended due the negative security implications: Downloading and installing apps from somewhere (specifically "someone"), plus (when doing this manually) never being informed about their updates.

If you really want to pursue this, use the app [APKMirror](https://f-droid.org/en/packages/taco.apkmirror/) and / or (but not on an Xperia X) [Apkpurer](https://f-droid.org/en/packages/gh.cloneconf.apkpurer/) from F-Droid to access the two best maintained (and probably least insecure) alternative sources for Android apps: [APKMirror](https://www.apkmirror.com/) and [APKPure](https://apkpure.com/)  *Edit(2023):* [Uptodown.com](https://en.uptodown.com/developer/uptodown-com) *may* be another viable alternative (unchecked and untested), but its client app is not offered at F-Droid (apps being offered at F-Droid provide a lot of positive security implications).

For updating apps from alternative sources (searching and installing is also possible, but inconvenient) you can use the app [ApkTrack](https://f-droid.org/en/packages/fr.kwiatkowski.ApkTrack/) from F-Droid and / or manually install the [latest release](https://github.com/rumboalla/apkupdater/releases/latest) of the app [APKUpdater](https://github.com/rumboalla/apkupdater#apkupdater--) from GitHub.  *Edit:* Both seem to be unmaintained as of 2023.

Do **not** use Aptoide, neither its client app (even though promoted by Jolla and an old version of the Aptoide app is available in the Jolla Store as "Store" app) or its web site: Aptoide offers a lot of malware (e.g., common apps with added malicious code, fake apps etc.), because anyone can upload anything there and Aptoide is not curated.  Furthermore Aptoide regularly has security breaches, e.g. a leak of their complete user database including passwords (the first time in plain text, the second time unsalted) at least twice!  Additionally the Aptoide app(s) has become a data collection tool.  Hence one **shall not use Aptoide** at all.  All software at Aptoide is available elsewhere, because it only hosts APKs uploaded by users!

BTW, by installing the original Google Play Store app, the Amazon Store app etc. you transform your SailfishOS device into a data collecting machine: Then you may use a regular Android device instead with far less effort.

---

#### 4.6 Installing microG

Optional; for Android apps which need Google services.  Not supported on the Xperia X, but by all later models (XA2 series, Xperia 10 series, Xperia 10 II and Xperia 10 III) since SailfishOS 3.1.

Requires to have "Android support" and an [F-Droid client app](#451-f-droid) installed.

- For SailfishOS ≥ 4.5.0 utilise [this wiki page at FSO](https://forum.sailfishos.org/t/installing-microg-on-sailfish-os/14375).

- For SailfishOS 3.1.0 to 4.4.0, follow the [original microG installation guide by SailfishOS community member "Dr. Yak"](https://together.jolla.com/question/209300/how-to-microg-in-sfos-31/?answer=209744#post-id-209744), which is easier than it looks at first sight.  When issues occur, do search at the [SailfishOS forum for "microG"](https://forum.sailfishos.org/search?q=microG).

Do **not** install original Google services (except for [Google's "Text-to-Speech (TTS)" engine](https://play.google.com/store/apps/details?id=com.google.android.tts), for which [ivonaTTS is an alternative](https://forum.sailfishos.org/t/xa2-and-ivonatts-no-voices-found/7270/6) although much larger, more intrusive, but with even better speech quality) or [OpenGApps](https://opengapps.org/): Then you might better use a regular Android device instead with far less effort.

---

### 5 Further recommendations

---

#### 5.1 Recommended apps from OpenRepos

- [MeeCast for SailfishOS](https://openrepos.net/content/vasvlad/meecast-sailfishos) with [Meecast Daemon](https://openrepos.net/content/vasvlad/meecast-daemon) and [Meecast Event View](https://openrepos.net/content/vasvlad/meecast-event-view).

 When choosing Weather.com as a (high quality) weather data provider it supersedes the proprietary Jolla Weather app (by Foreca) in every aspect.

- [Pure Maps](https://openrepos.net/content/rinigus/pure-maps) with [PicoTTS](https://openrepos.net/content/rinigus/picotts) and [OSM Scout Server](https://openrepos.net/content/rinigus/osm-scout-server) provide a "state of the art" navigation app utilising offline or online map and routing services.  *Note that since 2022 newer versions of these three components are solely published at SailfishOS:Chum and in a feature-reduced version at the Jolla Store.* 

- [Aliendalvik Control](https://openrepos.net/content/coderus/aliendalvik-control) ~~is~~ was extremely useful for users of the Android runtime environment ("Android App Support"). *Unmaintained since mid-2021, hence not working on SailfishOS 4 as of September 2022.*

---

#### 5.2 Guides for utilising an SD card to consider

- [Creating partitions on SD-card, optionally encrypted](https://gitlab.com/Olf0/guide-creating-partitions-on-sd-card-optionally-encrypted)

- [Externalising android_storage and other directories / files to SD-card](https://gitlab.com/Olf0/guide-externalising-android_storage-and-other-directories-files-to-sd-card)

---

### 6 Further guidance and sources of information

For further information always search first at

- The [SailfishOS Forum (FSO)](https://forum.sailfishos.org/), Jolla's current community platform (since 2020-07-09)

- [Together@Jolla.Com (TJC)](https://together.jolla.com/questions/), Jolla's old community platform
 Mind that the Askbot release running TJC has a [couple of flaws](https://together.jolla.com/question/168694/update-askbot-running-tjc-to-a-more-recent-version/).  E.g., Askbot's search function returns many seemingly unrelated *results*, though the search *suggestions* (i.e., in its JavaScript-based drop-down list) are quite spot on although usually sorted from old (at the top) to new (at the bottom)!

- [Jolla's Zendesk instance](https://jolla.zendesk.com/)

- Community documentation: e.g., https://github.com/sailfishos-community/awesome-sailfishos

- [Talk@Maemo.Org (TMO)](https://talk.maemo.org/)

- The "[SailfishOS cheat sheet](https://sailfishos.org/wiki/Sailfish_OS_Cheat_Sheet)"

- [Developer documentation (link list)](https://together.jolla.com/question/7008/looking-for-sailfishnemomer-system-documentation-i-am-lost/?answer=222262#post-id-222262)

For issues with a device using a paid license, you may open a [Zendesk support request](https://jolla.zendesk.com/) **after** having exhausted searching aforementioned sources of information and including everything relevant you found and have tried.

Have fun with SailfishOS on your Xperia!
 
P.S.: The [original repository for this guide](https://gitlab.com/Olf0/sailfishX) is here at Gitlab.com and it is also [rendered better here](https://gitlab.com/Olf0/sailfishX#guide-installing-sailfishx-on-xperias) (e.g., its formatting, especially enumerations across paragraphs) than [at TJC](https://together.jolla.com/question/222126/guide-installing-sailfish-x-on-xperias/) (except for the uncommon TOC markup and how the line spacings in this footer and TOC are rendered without some trickery). Furthermore, the version at TJC became outdated, because TJC was set to "read only" at the end of 2020, thus that version there cannot be updated anymore. Hence the canonical URL for this guide is https://gitlab.com/Olf0/sailfishX#guide-installing-sailfishx-on-xperias
