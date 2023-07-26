## Energy saving for Xperia 10 II and III


* `OS VERSION` : 4.5.0.19
* `HARDWARE` : Xperia 10 II dual SIM
* `ANDROID SUPPORT` : licenced and installed
* `UI LANGUAGE` : English

---

### APPROACH

Recently I set the enery saving mode at 100% of battery threshold which means always active:

* [using mcetool to change the power saving threshold](../knowhow/battery-recharge-and-power-saving.md)

Moreover, I dimmed the brightness of the screen to the minimum and I have installed and activated the [Pure Black Backgrounds ](https://coderus.openrepos.net/pm2/project/patch-i-see-a-red-door) patch which it expected to save energy with OLED display which is the case. The display is set to sleep after 30 seconds.

**DATA COLLECTED**

The [System Monitor](https://openrepos.net/content/basil/system-monitor) was running since the begging and collecting data. Here a composition of what I found:

<img src="power-consumption.png" width="400px" height="800px">

The high-resolution image is available for download from [here](https://drive.google.com/file/d/1EJvPc5XkaWFy07DPnLuiD9vSIBqkj7X6/view).

---

### SCENARIO

In the area highlighted, the smartphone was resting alone with no native nor Android application apparently running and with the `Android Support` active.

Despite this the activity about system processes were more intense that normal usage but despite this the battery discharge rate was less or about 1% which is a great achievement.

**OBSERVATIONS**

Counter sides effects: some sub-system was not working when the smartphone has been waked-up. In this specific case the Bluetooth. More often the fingerprints reader get asleep probably and should be reset.

* [Fingerprint reader restart in LockScreen](https://forum.sailfishos.org/t/fingerprint-reader-restart-in-lockscreen/15878/1)

There is a huge opportunity to extend the battery life leveraging the power save mode as far as all the hardware sub-system are awaken correctly and at expences of the response time because applications starting lag a bit.

This [Reduce settings app lag](https://coderus.openrepos.net/pm2/project/sfos-patch-settings-fix-startup-lag) patch changes the way in which the visualisation of some SFOS native menu/app are presented but not the time of starting of an Android apps.

---

### PROPOSAL

The `START` / `STOP` states for the `Android Support` are not enough because clicking on an Android app, also the `Android Support` starts automatically. It would be much better having an option to disable the `Android Support` to avoid that it can support any application without the express will of the user:

* `disabled, stopped` - A.S. is not running and it will not start automatically
* `disabled, running` - A.S. is put in a sleep state for which it results unavailable
* `enabled, stopped` - A.S. behave like now starting when requested by an app
* `enabled, running` - A.S. behave like now when it running giving the service

With these option the Android Support can be kept safely disabled but quickly to gives it service if the user need it. This will make the SailFish OS more reliable about Android apps background activities and more power energy saving.
