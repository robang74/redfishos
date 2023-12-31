## The SFOS refactoring project

```diff
+ This is the announcement of the github project publication, two weeks after its creation.
```

---

About the need for this work, it has been written a lot in the forum. Just to recap briefly the technical imminent goals:

1. a recovery boot mode always available on-demand at user request or automatically when the system is badly bricked;

2. a system patch manager that can un/apply persistent patches to the root filesystem for system services configuration;

3. a early-boot backup/restore script suite with the related after-flashing system configuration shell script.

These tools are indispensable for the long-term aim of refactoring the SFOS.

---

### Project naming

The project naming **RedFish OS** (RFOS) is part of its marketing campaign - everything we speak with others is marketing, whatever you might think about it - and hopefully in the near future will distinguish the refactoring from the official SailFish OS (SFOS).

---

### Current state

At the moment (25th July 2023) some github projects have been forked and developed towards these goals.

* [yamui](https://github.com/robang74/yamui) - Yet Another Minimal UI. Tool for displaying graphical notifications in minimal environments like early boot/initrd, build-able by Github action..

    * **done**: the project was correctly built with github actions.

    * **todo**: testing the font size multiplier and multi-line text displaying;

* [busybox for SFOS](https://github.com/robang74/sailfish-os-busybox) - The busybox config and RPM spec for SailFish OS, buildable by Github actions

    * **done**: 1.36.1+git2-raf3 provides RPMs for both dynamically and statically linked busybox for all the supported architectures {aarm64, arm7lh, i486} good for SFOS and for the recovery image, respectively.

    * **todo**: configuration review and fine-tuning, possibly

* [Patch Manager](https://github.com/robang74/patchmanager) - The Patch Manager page in Settings:System for Sailfish OS, buildable by Github action

    * **done**: the project was correctly built with github actions, some scripts and C++ code received a review.

    * **todo**: deep test of the changes made and developing all the features necessary to be paired with the command system patch manager suite, which is not fully completed yet.

* [Github actions for SFOS apps](https://github.com/robang74/github-sfos-apps-build) - Github actions for building SailFish OS apps

    * **done**: working examples for most common cases, quick step-by-step guide to deploy the action, github branches protected for high-availability, mirror of the docker image

    * **todo**: it would be great to be able to cache the docker image instead of pulling it for each build.

Finally, a list of proprietary and/or closed-source components has been started, and it contains: `devel-su` completely while for `silica` some files are available only. The sources of lipstick still need to be reviewed and tested to prove that they produce an updated and fully working UI engine.

---

### Resources allocated

These are the IT resources just allocated and ready to go:

* a wiki
* a m-list for developers only
* a dedicated github project
* a website with its domain name

The github project can also provide a specific wiki, a project management tool, an issue tracker, and a specific forum. Not necessarily all these resources from github will be used.

---

### Budget allocation

Dear Sailors, now it is time to set the budget allocation. Here are some simple rules of thumb to give an estimation.

* time for delivery: the date for which you wish the 3-points above to be completed
* number of people and roles needed: a list of skilled people that are required
* number of weeks of working: the number of people x the duration of the project
* the value and cost of the project: how much is this stuff worth? How much will it cost?

Please write your own in the comments. Do not be shy, you will not be asked to pay for it. Unless you want to, naturally, and in such a case, check the RFOS main page on github.

---

### GitHub repository

> :memo: **scheduled launch**
>
> On 26th July 2023 probably on the late evening when the stars are bright in the sky...

* [RedFish OS: a SFOS refactoring project](https://github.com/robang74/redfishos#redfish-os)

The weather conditions were favourable, and the launch went on-line within the first time window available: 25th July 2023 at 14:21 (CET), one day in advance of the schedule. :blush:

---

### Joining the club

Due to the peculiar nature of mobile embedded systems and the barrier of dealing with an ASOP to properly configure the hardware, the club will not be widely open but reserved for some skilled people who wish to participate and some others who wish to learn the black magic of the near-assembly code system architecture. Everything else will be presented in this forum - unless considered off-topic - otherwise moved to its dedicated wiki, website, etc.

---

### Acknowledgements

This is a list of projects on which the SFOS refactoring first stage is based, listed by their authors:

* @coderus : provided the docker image, the initial Sailfish OS busybox github project
* @olf : provided the initial Patch Manager github project
* @Nephros : which suggestion was determining in unlocking the build of the busybox
* Jolla developers : for their numerous contributions and 907 github projects

In case I missed citing your project, my anticipated excuses, and please remember me about your effort.
