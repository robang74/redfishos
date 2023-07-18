[quote="spiiroin, post:7, topic:7322"]
[quote="Seven.of.nine, post:1, topic:7322"]
> Presently there’s only possible to automatically activate the power saving mode depending on the accu charge level (20%, 15%, 10%, 5%, off), or set manually until next time charger is connected.
> [/quote]
>
>
>
> Note that from command line you can select any percentage value, e.g.
>
>
>
>
>
> ```
> mcetool --set-psm-threshold=100 --set-power-saving-mode=enabled
> ```
[/quote]

IMHO, this group of settings `{20%, 15%, 10%, 5%, off}` should be extended with two others values `{90%, 50%, 20%, 15%, 10%, 5%, off}` where `50%` indicates a strong propency to saving energy and `90%` almost keep the phone locked in energy saving mode.

Moreover, the option:

* *Enable battery saving mode until charger is connected the next time*

should change in this more useful:

* *Enable battery saving mode until next time got charged at 90%*

The reason it is obvious, it is enough that I connect the smartphone just the time to trasfer some data from it with the MTP via USB and the energy saving mode will be reset to the normal but no a very little charge has been transfered to the battery.

Finally, the threshold in charging at `{80%, 90%}` will do the rest. In order to keep the smartphone always in energy saving mode. At the cost of few meaningful changes. Personally, I would add `70%` at the values above, for those the battery is somehow compromised.

Is it possible to generate a patch for `PatchManager` to changes this behaviour? Which files are involved in changing reconfiguring the UI and/or its business logic? Because for the message to change, it is supposed to be translated in many languages in order to correctly address the various localisations.

**POST SCRIPTUM**

The `mcetool` command line should be installed with

> `devel-su pkcon install mce-tools`

---

**OFF-LINE NOTES**

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

/sys/devices/platform/soc/4784000.sdhci/mmc_host/mmc1

cat /sys/devices/system/cpu/cpu?/online 

grep mmc1 /sys/kernel/irq/*/actions
/sys/kernel/irq/53/actions:mmc1

/usr/lib/systemd/systemd-udevd -D

systemctl restart systemd-udevd systemd-udevd-kernel.socket systemd-udevd-control.socket
systemctl status systemd-udevd systemd-udevd-kernel.socket systemd-udevd-control.socket

/usr/lib/systemd/systemd-udevd -D

[root@Sueza11 ~]# cat  /sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors
conservative powersave interactive performance schedutil 
[root@Sueza11 ~]# cat  /sys/devices/system/cpu/cpufreq/policy4/scaling_available_governors
conservative powersave interactive performance schedutil

a=/sys/devices/system/cpu; b=cpufreq/scaling_governor;
for i in $a/cpu[0-3]/$b; do echo "interactive" >$i; done; for i in $a/cpu[4-7]/$b;
do echo "conservative" >$i; done; mcetool --set-power-saving-mode=enabled \
--set-low-power-mode=enabled --set-psm-threshold=100 --set-forced-psm=disabled \
--set-ps-on-demand=enabled;

mcetool --set-cpu-scaling-governor=performance
for i in $(find /sys/block/mmcblk0/ /sys/block/mmcblk0rpmb/ -name control | grep "power/control");
do echo on >$i; done
sync; echo 3 > /proc/sys/vm/drop_caches

gpstoggle | grep -E "location status: 1|power status: 1" | wc -l | grep 1 && gpstoggle location=0 power=0

for i in /sys/devices/system/cpu/cpu[0-3]/cpufreq/scaling_governor; do echo "interactive" >$i; done

for i in /sys/devices/system/cpu/cpu[4-7]/cpufreq/scaling_governor; do echo "conservative" >$i; done

mcetool \
	--set-power-saving-mode=enabled \
	--set-low-power-mode=enabled \
	--set-psm-threshold=100 \
	--set-forced-psm=disabled \
	--set-ps-on-demand=enabled

mcetool \
	--set-brightness-fade-dim=1000 \
	--set-brightness-fade-als=1000 \
	--set-brightness-fade-blank=1000 \
	--set-brightness-fade-unblank=150 \
	--set-brightness-fade-def=150 \
	--set-als-autobrightness=enabled
	
Super saving

mcetool \
	--set-power-saving-mode=enabled \
	--set-low-power-mode=enabled \
	--set-psm-threshold=100 \
	--set-forced-psm=enabled \
	--set-ps-on-demand=disabled
	
for i in /sys/devices/system/cpu/cpu[0-7]/cpufreq/scaling_governor;
do echo "performance" >$i; done

mcetool \
	--set-power-saving-mode=disabled \
	--set-low-power-mode=disabled \
	--set-psm-threshold=10 \
	--set-forced-psm=disabled \
	--set-ps-on-demand=enabled
```
