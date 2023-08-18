## Battery recharge and power-saving

A longer page about power-saving dedicated to the Xperia 10 II and III is available [here](../todo/energy-saving-for-xperia-10-ii-and-iii.md). Instead, this page is focused on user-tailored power management for SailFish OS in general, and it also includes the battery recharge thresholds for a long battery life plus a brief essai about screen brightness.
 
> @spiiroin wrote:
> >
> > @Seven.of.nine wrote:
> >
> > Presently there's only possible to automatically activate the power saving mode depending on the accu charge level (20%, 15%, 10%, 5%, off), or set manually until next time charger is connected.
> > Note that from command line you can select any percentage value, e.g.
> ```
> mcetool --set-psm-threshold=100 --set-power-saving-mode=enabled
> ```

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

**Battery charging thresholds**

```
mcetool \
	--set-forced-charging=disabled  \
	--set-charging-enable-limit=95  \
	--set-charging-disable-limit=90 \
	--set-charging-mode=apply-thresholds
```

<sup>________</sup>

**Screen brigthness**

The other setting to operate on in order to save energy is screen brightness.
 
In this case, there are three different aspects that can be optimised:
 
- the brightness settings available with `mcetool` and d-bus
 
- a proper use of the light sensor embedded in the smartphone
 
- improve the `mcetool` without breaking the back-compatibility
 
In particular, the second one seems to be the most work-intensive task of the two and also the least optimised at the moment.
 
However, before starting about light sensor management, it will be important to clearly understand how the various settings are working because their descriptions, especially in some cases, are definitely not very useful in describing their effective role. This is the reason for the third point in the task list above.

```
mcetool \
	--set-brightness-fade-dim=1000    \
	--set-brightness-fade-als=1000    \
	--set-brightness-fade-blank=1000  \
	--set-brightness-fade-unblank=150 \
	--set-als-autobrightness=enabled  \
	--set-brightness-fade-def=150
```

This is a script that sets some reasonable value for display auto-brightness and enables it.

---

### CPU governors

The CPU governors subject has been faced in two different pages:

