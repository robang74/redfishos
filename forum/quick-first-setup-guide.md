## Quick First Setup Guide v1.0.9

This is the guide originally written for the SailFish OS community forum reported here in Github .md format.

> (C) 2023, Roberto A. Foglietta \<<roberto.foglietta@gmail.com>\> released under [CC BY-NC-SA 4.0 license](https://creativecommons.org/licenses/by-nc-sa/4.0/) terms.

If you are going to use this guide for commercial purposes, feel free to contact me to negotiate a license for your business specific needs.

---

**RATIONALE**

This is a step-by-step mini guide to follow immediately after having flashed your smartphone with SailFish OS. It has been written and tested with a Sony Xperia 10 II smartphone.

Some suggestions about flashing your smartphone with SailFish OS and copying with the USB v3.x problems have been reported at the beginning of the [Quick Start Guide](quick-start-guide.md) and that sections belong to this guide more than the other one. Unfortunately the other one is not editable anymore. Therefore, I cannot move such information here and I wish not to duplicate them here.

Moreover, having such a guide allows everyone involved in supporting the hardware to have a standard starting point in order to reduce - as much as possible - the interference caused to a different setup procedure.

---

**DUAL SIM**

For the dual SIM smartphone owners: put the SIM you wish to use for mobile data on the slot #1. If the other SIM has a PIN enabled put it in the slot #2 otherwise do not but do it later when you will complete the network operator configuration of the first SIM. It is not strictly necessary but it helps a lot in some troubling cases.

---

**EARLY SETUP**

For everybody:

0. complete the flash procedure with these two commands:

```
  sudo fastboot flash oem_b SW_binaries_*.img
  sudo fastboot reboot
```

 1. choose the language that you like to use for the UI
 2. accept the end-user license
 3. insert the PIN for the SIM on the slot #1
 4. skip with the X to insert the PIN for the SIM on the slot #2, confirm: continue
 5. enter your security PIN/password for the internal storage encryption
 6. re-enter the PIN/password for confirmation
 7. click on the blue bottom half of the display to skip the connection, confirm: skip
 8. select the timezone manually (optional) but later will be set right automatically
 9. accept (optional but suggested) to setup the fingerprints reader
10. insert the fingerprint of the thumb of the hand you keep the smartphone, confirm: next
11. skip to learn the basics about SFOS with the (X) on the top right, you will do later
12. confirm your choice with x-close-tutorial button

---

**BASIC SETTINGS**

Now the smartphone needs a little more effort to be completely configured on the basics.

 0. Swipe from the bottom on the home display, choose Settings and its System tab

in Settings:System page:

 1. Display -> Text size: choose the one comfortable for you
 2. Sounds and feedback raise all the volumes to 100%, fine tuning later
 3. Gestures -> Show hints and tips: OFF, learning later
 4. Battery -> Activation threshold: set Battery 20%
 5. Battery -> Charging mode: set Apply threshold, Stop charging: 90%
 6. Device Lock -> Show notifications when device is lock: OFF

The battery settings are not strictly required but it is supposed that your battery will last longer and with the power saving mode starting at 20% of the battery, the smartphone will last as much as having fully charged the battery.

About showing the notifications when the device is locked - ON by default - allows sensible information leaking to everyone who can see at your unattended smartphone display. Like the content of SMS/text messages which sometimes contains an OTP used by some banks or other service providers to confirm a transaction or authorizing a sensitive change by a registered mobile number. A leak that can be leveraged for being actively used.

---

**SIM SETTINGS**

 1. swipe from the bottom on the bottom edge and choose the Messages app
 2. in Message, swipe from above on the display and select new message
 2. send a configuration SMS/text request to your network operator: wait for it
 3. swipe from the bottom on the bottom edge and choose Settings
 4. in Settings -> Mobile network check the configuration for the SIM #1
 5. select SIM #1 and enable the mobile data connection, it should go in *Connected* state

For those have a dual-SIM smartphone and two SIMs, it is time to configure the SIM #2

* insert the 2nd SIM into the slot #2, if you did not do before and configure it

or

* for those the 2nd SIM is in the slot #2 but did not unlock it, unlock and configure it

---

**TOP MENU**

This part of the configuration is optional but it will be useful for the many.

In Settings:System -> Top menu:

1. disable Show ambiance in Top menu, it will save a lot of useful space in top menu;
2. enables the following: Silence, Flashlight, VPN, NFC, Developer tools, Utilities, Take a selfie.

Make all other changes you wish. 

About the *VPN*, it should be configured before using it, check the [Quick Start Guide](quick-start-guide.md) for it.

About the *NFC* is useful only if you are going to use it otherwise disable it in 

* Settings:System -> NFC: OFF.

About *Screenshot*, the keys combination `volume up + down` is a much faster way to get your display screenshot-ed.

About Take a selfie, it is a straightforward mis-defined shortcut to the camera therefore 

* Settings:System -> Gesture -> Quick access to the Camera: OFF 

will simplify the UI without undermining the user experience. 

About *Connect to Internet* is quite useless and disabling it will let you gain a free icon position in the top menu or even save an entire line in some cases. 

---

**OPTIONS AVAILABLE**

Now it is time to take some decisions:

* Are you going to enable the **developer mode** activating the SSH connection? No? Why have a GNU/Linux-like smartphone and not use it like that?

* You may want to register for the smartphone with a **Jolla account** or not. In the negative case some repositories will be unavailable and it is suggested that you will disable them. This part will be explained below in this mini guide.

* Are you going to use a WiFi connection or do you wish that your smartphone could share the mobile data connection with your other devices? In this case, you have to configure the **tethering**.

About the tethering: the one via WiFi is quite immediate to configure by the UI and will be explained later in this guide while the one via USB requires a package to be installed and you will find the related section in the [Quick Start Guide](quick-start-guide.md).

---

**SSH CONNECTION**

These steps will let you able to activate the SSH activation, in Settings:System -> Developer tools:

 1. Show reboot option on Top menu: ON
 2. Developer mode: ON
 3. Remote connection: set a **strong** root password and save it
 4. Remote connection: ON

At this point you have two ways to access the SSH connection: via USB and via WiFi or Wifi tethering.

* via USB: `ssh defaultuser@192.168.2.15 devel-su /bin/bash`

* via WiFi: `ssh defaultuser@172.28.172.1 devel-su /bin/bash`

You will need to digit your password two times: the first for the SSH login and the second to become root otherwise you will not be able to configure, administer the system and install packages.

In the [Quick Start Guide](quick-start-guide.md), it is explained how to configure a secure and quick way to access via SSH as root to your smartphone without the use of the password but this functionality is limited to trusted devices only.

* [patch to enable the SSH login by key only](https://coderus.openrepos.net/pm2/project/sshd-publickey-login-only)

The patch above allows you to enable and disable the login with the password, just in case.

---

**JOLLA ACCOUNT**

To add or create your Jolla account:

 1. in Settings choose the tab Account
 2. add an account, choose Jolla
 3. follow the procedure
 4. install the Jolla apps that you like

For those wish not register their smartphone with a Jolla account, some repositories need to be disabled:

 1. connect your smartphone to your laptop/PC via USB or via WiFi or WiFi tethering
 2. login via SSH and as root execute:

 ```
  repo_list='adaptation0 aliendalvik sailfish-eas xt9'
  for repo in $repo_list; do ssu disablerepo $repo; done
 ```

---

**WiFi TETHERING**

**Warning**: your laptop/PC especially when running Microsoft Windows will use your smartphone WiFi tethering like an Internet cabled line by default and this can easily consume a lot of data traffic which can involves extra costs or blocking your SIM data mobile traffic until the next month or next data pack renewal, depending on your plan.

Follow these instruction to activate it in Settings:System -> Internet sharing:

 1. set the WiFi name (SSID)
 2. change the password with a stronger one
 3. set Internet sharing: ON

In the future you can activate the WiFi hotspot/tethering also from the top-menu.

---

**ADVANCED SSH**

For those connect to their SFOS smartphone frequently both via USB and via WiFi, these two simple functions added into your `.bashrc` will avoid you to digit the same stuff every time:

```
wfish() { ssh root@172.28.172.1 "$@"; }
ufish() { ssh root@192.168.2.15 "$@"; }
```

Just for fun, I developed a much more extreme approach to the problem and I have released this patch which is not for the SFOS but for your laptop/PC:

* https://coderus.openrepos.net/pm2/project/sfos-ssh-connect-env

This patch is for your laptop/PC and contains a bash environment that defines some function useful to quickly and easily connect to your SFOS device to avoid you having to type the user and the IP address every time. Moreover, automatically find the quickest network path among those available if there are more than one.

**pre-requisites**

This patch requires to having installed on your SFOS device the "*SSHd public-key login only*" patch:

* https://coderus.openrepos.net/pm2/project/sshd-publickey-login-only

Optionally installing on your SFOS device also the "*USB tethering POSTROUTE setting*" patch allows you to quickly and easily set the USB tethering for the developer mode.

**installation**

Save this file in `/usr/bin/sfos-ssh-connect.env` as text file not as a script and add this line to the end of your `~/.bashrc` for the future bash instances:

* `source /usr/bin/sfos-ssh-connect.env`

and / or manually load into the current bash instance in the same way above.

**usage**

* `tfish [command]` - to use recovery telnet via USB on its default IPv4
* `rfish [command]` - to use recovery SSH via USB on its default IPv4
* `ufish [command]` - to use SSH via USB connection on its default IPv4
* `wfish [command]` - to use SSH via WiFi connection on its default IPv4
* `afish [command]` - to use the fast route IPv4 for SSH, updates IPv4 default
* `sfish [command]` - to use the previous route for SSH or it finds the fastest

extras:

* `afish getip` - set the fastest route IPv4 for establishing the SSH connection
* `ufish devtether` - enable on the SFOS the tethering via USB in developer mode

---

Continue to explore SailFish OS and leverage its functionality with the

* [Quick Start Guide](quick-start-guide.md)

Have fun <3, R-
