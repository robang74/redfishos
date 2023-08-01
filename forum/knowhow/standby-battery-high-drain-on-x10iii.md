## Standby battery drainage

> @ua0056 wrote:
> 
> Can confirm that modifying processor options (scheduler/frequency), or altogether disabling CPU stand-by has no noticeable effect on power dissipation.

I believe you about what you wrote (observations), but not about the conclusion. 

**Do a confutation test**

Execute code in order to force all the CPUs running at their maximum speed for some time, e.g. 10 or 15 minutes. What are our expectations about this experiment?

* All the CPU fully work-loaded do NOT have a significant impact on the battery's lifespan.
* The contrary, they are able to drain a lot of energy from the battery.

It is reasonable to think about the second, but trying to make all the CPUs sleep does not bring the results expected. The keyword is **trying**. In fact, with the `System Monitor` my observations report that there are a HUGE number of CPU sleeping failures.

> :zap: **HINT**
> 
> On [this page](https://github.com/robang74/redfishos/blob/main/recovery/README.md), you can find a scripts suite that can create a tarball `sysdebug` containing `stress-ng` a command-line tool that can put your smartphone's CPUs under full work-load.
> 
> :warning: **WARNING**
> 
> Furthermore, I reduced the test time to 10 or 15 minutes because, in the unlucky scenario in which the CPUs' thermal throttle is broken, down, or whatever but not correctly functioning, you seriously risk literally cooking your smartphone. Therefore, the first time you play with it, pay close attention to the CPUs' temperature, and `System Monitor` may not help but trick you because monitoring my Xperia 10 II, it reports 36°C all the time.

They are trying to sleep, but they get awakened almost immediately, and this clogs the system logfile, and guess what? The syslog is writing on the internal flash, and each write awakens a CPU, which creates a failure syslog message that should be written on the internal flash.

**Why does this happen?**

My hypothesis is that the SG/DMA is not activated and the filesystem caching is very limited or absent at all. Which makes sense for a mobile device that can safely - even if brutally switched off by the pressure of hardware keys driven by the user - keep data saved on the internal flash in real-time like `sync` filesystem option or near similar in effect.

**How to easily confute my hypothesis?**

Move the syslog to a `tmpfs`, with the precaution to kill the syslog daemon - if it still exist in user-space and it is the same that convey the kernel error/warning messages - because replacing it with a symlink pointing to /tmp will not close the file descriptor that syslog daemon is using. However, these information about syslog and syslog daemon have been collected a long time ago and possibly they are obsolete by now or specifically for SFOS.

> @ua0056 wrote:
> 
> Considering the average current draw during stand-by (display off) is about 30 mA, while it should presumably be less than 5, something is probably not being powered down. Such as a radio.

At 230mA, my Xperia 10 II can last 12h. Doing a linear proportion at 5mA it would last 550h which is definitely too much even for a standby but not hibernated system. Using the same linear proportion, at 30mA it would last 92h and this sounds reasonable instead. At least for me.

> @ua0056 wrote:
> 
> This disables a bunch of things, such as the display, so have a care.

A total black screen (aka all the pixels at `#000000` color) consumes less energy than a white screen ONLY if the display is based on OLED technology or better. IPS displays do not have the feature of powering down the simple pixels or a relatively small matrix of them.

Therefore, there is quite a difference between disabling a hardware sub-system and cutting its link to the energy source, the battery. For example, GPS usually receives energy even when it is not used and disabled, but with `gpstoggle` we can cut it.