* [battery-recharge-and-power-saving.md](https://github.com/robang74/redfishos/blob/main/forum/knowhow/battery-recharge-and-power-saving.md#cpu-governors) (this one)

* [energy-saving-for-xperia-10-ii-and-iii.md](https://github.com/robang74/redfishos/blob/main/forum/todo/energy-saving-for-xperia-10-ii-and-iii.md#cpu-governors) (the other)

<sup>________</sup>

The Xperia 10 II has 4+4 CPUs while the Xperia 10 III has 2+6 CPUs and this difference have an impact in how the CPU governors are set. The first implication is that for the mark 2 the CPUs sets are {[0-3], [4-7]} while for mark3 {[0-1], [2-7]} or unlikely {[0-5], [6-7]} depending how the CPUs are mapped by the kernel. Therefore the first information we need to collect for which **n** happen the separation:

```
cfp="/sys/devices/system/cpu/cpufreq/policy"
n=$(ls -1rd ${cpf}? | head -n1 | tr -cd '[0-9]');
echo "CPUs sets separation is {[0-$((n-1))], [$n, 7]}"
cat "${cfp}0/scaling_available_governors"
```

Fortunately, this division is cabled into the kernel and can be read directly from `/proc` in this way:

```
cat /sys/devices/system/cpu/cpu0/cpufreq/affected_cpus 
0 1 2 3
let n=$(rev /sys/devices/system/cpu/cpu0/cpufreq/affected_cpus | head -c1)+1; echo $n
4
cat /sys/devices/system/cpu/cpu$n/cpufreq/affected_cpus 
4 5 6 7
```

The last line shows the available CPU governors policies reasonably supposing that they are the same for the two CPUs sets. For the Xperia 10 II these policies are: `conservative`, `powersave`, `interactive`, `performance`, `schedutil`. 

About the CPUs sets for Xperia 10 III, [this comment on github](https://github.com/sonyxperiadev/device-sony-lena/issues/20#issuecomment-1220483952) reveal that the `n = 6`. Moreover the among policies there is not `interactive` but `ondemand`. At the end of this section there is a description of the various governors here cited.

We can provide four CPU dynamic governor policies for four different profile of usage:

```
          $1                  $2            $3         $4        $5        $6        $7      $8
1. ondemand-performance : schedutil   , performance, disabled, disabled, enabled, disabled,  20
2. balanced-interactive : schedutil   , interactive, enabled , disabled, enabled, disabled, 100
3. balanced-conservative: conservative, interactive, enabled , disabled, enabled, disabled, 100
4. ondemand-power-saving: conservative, automatic  , enabled , enabled , enabled, enabled , 100
```

and apply them with a single script template like this:

```
echo Setting $1 governor policy
for i in /sys/devices/system/cpu/cpu?/cpufreq/scaling_governor; do
#   echo "interactive" >$i 2>/dev/null || echo "schedutil" >$i
    echo "$2" >$i
done
mcetool -S $3 \
	--set-power-saving-mode=$4 \
	--set-low-power-mode=$5 \
	--set-ps-on-demand=$6 \
	--set-forced-psm=$7 \
	--set-psm-threshold=$8
```

The **Conservative** governor can be fine-tuned at run-time by changing these parameters:

```
grep . /sys/devices/system/cpu/cpu0/cpufreq/conservative/*
/sys/devices/system/cpu/cpu0/cpufreq/conservative/down_threshold:20
/sys/devices/system/cpu/cpu0/cpufreq/conservative/freq_step:5
/sys/devices/system/cpu/cpu0/cpufreq/conservative/ignore_nice_load:0
/sys/devices/system/cpu/cpu0/cpufreq/conservative/sampling_down_factor:1
/sys/devices/system/cpu/cpu0/cpufreq/conservative/sampling_rate:2000
/sys/devices/system/cpu/cpu0/cpufreq/conservative/up_threshold:80

grep . /sys/devices/system/cpu/cpu0/cpufreq/scaling_m*_freq
/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq:1804800
/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq:300000

grep . /sys/devices/system/cpu/cpu$n/cpufreq/scaling_m*_freq
/sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq:2016000
/sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq:300000
```

but this task requires a root-privileged userland application capable of monitoring and foresighting the CPUs loads.

---

### Governors descriptions

The following CPU governor descriptions have been taken from the [sabers-guide-on-cpu-governors-i-o-schedulers-and-more](https://forum.xda-developers.com/t/ref-guide-sabers-guide-on-cpu-governors-i-o-schedulers-and-more.3048957/) on the XDA forum and those longer that a single sentence has been reworked and summarized by ChatGPT 3.5 for quicker text comprehension.

* The **Performance** locks the phone's CPU at maximum frequency (probably the maximum frequency set by the user).

* The **Powersave** is the opposite of the Performance governor because it locks the CPU frequency at the lowest frequency set by the user.

* The **Conservative** governor in a phone biases towards using the lowest possible clockspeed most of the time. It requires a larger and more persistent load on the CPU before raising the clockspeed. This approach can lead to choppy performance, but it benefits battery life. Some describe it as a "slow OnDemand". It is considered obsolete.

  > :warning: **TODO**
  >
  > About the **Conservative** governor - the original and unmodified conservative is slow and inefficient - therefore, it makes sense to evaluate changing the kernel in order to add a better one, but this task should be put into a specific, broader goal aiming for a more extreme kernel optimization. About a possible alternative to `conservative` a quick analysis indicates `relaxed` as a good candidate.
  >
  > The **Relaxed** governor is derived from Chill and modified to offer gradual frequency boosting, which results in better battery life. It utilizes a boost ceiling variable to achieve this, avoiding an immediate boost to the maximum frequency. Relaxed is meant to complement Chill, which is a conservative-based governor focused on aggressive battery savings when the screen is off.

* The **Schedutil** is a modern EAS governor in recent Linux Kernel versions (4.7+). Its key feature is better integration with the Linux Kernel scheduler. By using the kernel's scheduler to receive CPU utilization data, Schedutil can make faster and more accurate decisions compared to traditional governors like Interactive, which rely on timers.

* The **Interactive** governor adjusts the CPU clockspeed based on a timer set by the kernel developer or user. It can quickly scale to the maximum frequency when needed, making it more responsive than the OnDemand governor. It also takes into account user interactions, assuming that turning on the screen will be followed by using applications. This governor is commonly used as the default choice by smartphone and tablet manufacturers.

* The **Ondemand** governor is an older and original governor available in the Linux kernel. When the CPU load reaches a certain threshold, it quickly ramps up to the maximum frequency, providing excellent fluidity. However, this high-frequency bias can have a negative impact on battery life compared to other governors. While it was commonly used by smartphone manufacturers in the past due to its reliability, it is now considered outdated and is being replaced by Google's Interactive governor.

In conclusion, two governors are useful: one powersaving-oriented and the other performance-oriented. Among these two classes, those with a dynamic policy of scaling up and down are taken into account, while those with static policies are put aside.

The two best governors available to use under this PoV are the **`conservative`** because the `powersave` is a static one unless a userland application takes care of dynamically changing the minimum frequency of working for each CPU, and the **`schedutil`** because the `performance` has the same shortcomings as the `powersave`. The `interactive` is available on mark2 only, and it seems the best for smartphones, but should be paired with `ondemand`, which is available on mark3.

Therefore, `schedutil`, which is a pretty new and advanced governor, seems like a reasonable choice. On the other hand, it is quite limiting considering SFOS mobile devices like smartphones only because, unlike Android and iOS smartphones, it is supposed they will be on duty even when the user does not interact with them, e.g. providing services like any UNIX server has done since 1970.

For those end-users that wish to use a SFOS smartphone just as a mere smartphone, then they can be addressed towards the use of an userland application specifically developed for dealing with CPUs, like `zgovernor` a [CPU governor manager for SFOS](https://github.com/robang74/zgovernor) and from which we can take the suggestion to put some CPUs offline in some particular conditions, like when the battery runs lower than 10% or 5% of its full charge.

---

#### OFF-LINE NOTES

Some copy-and-paste text from the console while I was investigating the issue. Reported here just for contextual memory trigger.

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
```
