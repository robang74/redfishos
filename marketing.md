## Marketing

To learn how your business can benefit from the RedFish OS adoption, check this [PDF presentation](RedFishOS-presentation-A4.pdf) introduced by a less than 200 words executive summary.

---

### Marketing targets

First of all, it is important to notice that this project does not aim to reach the end-user market directly. The RFOS marketing targets are the vendors, the distributors, the engineers, and the modders, including those who are doing such activities as hobbies.

The end-users might have several advantages in having RedFish OS pre-installed as a recovery image or as a supervising system, but they are not the targets of the RFOS marketing because most of the on-the-shelf smartphones do not allow to overwrite the boot or the recovery image, and those that allow it do so not by a bare-simple procedure. Otherwise, end-users would probably brick their smartphones or install a malicious rootkit instead of something really useful. Plus, it would void the vendor's warranty, obviously.

---

### Project presentation

RedFish OS has the primary goal of complementing Android rather than
replacing it. It can serve for various purposes, such as a flashing tool,
firmware supervisor, system configuration manager, IoT fleet manager,
B2C support gateway, benign rootkit for security and privacy, and a
customizable device for penetration testing, which is the reason for
having chosen the name RedFish OS in the first place.

Therefore, RedFish OS is a proof-of-concept demonstrating that Android
hardware support, including a custom kernel and firmware blobs, can be
utilised to run a traditional GNU/Linux system. This opens up a lot of
modding possibilities for every device based on a System-on-Chip (SoC)
with Android support.

Before RedFish OS, companies dealing with embedded systems like
automotive, smart TV, and set-top box manufacturers had to customise
their products for each SoC model and version. They relied on the hope
that hardware producers would provide sufficient support, and they
were involved in technical activities that were costly and challenging.

---

### Logo and brand

Refer to the [logo folder](logo#redfish-os-logo) in order to learn more about it and the product branding. That page contains also some uses cases which might be interesting fo your business.

```diff

+ RedFish OS, do you feel the power?

```

The logo and the motto have been proposed to specifically fit the taste and expectations of the [marketing targets](../marketing.md#marketing-targets): Linux embedded engineers in their middle-life age who are looking for an old-good-days simple and powerful tool to cope with mobile devices initially tailored for Android.

---

### Recorded performances

The use of videos is important to tune the expectations: give an idea of what has been achieved compared to what can be achieved with their involvement. In these two videos, the RedFish OS is presented, providing two different tasks:

1. a recovery image that can also boot another operative system based on Linux or Android

    * [video on youtube, 1m17s](https://youtu.be/xT_MR-NgAcU) - RedFish OS recovery image boots a freshly installed SailFish OS.

2. a recovery image that can provide a straightforward interface to flash the entire smartphone

    * [video on youtube, 1m11s](https://youtu.be/EP10Evtl0wo) - RedFish OS recovery image install SailFish OS by the telnet menu.

In the first video, the smartphone boot image is flashed with the RedFish OS image, then it reboots with the recovery image, and then it reboots with the normal operative system, in this case SailFish OS. Notice that all of this takes 1m17s despite the fact that the smartphone vendor boot requires at least 20 seconds for each of the two reboots.

In the second video, the smartphone several partitios are re-flashed with SailFish OS official installation images set using the RedFish OS service instead of the `fastboot` mode or for some other operative systems like `/e/OS` the ADB mode. Notice that to complete the whole re-flashing procedure, which writes not less than 1.5GB of data in this case, it takes 70 seconds.

---

### The recovery menu on telnet

Offering a remote root-priviledged shell access is the best way to let engineers know that they can do anything with the system but offering a well designed textual menu is the best way to let them know that RedFish OS is supporting them in being extremely productive tearing down the operative entry barrier and speeding up the most common operations.

The menu available via `telnet` or via `ssh` has different specialised sections:

<p><div align="center"><img src="../recovery/recovery-menu-on-telnet-all.png" width="990px" height="582px"></div></p>

Notice that the first rendering of the recovery menu takes 461 ms, and in the past it was about 360 ms. This is because the USB is set to sleep, like many other components. Obviously, the awake process introduced a latency of about 100 ms, but the current consumption dropped to 23 mAh from 46 mAh on average. It has been halved, and the overall advantage is pretty clear.

---

### Native ARM64 build environment

The developers menu provides several functionalities to cope with the SailFish OS root filesystem and for preparing the `super` partition, which is 12GB in size on the Sony Xperia 10 II, to provide an ARM 64-bit native building toolchain based on CentOS 8 Stream for just 642 MB. The `super` partition is dedicated to temporarily storing the OTA Android updates but can also permanently or temporarily host a native toolchain system. In fact, installing it requires about 35 seconds.

The CentOS 8 Stream has been chosen because upgrading it to the last version is required, just a step above the CentOS 9 Stream. While Fedora 31 should be updated to Fedora 39. This means that CentOS offers long-term support for each version, and for this reason, it is much more affine for business adoption. The two distributions have been taken into consideration in the stage2 of the [SFOS refactoring plan](../README.md#about-sfos-refactoring) as a starting point.

---

### Advanced feature for added value

We all know that enginers choose the tools but are managers that provide them the budget. A vendor or a distributor, even if needs to provide a better support to their customers, tends to be hesitant is investing on a technology which does not directly related with the sales and therefore with the revenews but just it is a cost.

In order to address this shortcoming, RedFish OS can provide advanced features which can bring an added value to end-users. 

A supervising system or a remote fleet-management tool or an advanced recovery image are very valuable services also for the end-users because these tools help them in having as less problems as possible or fixing them as fast and as easy as possible. Unfortunately, all of these are valuable assets for vendors, distributors and professional modders but their customers, especially the end-users, rarely perceive all the effort and the value in carying about them.

Instead, some advanced features like the Punkt MP01 virtual clone (or a Nokia 3310 virtual clone, depending the skin) can be perceived like an effective added value.

---

### Welcome back Nokia 3310

[TODO]



