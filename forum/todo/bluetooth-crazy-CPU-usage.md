## The bluetooth crazy CPU usage creates a battery drain

```
SailFish OS version : 4.5.0.19
Android Support : not running
Hardware : Xperia 10 II
```

During and after the bluetooth use the CPU is kept running high:

* [udev - systemd-udevd high cpu usage - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/433393/systemd-udevd-high-cpu-usage)

in my case, for days `systemd-udev` was using a lot of CPU time until I did:

```
systemctl restart systemd-udev
```

However, this is not the solution but just an extemporarly work around. Moreover, the problem is not only related to Bluetooth. 

The full restarting line is here below:

```
systemctl restart systemd-udevd systemd-udevd-kernel.socket \
                   systemd-udevd-control.socket
```

While, this command helps to debug the problem with the `udevd` service:

```
/usr/lib/systemd/systemd-udevd -D
```

I created a patch to fix some rules for `udevd` and now does not complains anymore about errors, at least. 

I released the patch in ALPHA state because I did not tested extensively it.

* [x10ii-iii-udev-rules-fixing](https://coderus.openrepos.net/pm2/project/x10ii-iii-udev-rules-fixing)

After a modding about [energy saving](energy-saving-for-xperia-10-ii-and-iii.md#about-the-future-of-sfos),l istening music from 4G mobile date streaming with a bluetooth headphones will raise the battery drain from 6%/h (daylight power save mode) to 8%/h which is acceptable (12h of music listening). Therefore, the issue can be considered having a solution.

### Current absorbtion

When I started the investigation of this issue, I wrote a script that collect data about the amount of the current absorbtion. This is an example of usage:

```
Battery status: discharging
log: /root/.batt_curr_stats.log
data set: 1965 items

now:  -337 mAh
min:   -59 mAh
max:  -801 mAh

avg:  -232 mAh ( 1 minute)
avg:  -252 mAh ( 2 minute)
avg:  -234 mAh ( 5 minute)
avg:  -248 mAh (10 minute)
avg:  -235 mAh (15 minute)
```

The most interesting part is that the current absorbtion can greatly vary within a wide range: 60 mAh and 800 mAh (more than an order of magnitudo) while the average is quite stable between 230 mAh and 250 mAh (less than 10% of variance).

Unfortunately, I also discovered that `sleep 1` is not as reliable as much as in other GNU/Linux systems. In fact, its time jittering is quite HUGE and a `sleep 1` lasts between 1s and 2.6s.

