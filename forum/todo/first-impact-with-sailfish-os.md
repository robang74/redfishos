## First impact with SFOS

These are the notes collected in the first month of SailFish OS 4.5.0.19 usage.

### Installation
 
I followed the official installation procedure which suggest to upgrade to Android 11 but not to downgrade:

* [How to install Sailfish X on Xperia™ 10 II on Linux](https://jolla.com/how-to-install-sailfish-x-on-xperia-10-ii-on-linux/)

Therefore the initial smartphone conditions were not completely matched because it was delivered with Android 12 instead of 11.

---

### System data

* Xperia X10 II dual SIM, model XQ-AU52 originally with Android 12
* Sailfish OS Jolla-4.5.0.19 qau52-1.0.0.19
* Sony binaries 10.0 kernel 4.14 seine
* AOSP Android 11 59.1.A.2.169
* Free (gratis) licence

--- 

### Shortcomings

* critical : no SIMs, GPS on, WLAN connected, but no position: InfoGPS found 7 satellites 0 lock

* critical : SIM in routing, network manual selection is slow and often back to search

* annoying : automatic time zone does not work even with an internet connection and GPS on

* annoying : Xperia 10 II mobile data does not work in 2G and 3G networks on SIM2, which is a known issue¹ but [it works for me](https://forum.sailfishos.org/t/release-notes-struven-ketju-4-5-0-19/15078/38) on a Xperia 10 II with 4.5.0.19 (customisations: my ofono is allowed to load the qmi plug-in, which by default is disabled + the network on SIM2 is set manually).

* function: InfoGPS is installed among other default applications for GPS testing at first installation.

* aesthetic: SIM renaming and signal strength bars are missing in the "Mobile Network(s)" config menu.

* aesthetic: in the Settings:Apps page, every icon should be added a subscript-i for info²

* The GPS failure can influence the time zone as well, and without a position, Finland is the default? (yes, when an internet connection is also unavailable).

---

### Suggestions

Here are a couple of suggestions, but about the second, keep in mind that it has been developed just in the first month of usage, and just at the second month, it seems not so viable, unfortunately for the SFOS which has not shown any sensible improvement in any way after the full licencing compared to the free version. The main difference is about additional functionalities, among others, Alien Dalvik Android Support and Microsoft Exchange support.

* Fixing the critical issues in the same order listed above

* Offer a try-and-buy-or-reset licence.

The try-and-buy-or-reset licence would last, e.g. 30 days and it might be free or cost €5. It lets the user try the Sailfish OS full licence features and then decide to pay in full the licence fee (€49 - €5) or have the phone reset to the free licence, or better locked than reset, like ransomware but legal.

Personally, I would buy it just to see if there is some way (upgrade, patch) that fixes or improves considerably the performance.

About the first two critical issues:

 * [GPS signal very bad](https://forum.sailfishos.org/t/gps-signal-very-bad/13026) (sept, 2022)

I hope that issues (GPS cannot lock satellites, routing manual networks) are regressions, is that right? Uhm, not really recent, at least.

---

### Early fixing efforts

I have tried to apply this suggestion, hoping that it will fix the GPS problem at reduced privacy counterbalance:

* [MLS Manager](https://forum.sailfishos.org/t/sailfish-community-news-25th-february-sdk-openssl/5179/1)

> :information_source: **Note**
> 
> Back in March of last year, Mozilla changed the terms of access to the Mozilla Location Service (MLS), with the unfortunate consequence that Jolla was no longer able to use it as part of the default Sailfish OS install. While GPS is still perfectly usable without MLS, it unfortunately does mean it takes longer to get a fix, especially in cases where GPS hasn’t been used for a while or is reactivated at a significant distance from the last place it was used. Happily, the ever-ingenious Sailfish community has come up with a workaround in the form of MLS Manager by Samuel Kron, which allows location data to be downloaded to your phone for offline use. Being offline means no sensitive data is sent over the Internet, but if you use it, don’t forget to alter your location settings to enable offline lookups in Settings -> Location -> Select custom settings -> Enable GPS and Offline positioning, disable Online positioning.

Obviously, downloading data that helps to get faster localization in urban areas or city centres would not solve the problem of not having access to the real-time GPS hardware subsystem.

A user find out that reverting back to Android 11 can be considered a work-around:

* [GPS Experiences after flashing with Android 11](https://forum.sailfishos.org/t/gps-experiences-after-flashing-with-android-11/11079/1)

I have tried also this, but it does not work without downgrading to Android 11:

* [Fix XA2 GNSS(GPS): Let’s Try harder](https://forum.sailfishos.org/t/how-to-hardware-fix-xa2-gnss-gps-lets-try-harder/11875/54)

Please check the [flashing tools page](../knowhow/flashing-tools-Xperia-phones.md) for more information.

---

### Forum feedbkacks

> @rgp wrote:
> 
> Not a fix, but something that will make your life a little easier is a patch by @carmenfdezb which will let you add an Android Support toggle button to the Top Menu:
[https://coderus.openrepos.net/pm2/project/android-support-button](https://coderus.openrepos.net/pm2/project/android-support-button)

This patch is not compatible with the last version 4.5.0.19 in which there is a similar icon for the top-menu but it brings it to the Android Support page. Instead, the button created by this patch is supposed to enable/disable the Android Support. Is that right? Will the author update it also for the last version?

> @carmenfdezb wrote:
> 
> and select ‘No’ in ‘Check version’ option

Thanks. In fact, at this time I have the *strict check version* enabled. Once disabled, I can install the patch.

---

### Notes

¹ [Known Issues](https://docs.sailfishos.org/Support/Releases/Known_Issues/) reported on Sailfish OS Documentation
² despite the top-menu header Apps, System, Accounts is easy to confuse the new users with the apps list from which the applications can be started instead of queried.
