## SFOS refactoring project (-1 day to the launch)

About the need for this work, it has been written a lot in the forum. Just to recap briefly the technical imminent goals:

1. a recovery boot mode always available on-demand at users request or automatically when the system is badly bricked;

2. a system patch manager that can un/apply persistent patches on the root filesystem for system services configuration;

3. a early-boot backup/restore script suite with the related after-flashing system configuration shell script.

These tools are indispensable for the long-term aim of refactoring the SFOS.

---

### Project naming

The project naming **RedFish OS** (RFOS) is part of its marketing campaign - everything we speak with others is marketing whatever you might think about it - and hopefully in the next future to distinguish the refactoring from the official SailFish OS (SFOS).

---

### Current state

At the moment some github projects have been forked and developed towards these goals.

* [yamui](https://github.com/robang74/yamui) - Yet Another Minimal UI. Tool for displaying graphical notifications in minimal environments like early boot/initrd, build-able by Github action..
  * **done**: the project correctly build with github actions
  * **todo**: testing the font size multiplier and multi-lines text displaying;

* [busybox for SFOS](https://github.com/robang74/sailfish-os-busybox) - The busybox config and RPM spec for SailFish OS, buildable by Github actions
  * **done**: 1.36.1+git2-raf3 provides RPMs for both dynamically and statically linked busybox for all the supported architectures {aarm64, arm7lh, i486} good for SFOS and for the recovery image respectively.
  * **todo**: configuration review and fine-tuning, possibly

* [Patch Manager](https://github.com/robang74/patchmanager) - The Patch Manager page in Settings:System for Sailfish OS, buildable by Github action
  * **done**: the project correctly build with github actions, some scripts and C++ code received a review
  * **todo**: deep test of the changes made and developing all the features necessary to be paired with command system patch manager suite which is not fully completed, yet.

* [Github actions for SFOS apps](https://github.com/robang74/github-sfos-apps-build) - Github actions for building SailFish OS apps
  * **done**: working examples for most common cases, quick step-by-step guide to deploy the action, github branches protected for high-availability, mirror of the docker image
  * **todo**: it would be great being able to cache the docker image instead of pull it for each build.

Finally, a list of proprietary and/or closed-source components has been started and it contains: `devel-su` completely, `silica` some files are available only. The sources of lipstick still need to be reviewed and tested to prove that they produce an update and fully working UI engine.

---

### Resources allocated

These are the IT resources just allocated and ready to go:

* a wiki
* a m-list for developers only
* a dedicated github project
* a website with its domain name

The github project can also provide a specific wiki, a project management tool, an issues tracker, a specific forum. Not necessarily all these resources by github will be used.

---

### Scheduled launch

On 26th July 2023 probably on the late evening when the stars are bright in the sky...

---

### Joining the club

Due to its peculiar nature of mobile embedded system plus the barrier of dealing with an ASOP to configure properly the hardware the club will be not widely open but reserved to some skillful people who wish to participate and some others who wish to learn the black magic of the near-assembly code system architecture. Everything else will be presented in this forum - unless considered off-topic - otherwise moved on its dedicated wiki, website, etc.

---

### Contributors

Just the most relevant contributors are listed here:

* @coderus : provided the docker image, the initial Sailfish OS busybox github project
* @olf : provided the initial Patch Manager github project
* @Nephros : which suggestion was determining in unlocking the build of the busybox
* Jolla developers : for their numerous contributes and 907 github projects
 
In case I missed to cite you, my anticipated excuses and please remember me about your effort.
