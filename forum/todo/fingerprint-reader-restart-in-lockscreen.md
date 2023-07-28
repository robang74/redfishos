## Fingerprint reader restart in LockScreen

After installing `SailFish Utilities` from the Jolla store, we have the chance to restart the fingerprint system when it does not work properly. Some days, it happens often.

I am suggesting adding an icon to restart the fingerprint reader on the lockscreen.

<img src="fingerprint-reader-restart-in-lockscreen.png" width="345px" height="190px">

Obviously, fixing the problem is the main way, but a quick workaround would mitigate the issue until it was investigated and understood.

<sup>________</sup>

### A fingerprint sleeping issue?

Another way to deal with this issue is to start-reset-stop the fingerprint reader only when necessary:

* lockscreen to unlock

* add a new fingerprint

and keep running/ready the rest of the system (software stack) as far as possible. At the moment, I set the energy-saving mode at 100% of the battery threshold: always. The fingerprint system fails a lot of times. 

Possibly, the fingerprint reader will go to sleep when it is not used for a long time, and missing out on waking it up brings the system to failure. Therefore, there is a good chance to solve the problem of switching on the fingerprint reader when it is going to be used and switching it off immediately after.

---

### The end-user expectations
 
> @remote wrote:
> 
> there should be a setting for this.
> cause if the user manually stops the fingerprint reader (for border crossing, for example), it shouldn’t restart the service.

If someone is going to cross a border, entering or exiting a hostile or unsecure country, the best s/he can do is to remove the fingerprints via the specific menu in Settings:System and rely only on a long-enough PIN with limited tries.

* **Question** : *what happens when the maximum number of tries has been reached without inserting the right PIN? Someone ever tried it?*

IMHO, the SailFish OS currently lacks many features for being used as a secure personal device in a hostile real-world environment. 

Privacy, intended as a protection against mass surveillance and unprofessional stalking, is just a small subset of the security one needs to keep safe life-dependent assets or data.

> @remote wrote:
> 
> I don’t wanna remove fingerprints and then add them again. Just a toggle to use it, or don’t.

Then something crashes for any reason, and the system restarts¹ with the fingerprint reader activated but not the icon to restart it on the lock screen. Therefore, you think that everything is fine, but it is not.

Security and safety are about restricting the chances of a negative event and not increasing the options for no reason. The option you are asking for is completely another feature, like:

* possibility to encrypt the fingerprints with the PIN code in order to store them for future use, but the stored fingerprints should be displayed with a lock. Otherwise the user might forget that s/he has encrypted and stored. This might raise the need of renaming the fingerprints, not just enumerating them².

I know you never forget anything in your life, even the used toothbrush in a hotel room, but those who are escaping to save their lives tend to overlook, forget, and leave behind a lot of things… :wink:

> @ric9k
> 
> What is the relation between a personal fingerprint reader and border crossing?

It is easy to pretend to have forgotten a PIN, but it is not so easy to refuse to put your finger on the reader. The quick solution is to reboot the phone because the LUKs engine requires the code, and in such a state, the data is not yet undeciphered.

Thus, any action will be - in theory - useless without knowing the PIN, and at that time, a maximum number of tries before safely erasing the LUKs key will be a nice feature to have.

Because of anyone can insert enough wrong PINs with the malicious intent to erase or lock the data on the smartphone, an alternative arbitrary PIN for erasing would be more appropriate.

Probably the best-in-class solution is:

* a PIN to access the smartphone and its data
* a PIN to access a secondary fake account configured by the user in order to be plausibly taken like the real one
* a PIN to erase the data on the phone, deleting the LUKs key, and entering into the fake account if it has been prepared, or to the guest account or to the main account but completely reset.

In theory, as long as the data erasing is limited to the LUKs key only, this opens up the possibility of recovering the data later if a backup copy of it has been safely stored somewhere. In this case, the main account should not be reset nor used but kept frozen until the final decision is taken.

> :information_source: **Note**
> 
> A LUKs key is a small amount of data (128 bits, fast ~ 1024 bits, strong) that can be saved encrypted also embedded into an image leveraging stegonagraphy, and this special image can be saved with some others but not into the account protected by the LUKs key itself. Otherwise, everything will be lost forever. In the fake account or in the cloud.

---

### About the fingerprint reader restart

The fingerprint reader suspending/awakening investigation goes much further, and here you will find the analysis about it.

```
service_do restart sailfish-fpd
sleep 3
service_do restart sailfish-fpd
```

@piggz, the sleep 3 is a waste of time, and having to repeat the restart means that the restart does not work correctly and should be fixed.

@ichthyosaurus, it would be nice to have a patch in Patch Manager to remove those two lines of code. The diff patch could be downloaded from here, while the Patch Manager patch is from here:

* [utilities-quick-fp-restart](https://coderus.openrepos.net/pm2/project/utilities-quick-fp-restart)

This patch applies to SailFish Utilities (Jolla Store) to make the fingerprint service restart without a delay of 3 seconds. Obviously, if the patch improves performance and does not introduce regressions, then it should be integrated with the SailFish Utilities.

---

### About the fingerprint reader service

Looking at the running process, I found these about the fingerprint reader:

```
[root@sfos defaultuser]# ps | grep fpd
 2904 root     /usr/lib64/qt5/plugins/devicelock/encsfa-fpd --daemon
 4887 root     /usr/bin/sailfish-fpd --systemd
 4888 root     /usr/libexec/sailfish-fpd/fpslave --log-to=syslog --log-level=4
 4954 root     grep fpd
```

Restarting the service is quite immediate:

```
[root@sfos defaultuser]# time systemctl restart sailfish-fpd
real 0m 0.14s
```

To understand which processes were restarted, I did a stop and a check:

```
[root@sfos defaultuser]# ps | grep fpd
 2904 root     /usr/lib64/qt5/plugins/devicelock/encsfa-fpd --daemon
 5107 root     grep fpd
```

Probably the restart from `Utilities` will also restart the QT5 plug-in. I did not verify the code of the `service_do` function, but considering the parameters passed to the function, it is about `systemctl`.

Considering how fast the fingerprint reader service is being started

```
[root@sfos defaultuser]# systemctl stop sailfish-fpd
[root@sfos defaultuser]# time systemctl start sailfish-fpd
real 0m 0.16s
```

and the few static places in which it is needed: unlock the screen and add a new fingerprint. I think that it would be a sane policy to start it only when it is necessary and stop immediately after.

**Unlocking the screen**

* is there a PIN set?

	no: get into the account

* is there a FP set, at least?

	yes: start the FP service

	no: wait for the PIN

* does unlock succeed?

	no: wait for unlock or timeout

* timeout expired?

	yes: stop the FP service

* stop the FP service

Implementing the logic about unlocking the screen would probably be easier than the one described because those checks are just done. Therefore, there could be just three points in the source code to change. 

**Adding a new fingerprint**

* start the FP service
* acquire the fingerprint
* stop the FP service

Instead, the logic for adding a fingerprint is straightforward.

---

### Notes

¹ you did well, hiding the icon and shutting down the fingerprint, but just before locking the screen, something goes wrong, and you decide to restart the UI without being aware that such action will also restart the fingerprint reader system because an update you did recently changed that part and you did not notice yet. Plus more other corner cases, etc.

² a feature that can be good or bad, depending on whether cutting a finger from your son or daughter in another city and sending it to the border is an option. :expressionless:
