## Energy saving for Xperia 10 II and III

* `OS VERSION` : 4.5.0.19
* `HARDWARE` : Xperia 10 II dual SIM
* `ANDROID SUPPORT` : licenced and installed
* `UI LANGUAGE` : English

---

### APPROACH

Recently I set the energy saving mode at 100% of battery threshold which means always active:

* [using mcetool to change the power saving threshold](../knowhow/battery-recharge-and-power-saving.md)

Moreover, I dimmed the brightness of the screen to the minimum and I have installed and activated the [Pure Black Backgrounds ](https://coderus.openrepos.net/pm2/project/patch-i-see-a-red-door) patch which it expected to save energy with OLED display which is the case. The display is set to sleep after 30 seconds.

---

### DATA COLLECTED

The [System Monitor](https://openrepos.net/content/basil/system-monitor) was running since the beginning and collecting data. Here a composition of what I found:

<img src="power-consumption.png" width="400px" height="800px">

The high-resolution image is available for download from [here](https://drive.google.com/file/d/1EJvPc5XkaWFy07DPnLuiD9vSIBqkj7X6/view).

---

### SCENARIO

In the area highlighted, the smartphone was resting alone with no native nor Android application apparently running and with the `Android Support` active.

Despite this the activity about system processes were more intense that normal usage but despite this the battery discharge rate was less or about 1% which is a great achievement.

---

### OBSERVATIONS

Counter side effects: some sub-system were not working when the smartphone has been waked-up. In this specific case the Bluetooth. More often the fingerprints reader gets asleep probably and should be reset.

* [Fingerprint reader restart in LockScreen](fingerprint-reader-restart-in-lockscreen.md)

There is a huge opportunity to extend the battery life leveraging the power save mode as far as all the hardware subsystem are awaken correctly and at expense of the response time because applications starting lag a bit.

This [Reduce settings app lag](https://coderus.openrepos.net/pm2/project/sfos-patch-settings-fix-startup-lag) patch changes the way in which the visualisation of some SFOS native menu/app are presented but not the time of starting of an Android apps.

---

### PROPOSAL

The `START` / `STOP` states for the `Android Support` are not enough because clicking on an Android app, also the `Android Support` starts automatically. It would be much better having an option to disable the `Android Support` to avoid that it can support any application without the express will of the user:

* `disabled, stopped` - A.S. is not running and it will not start automatically
* `disabled, running` - A.S. is put in a sleep state for which it results unavailable
* `enabled, stopped` - A.S. behave like now starting when requested by an app
* `enabled, running` - A.S. behave like now when it running giving the service

With these options the Android Support can be kept safely disabled but quickly gives it service if the user needs it. This will make the SailFish OS more reliable about Android apps background activities and more energy saving.

---

### FURTHER INVESTIGATION

My Xperia 10 II is running with energy power saving always active and at the beginning it shown some troubles about bluetooth and fingerprint reader awakening which forced me to reset that sub-systems.

> *I should **not** say this because it will be considered trolling* but… :sweat_smile:

After having configured some options about suspending/awakening hardware subsystems in Android while I was running the Android Support, the bluetooth and fingerprint reader reader never got stuck anymore even with AS stopped. However, the counter side is that my smartphone - when left alone without no any interaction or connections active - started to be busy in suspend/awake the systems continuously loading the CPU for 25% but with no impact on the battery discharge rate (less than 1%) because the CPU seems busy by System Monitor handling I/O but no power is drained because there is no code/math processing.

In fact, the `dmesg -Hw` shows a lot of this stuff on the WARN level and above:

<sub>

```
[  +0.000236] ------------[ cut here ]------------
[  +0.000202] WARNING: CPU: 7 PID: 6013 at /home/abuild/rpmbuild/BUILD/kernel/sony/msm-4.14/kernel/mm/vmscan.c:1685 isolate_lru_page+0x1e0/0x1e8
[  +0.000365] ---[ end trace b94aa1c373c520dc ]---

[  +0.001869]  cache: parent cpu2 should not be sleeping

[  +0.026021] OOM killer enabled.
[  +0.000003] Restarting tasks ... done.
[  +0.022791] PM: PM: suspend exit 2023-06-18 08:17:15.039700682 UTC
[  +0.000003] PM: suspend exit
[  +0.045724] ## mmc1: mmc_gpio_set_uim2_en: gpio=101 value=1
[  +4.943132] PM: PM: suspend entry 2023-06-18 08:17:20.028365718 UTC
[  +0.000016] PM: suspend entry (deep)
[  +0.000010] PM: Syncing filesystems ... done.
[  +0.015110] Freezing user space processes ... (elapsed 0.040 seconds) done.
[  +0.040466] OOM killer disabled.
[  +0.000002] Freezing remaining freezable tasks ... (elapsed 0.003 seconds) done.
[  +0.003784] Suspending console(s) (use no_console_suspend to debug)
[  +0.029206] Disabling non-boot CPUs ...
[  +0.002401] CPU1: shutdown
[  +0.005101] CPU2: shutdown
[  +0.004633] IRQ 7: no longer affine to CPU3
[  +0.000259] CPU3: shutdown
[  +0.004800] CPU4: shutdown
[  +0.003805] CPU5: shutdown
[  +0.003962] CPU6: shutdown
[  +0.004003] CPU7: shutdown
[  +0.003154] suspend ns:   30885642235516 suspend cycles:    1068241562170
[  -0.000010] resume cycles:    1069294245240
[  +0.000854] Enabling non-boot CPUs ...
[  +0.001628] CPU1 is up

[  +2.401109] somc_panel_color_manager: somc_panel_inject_crtc_overrides (788): Override: Already have original funcs! Is setup called twice??
[  +0.000435] somc_panel_color_manager: somc_panel_pcc_setup (886): Cannot read uv data: missing command
```

</sub>

If what written above is correct (because correlation does **not** necessarily means cause-effect relationship) then `SFOS` should correctly set the FP reader about suspend/awakening. About bluetooth, one single event even in conjunction with the FP reader failure make the assumption statistically too weak,

<img src="nightly-sleeping-awakening.png" width="1024px" height="585px">

Original hi-res image is [here](https://drive.google.com/file/d/1nHU4bdjLfSURLdnk8n2IRDYjOMrKY5xp/view).
