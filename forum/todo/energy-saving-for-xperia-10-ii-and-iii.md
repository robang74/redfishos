## Energy saving for Xperia 10 II and III

* `OS VERSION`: 4.5.0.19
* `HARDWARE`: Xperia 10 II dual SIM
* `ANDROID SUPPORT`: installed
* `UI LANGUAGE`: English

---

### Approach

Recently, I set the energy saving mode at 100% of the battery threshold, which means it is always active:

* [using mcetool to change the power saving threshold](../knowhow/battery-recharge-and-power-saving.md)

Moreover, I dimmed the brightness of the screen to the minimum, and I have installed and activated the [Pure Black Backgrounds ](https://coderus.openrepos.net/pm2/project/patch-i-see-a-red-door) patch, which was expected to save energy with the OLED display, which is the case. The display is set to sleep after 30 seconds.

---

### Data collected

The [System Monitor](https://openrepos.net/content/basil/system-monitor) has been running since the beginning and collecting data. Here is a composition of what I found:

<img src="power-consumption.png" width="400px" height="800px">

The high-resolution image is available for download from [here](https://drive.google.com/file/d/1EJvPc5XkaWFy07DPnLuiD9vSIBqkj7X6/view).

---

### Scenario

In the area highlighted, the smartphone was resting alone with neither a native nor an Android application apparently running and with `Android Support` active.

Despite this, the activity about system processes was more intense than normal usage, but despite this, the battery discharge rate was less than 1%, which is a great achievement.

---

### Observations

Counter side effects: some sub-systems were not working when the smartphone was woken up. In this specific case, the Bluetooth. More often than not, the fingerprint reader gets asleep and probably should be reset for being awaken.

* [fingerprint reader restart in LockScreen](fingerprint-reader-restart-in-lockscreen.md)

There is a huge opportunity to extend the battery life by leveraging the power-saving mode as long as all the hardware subsystems are awakened correctly, but at the expense of the response time because applications are starting to lag a bit.

This [reduce settings app lag](https://coderus.openrepos.net/pm2/project/sfos-patch-settings-fix-startup-lag) patch changes the way in which the visualisation of some SFOS native menus or apps are presented but not the time an Android app needs for being put in run.

---

### Proposal

The `START` and `STOP` states for the `Android Support` are not enough because, when clicking on an Android app, the `Android Support` starts automatically. It would be much better to have an option to disable `Android Support` to avoid that it can support any application without the express will of the user:

* `disabled, stopped` - A.S. is not running, and it will not start automatically.
* `disabled, running` - A.S. is put in a sleep state for which it results in being unavailable.
* `enabled, stopped` - A.S. behaves like now, starting when requested by an app.
* `enabled, running` - A.S. behaves like now when it is running, providing the service.

With these options, Android Support can be safely disabled but quickly given if the user needs it. This will make the SailFish OS more reliable about Android app background activities and more energy-efficient.

---

### Further investigation

My Xperia 10 II is running with energy and power saving always active, and at the beginning it showed some troubles with Bluetooth and fingerprint reader awakening, which forced me to reset those sub-systems.

After having configured some options about suspending/awakening hardware subsystems in Android while I was running the Android Support, the Bluetooth and fingerprint reader never got stuck anymore, even with AS stopped.

However, the counterside is that my smartphone - when left alone without any interaction or connections active - started to be busy in suspending or waking the system, continuously loading the CPU for 25%, but with no impact on the battery discharge rate (less than 1%), because the CPU seems busy by System Monitor handling I/O, but no power is drained because there is no code nor math processing.

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

If what is written above is correct (because correlation does **not** necessarily mean a cause-and-effect relationship), then `SFOS` should correctly set the FP reader about suspending or awakening.

About Bluetooth, one single event, even in conjunction with the FP reader failure, makes the assumption statistically too weak.

<img src="nightly-sleeping-awakening.png" width="837px" height="478px">

Original hi-res image is [here](https://drive.google.com/file/d/1nHU4bdjLfSURLdnk8n2IRDYjOMrKY5xp/view).

---

### CPU governors

> @direct85 wrote:
>
> Another yolo test: setting the governor to `ondemand` yields the lowest frequencies when idling, but boosting rapidly when needed:
>
> ```
> echo -n "ondemand" > /sys/devices/system/cpu/cpuX/cpufreq/scaling_governor
> ```
>
> where `cpuX` is `cpu0` , `cpu1` … `cpu7` .
>
> The default values were `schedutil` for cpu0…5 and `performance` for cpu6…7.

Here are about 100 options for power governors:

* [Saber's guide on CPU governors, I/O schedulers, and more!](https://forum.xda-developers.com/t/ref-guide-sabers-guide-on-cpu-governors-i-o-schedulers-and-more.3048957/)

But those available are listed here:

```
# cat  /sys/devices/system/cpu/cpufreq/policy[0-7]/scaling_available_governors
conservative powersave interactive performance schedutil
```

It would be possible to keep 4 CPUs in a `conservative` mode and 4 in `schedutil` mode or any combination thereof. I am not aware if it is better to run at full throttle with a few CPUs or keep them balanced.

I am trying this configuration:

```
for i in /sys/devices/system/cpu/cpu[0-3]/cpufreq/scaling_governor;
do echo "interactive" >$i; done

for i in /sys/devices/system/cpu/cpu[4-7]/cpufreq/scaling_governor;
do echo "conservative" >$i; done

mcetool \
	--set-power-saving-mode=enabled \
	--set-low-power-mode=enabled \
	--set-psm-threshold=100 \
	--set-forced-psm=disabled \
	--set-ps-on-demand=enabled
```

Different hardware has different configurations, but most of the commands are the same.

* Xperia 10 III : Octa-core (2x2.0 GHz Kryo 560 Gold + 6x1.7 GHz Kryo 560 Silver)

* Xperia 10 II : Octa-core (4x2.0 GHz Kryo 260 Gold + 4x1.8 GHz Kryo 260 Silver)

Therefore, it makes sense to have two different governor policies for the two CPUs sets:

```
for i in /sys/devices/system/cpu/cpu[0-1]/cpufreq/scaling_governor;
do echo “ondemand” >$i; done

for i in /sys/devices/system/cpu/cpu[2-7]/cpufreq/scaling_governor;
do echo “conservative” >$i; done
```

The differences for Xperia 10 III in the shell script are very small.

<sup>________</sup>

**Sleeping CPUs**

Considering also the application of the [udev patch](https://coderus.openrepos.net/pm2/project/x10ii-iii-udev-rules-fixing) at the system level, when the SFOS is correctly configured, the CPUs finally sleep like dead rats while the UI is still responsive:

<img src="sleeping-cpus-like-dead-rats.png" width="214px" height="500px">

Despite the results achieved, these messages in the system log are NOT completely gone. They were just mitigated. It seems that the [problem is known](https://forum.sailfishos.org/t/xperia-10-ii-bugs/6321/37) since SFOS v4.4.0.68, at least.

```
[  +0.000108] OOM killer enabled.
[  +0.000001] Restarting tasks ... done.
[  +0.013891] PM: PM: suspend exit 2023-07-03 18:52:53.726781389 UTC
[  +0.000002] PM: suspend exit
[  +0.048486] ## mmc1: mmc_gpio_set_uim2_en: gpio=101 value=1
[  +0.057462] PM: PM: suspend entry 2023-07-03 18:52:53.832776345 UTC
[  +0.000005] PM: suspend entry (deep)
[  +0.000003] PM: Syncing filesystems ... done.
[  +0.003319] Freezing user space processes ... 
[  +0.011845] PM: Wakeup pending, aborting suspend
[  +0.000066] Freezing of tasks aborted after 0.011 seconds
```

These below, continue to pollute the `syslog` but I am investigating them as well.

```
[  +1.003158] binder: 2784:2784 transaction failed 29189/-22, size 32-0 line 3096
[  +1.001224] binder: 2784:2784 transaction failed 29189/-22, size 32-0 line 3096
```

The `transaction failed` messages are from `ofono` (pid: 2784). If killed, it respawns and starts again to make such a show. In fact, after activating the `Android Support`, it calms down.

---

### Most time-active processes

The most promising candidates for optimizations are `d-bus` and `lipstick` daemons because, using `htop` and ordering the processes for time spent in `CPU`, these two are the winners.

However, with the `udevd` patch above applied and the power management configuration shown in the CPU GOVERNORS section, the `CPU` usage did not impact the battery anymore.

In fact, the discharge rate with `4G` and `WiFi` tethering active is around 6% per hour, which means that with a fully charged battery, there are about 16 hours of working as a 4G-Wifi tethering router with some sporadic user interactions.

---

## Power saving templates

It makes sense to develop and adopt a few templates, which are system configurations about power management.

Below is a description of these templates in terms of their features.

<sup>________</sup>

**A. nightly stand-by**

1. `WiFi`, Bluetooth, mobile data, fingerprint readers, sensors, photo cameras, and `GPS` should be turned off, and as far as possible, their hardware subsystems should be powered off. For the `GPS`, the [gpstoggle](https://openrepos.net/content/halftux/gpstoggle) can do that, but for the other hardware subsystems, I have not checked, yet.

2. The `Android Support` should be disabled, and `zRAM` swap should be off-loaded with [the script from this patch](https://coderus.openrepos.net/pm2/project/zram-swap-resize-script).

3. CPUs [0-3] for the Xperia 10 II and CPUs [0-1] for the Xperia 10 III should be set to the minimum working frequency and to `conservative` scaling mode. The other CPUs, the same but put off-line (all the processes will switch to other online CPUs). Linux kernel, real-time, and a few specific system processes that need to deal with time jittering tend to rely on CPU #0 only. Moreover, because [0–3] belong to the same multiple-core CPU, all of them can be kept online.

4. the external `MMC` card should be unmounted and its hardware controller powered off, while the internal `SSD` flash should be put in power-saving mode.

5. the display should be kept powered off unless hardware keys are triggered.

Considering that on the Xperia 10 II, the CPUs [0-4] are 1.8GHz while the others are at 2.0GHz, the first CPUs set is also the one more conservative in terms of power consumption. Instead, in the Xperia 10 III the most powerful CPUs will probably be at [7-8] enumeration. Therefore, for the Xperia 10 III, putting just those 2 cores off-line will result in a smaller power save.

<sup>________</sup>

**B. daily stand-by**

This template is similar to *night stand-by* but with these differences:

* the second set of CPUs is kept online without enforcing their working frequency, but the maximum working frequency can be limited to half of the hardware maximum working frequency, aka the top scaling cap.

* the `Android Support` - if it is running - keeps running, thus the `zRAM` swap off-loading will not be performed when this template is applied, unless the `Android Support` is not running.

* only the hardware related to unused/inactive services (WiFi, Bluetooth, GPS, mobile connection, etc.) should be powered off.

* sensors should be kept powered on because they can be useful for some apps, like shaking the phone to switch on/off the flashlight, but not the compass unless `GPS` is active or used by an application. Like the fingerprint reader, the compass should be awakened when requested by an application.

* external MMC can be mounted and kept ready. Most depends on how fast / reliably we can `mount` and `umount` such a partition when it is not used by any application or by the implication of having a fake-root filesystem-overlay (probably none, but it has to be verified and tested).

<sup>________</sup>

**C. daily power-saving mode**

This template is similar to *daily stand-by* but with these differences:

* the first set of `CPU`s are put in `interactive` (mark2) or `ondemand` (mark3) frequency scheduling policy, while the others are in `conservative` mode. A top cap about the maximum working frequency can be set for the second group of `CPU`s. Therefore, the user can decide between *daily power saving* mode or *daily power saving plus* mode by selecting one or another.

* without the *plus* option activated, the internal flash is set to a more responsive mode rather than the power-saving mode.

<sup>________</sup>

**D. daily performance mode**

When a battery is less important than productivity or the smartphone is connected to a power source, then all the policies can be set to the most performing option available.

<sup>________</sup>

**E. general settings**

These following settings apply to all the power management templates.

* The fingerprint reader and the photo cameras should be kept switched off unless there are a few cases in which they should be temporarily awakened for their duty.

* The `GPS` should be powered off when it is not used. The same for Bluetooth and `WiFi` subsystems.

* The `WiFi` tethering should not ask which is the source  of data networking (`SIM1`, `SIM2`, `WiFi`) because the user may want to use it to access the smartphone locally and we do not know which network services s/he installed to be used. Moreover, when WiFi tethering is asking for which source should be used to share the data connection, it mess-ups the state of the toggle button in the topmenu about mobile data when a SIM is chosen. Under this PoV the related Settings page should be renamed from "internet sharing" to "wifi tethering" .

* The WiFi tethering should be powered off when it is not used by any client for a user-customizable timeout (eg. 5, 10, 15, 30, 60 minutes), but the user can disable this by default.

* Few default native applications take too much time to be started {phone, `SMS`/text, contacts/people, photo camera} but these applications are supposed to be used also in emergency situations like calling 112/911, calling or texting the home or family, taking a shot or video of an incident, and any other situations in which a photo or video proof can have a sensible impact on legal consequences. For this reason, these apps should be put in run, kept in run, restarted quickly when they are not running (1-min or immediately waiting on their `/proc/$pid/cmdline`¹) as many times is necessary, and the user should be notified when N restarts fail consecutively in such a way s/he can act accordingly.

* The default camera app should be replaced in the above role by the [Advanced Camera](https://openrepos.net/content/piggz/advanced-camera) when the end-user decides so (optional). Therefore, a Settings page about always-running apps should be created.

* Some other native default apps that the user can optionally decide to keep ready are clock/alarms, calendar, todo list, and notes. These apps lag-to-start can have a social impact: if you are in a hurry and meet a person, then you need to set some schedule, alarm, or simply take a note or to-do reminder. Some to-do reminders should have an alarm associated with them, but I did not see this feature implemented.

* The always running native apps should not be closed in the default way (with `kill $pid`, probably) but set to a suspended state (with `kill -STOP $pid`) and then awaken when they are started again (with `kill -CONT $pid`). This is an efficient way to have them ready to run.

<sup>________</sup>

**Notes**

¹ In all the Linux systems that I had the chance to work on, the `/proc/$pid/cmdline` still exists when a process is terminated, but it is a zombi. In such a case, a `procfs` item is void with a zero size. Therefore, the suggestion to wait on `/proc/$pid/cmdline` is not completely correct, but choosing another instance in the same folder is subjective or arbitrary.

---

## About the future of SFOS

Before answering this question, we should agree on what is `SFOS` and what is not. However, I wish to skip this premise and go straight to the point with this image:

<img src="sfos-sleeping-untouched.png" width="1024px" height="478px">

The original high-resolution image is [here](https://drive.google.com/file/d/1TojQHjOUG_fB1MJbPXxj0fAQP3Dp48Bf/view).

What does this image show? A sleeping system, when untouched, consumes 5% of battery per hour, which means 20 hours of standby. It is not a great achievement because it should be 100 hours of standby for an optimised system ([here](../knowhow/standby-battery-high-drain-on-x10iii.md)).

On the other hand, we notice that `CPU` stops being polluted, falls asleep, and awakens constantly (sleep, awake, sleep, awake), apparently without a real need. BTW, the system consumed 5%/h of battery - while untouched with the `CPU` s which **NEVER** goes to sleep. This means that apart from the display consumption and `4G` and `WiFi` connections, the system was running 100% of the time.

Now, with the `4G` data mobile and `WiFi` tethering connections active, it sucks 6%/h. Therefore, the changes tested are more suitable for a daily calm working session than keeping the smartphone near our bed while we are sleeping, check out ([here](#power-saving-templates)).

<sup>________</sup>

**How did I achieve this?**

This is the log of that day and changes:

1. in the morning, I developed [this patch to fix a few udev rules](https://coderus.openrepos.net/pm2/project/x10ii-iii-udev-rules-fixing) and applied it to the system: reloading and restarting the systemd-udevd and related services would have been enough, but I did a reboot to be 100% sure to not have bad surprises after.

2. During the day, I used it with different applications and for several tasks also with `Android Support` and Android apps.

3. Before leaving the smartphone untouched for 4 hours, I did a swap offload using [the script conveyed by this patch](https://coderus.openrepos.net/pm2/project/zram-swap-resize-script) about `zRAM` and applied some power management rules (not published yet) about CPUs and internal `SSD` flash devices.

<sup>________</sup>

**Why does this achievement matters?**

From the point of view of the performances, it is not a game changer. From the `PoV` of bringing the `OS` part of `SailFish OS` under strict control - in particular about power management vs performances - it is a huge advancement.

After all, the great business that Google and Apple did was not about their `OS` but about their market revenues. In fact, there is no hope for app developers to earn good money as long as the operating system below their app is out of control and does not provide consistently good performance.

Which is the reason why the Linux kernel won the global challenge of being adopted. Also in this case, the great business is not about the kernel itself but about all the applications that can run because that kernel delivers a consistent good `QoS` (quality of service).

Think about this, because it is about the future of `SFOS` much more than everything else.
