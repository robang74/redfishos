## Battery recharge and power-saving

A longer page about power-saving dedicated to the Xperia 10 II and III is available [here](../todo/energy-saving-for-xperia-10-ii-and-iii.md). Instead, this page is focused on user-tailored power management for SailFish OS in general, and it also includes the battery recharge thresholds for a long battery life plus a brief essai about screen brightness.
 
> @spiiroin wrote:
> >
> > @Seven.of.nine wrote:
> >
> > Presently there's only possible to automatically activate the power saving mode depending on the accu charge level (20%, 15%, 10%, 5%, off), or set manually until next time charger is connected.
> > Note that from command line you can select any percentage value, e.g.
> ```
> mcetool --set-psm-threshold=100 --set-power-saving-mode=enabled ```

In my opinion, this group of settings `{20%, 15%, 10%, 5%, off}` should be extended with two other values `{100%, 50%, 20%, 15%, 10%, 5%, off}` where `50%` indicates a strong propensity to save energy and `100%` always keeps the phone locked in energy-saving mode.
 
Moreover, the option:
 
* *Enable battery-saving mode until the charger is connected the next time*
 
should change to make this more useful:
 
* *Enable battery-saving mode until the battery gets charged next time*
 
The reason is obvious: it is enough that the smartphone is connected just to transfer some data from it with the MTP via USB, and the energy saving mode will be reset to normal, but very little charge will be transferred to the battery. The threshold for the battery recharging at `{80%, 90%, 100%}` will do the rest.
 
Finally, because it is not installed by default, the `mcetool` command line should be installed with:
 
* `devel-su pkcon install mce-tools`
 
This means that the UI does not use it for changing the thresholds and therefore is not strictly necessary, but d-bus.

<sup>________</sup>

**Screen brigthness**

The other setting to operate on in order to save energy is screen brightness.
 
In this case, there are three different aspects that can be optimised:
 
- the brightness settings available with `mcetool` and d-bus
 
- a proper use of the light sensor embedded in the smartphone
 
- improve the `mcetool` without breaking the back-compatibility
 
In particular, the second one seems to be the most work-intensive task of the two and also the least optimised at the moment.
 
However, before starting about light sensor management, it will be important to clearly understand how the various settings are working because their descriptions, especially in some cases, are definitely not very useful in describing their effective role. This is the reason for the third point in the task list above.

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

[root@Sueza11 ~]# cat /sys/devices/system/cpu/cpufreq/policy0/scaling_available_governors
conservative powersave interactive performance schedutil
[root@Sueza11 ~]# cat /sys/devices/system/cpu/cpufreq/policy4/scaling_available_governors
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
