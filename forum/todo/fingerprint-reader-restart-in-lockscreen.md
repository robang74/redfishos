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

The fingerprint reader suspending/awakening investigation goes much further and here you will find the analasys about it, updated at the time of writing:

* [Patches by ichthyosaurus - #48 by robang74 ](https://forum.sailfishos.org/t/patches-by-ichthyosaurus/15387/48)

I hope this helps, R-

---

### Notes

¹ you did well, hiding the icon and shut-down the fingerprint but just before locking the screen, something goes wrong and you decide to restart the UI without the knowlegde that such action will restart also the fingerprint reader system because an updated you did recently changed that part and you did not noticed yet. Plus more other corner cases, etc. etc.

² a feature that can be good or bad, depending if cutting a finger to your son/daughter in another city and sending it to the border is an option… :expressionless:
