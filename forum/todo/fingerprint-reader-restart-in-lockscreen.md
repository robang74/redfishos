## Fingerprint reader restart in LockScreen

Installing `SailFish Utilities` from the Jolla store we have the chance to restart the fingerprint system when it does not work properly. Some days, it happens often.

I am suggesting adding an icon to restart the fingerprint reader on the lockscreen.

<img src="fingerprint-reader-restart-in-lockscreen.png" width="345px" height="190px">

Obviously, fixing the problem is the main way but a quick workaround would mitigate the issue until it wil be investigated and understood.

### A fingerprint sleeping issue?

Another way to deal with this issue is to start-reset-stop the fingerprint reader only when necessary:

* lockscreen to unlock
* add a new fingerprint

and keep running/ready the rest of the system (software stack) as far as possible.

At the moment, I set the energy saving mode at 100% of battery threshold: always. The fingerprint system fails a lot more times. Possibly, the fingerprint reader will go to sleep when it is not used for a long time and missing to wake it up, brings the system to a failure. Therefore, there is a good chance to solve the problem of switching-on the fingerprint reader when it is going to be used and switching-off it when it is not.

---

### The end-user expectations

> @remote wrote:
>
> there should be a setting for this.
> cause if the user manually stops the fingerprint reader (for border crossing, for example), it shouldn’t restart the service.

If someone is going to crossing a border, entering or exiting between a hostile / unsecure country. The best s/he can do is to remove the fingerprint via the specific menu into Settings:System and rely only on a long-enough PIN with limited tries.

* **Question** : *what happens when the max numbers of tries has been reached without inserting the right PIN? Someone ever tried it?*

IMHO, the SailFish OS currently lacks of many features for being used as a secure personal device in a hostile real-world enviroment. Privacy - intended as a protection for mass surveillance and unprofessional stalking - it is just a small subset of the security one needs to keep safe life-depending assets or data.

> @remote wrote:
> 
> I don’t wanna remove fingerprints and then add them again. Just a toggle to use it, or don’t.

Then something crashes for any reason and the system restarts¹ with the fingerprint reader activated but not the icon to restart it in the lockscreen. Threfore you think that everything is fine but it is not.

Security and safety is about restricting the chances of a negative evet not increasing the options for no reason. The option you are asking is a completely another feature, like:

* possibility to enchrypt the fingerprints with the PIN code in order to store them for a future use but the stored fingerprints should be displayed with a lock otherwise the user might forget that s/he has encrypted and stored. This might arise the possibility to rename the fingerprints not just enumerate them².

I know you did not forget anything in your life, not the used toothbrush in a hotel room but those escape for their lives tends to overlook, forget and leave behind a lot of things… :wink:

> @ric9k
>
> What is the relation between a personal fingerprint reader and border crossing?

It is easy to pretend to have forgot a PIN but it is not so easy to refuse to put your finger on the reader. The quick solution is to reboot the phone because the LUKs engine requires the code and in such a state the data are not yet uncyphered. Thus, any action will be - in theory - useless without knowing the PIN and at that time a maximun number of tryies before safely erase the LUKs key will be a nice feature to have.

I answer one question, I am doing a question: what’s happen when the max number of tries has been exhausted in the lockscreen PIN reader? Does someone tried it?

---

The fingerprint reader suspending/awakening investigation goes much further and here you will find the analysiss about it.

```
service_do restart sailfish-fpd
sleep 3
service_do restart sailfish-fpd
```

@piggz, the sleep 3 is a waste of time and having to repeat the restart means that restart does not work correctly and it should be fixed.

@ichthyosaurus, it would be nice to have a patch in Patch Manger to remove that 2 lines of code. The diff patch could be downloaded from here while the Patch Manager patch from here:

* [utilities-quick-fp-restart](https://coderus.openrepos.net/pm2/project/utilities-quick-fp-restart)

Obviosly, if the patch improves the performance and does not introduce regressions then it should be integrated with the SailFish Utilities. Unfortunately, in PM2 the fingerprint is missing among the category therefore I choose others.

---

### About the fingerprint reader restart

Looking at the running process, I found these about FP reader:

```
[root@sfos defaultuser]# ps | grep fpd
 2904 root     /usr/lib64/qt5/plugins/devicelock/encsfa-fpd --daemon
 4887 root     /usr/bin/sailfish-fpd --systemd
 4888 root     /usr/libexec/sailfish-fpd/fpslave --log-to=syslog --log-level=4
 4954 root     grep fpd
```

Restarting the service is quite immediate:

```
[root@sfos defaultuser]# time systemctl restart sailfish-fpd
real	0m 0.14s
```

To understand which processes were restarted I did a stop and a check:

```
[root@sfos defaultuser]# ps | grep fpd
 2904 root     /usr/lib64/qt5/plugins/devicelock/encsfa-fpd --daemon
 5107 root     grep fpd
```

Probably the restart from `Utilities` will restart also the QT5 plug-in, I did not verified the code of `service_do` function but considering the parameters passed to the function, it is about `systemctl`.

---

## About the fingerprint reader service

Considering how fast is the FP reader service in being started

```
[root@sfos defaultuser]# systemctl stop sailfish-fpd
[root@sfos defaultuser]# time systemctl start sailfish-fpd
real	0m 0.16s
```

and the few static places in which it is needed 1. unlock the screen and 2. add a new fingerprint, I think that it would a sane policy to start it only when it is necessary and stop immediately after. By default do start it at the boot time.

Unlock the screen:

* is there a PIN set?
no: proceed
* is there a FP set, at least?
no: wait for the PIN
* start the FP service
* does unlock succeed?
no: wait for unlock or timeout
* timeout exipired?
stop the FP service
* stop the FP service

Add a new fingerprint:

* start the FP service
* acquire the fingerprint
* stop the FP service

Probably implementing the logic about unlocking the screen would be easier that the one described because those check are just done for sure. Therefore there are just three points to change: start, stop and stop. Instead, the logic for adding a fingerprint is straightforward.

---

### Notes

¹ you did well, hiding the icon and shut-down the fingerprint but just before locking the screen, something goes wrong and you decide to restart the UI without the knowlegde that such action will restart also the fingerprint reader system because an updated you did recently changed that part and you did not noticed yet. Plus more other corner cases, etc. etc.

² a feature that can be good or bad, depending if cutting a finger to your son/daughter in another city and sending it to the border is an option… :expressionless:
