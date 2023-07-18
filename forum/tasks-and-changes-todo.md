## TASKS AND CHANGES TODO

This list of suggested changes is for those Sailors hackers or Jolla employees that wish to improve `SFOS`. 

Please, take a look of that list and feel free to indicate the 3 that are the **most** important for you or `SFOS` and the 3 which are the **least** important. To the 3+3 indications add for each one a **brief** explanation about why, just to support your preference.

---

**LIST OF TASKS TO DO**

* provide a not truncated LVM userdata filesystem image ([here](todo/truncated-LVM-volume-issue.md))

* improve and fix the hybris-recovery.img shortcomings ([here](recovery-image-refactoring.md))

* take care of the short-comings listed into this post ([here](todo/first-impact-with-sailfish-os.md)). 
 
* an easy way to deploy of the `A-GPS` config for X10 II and III ([>here](https://forum.sailfishos.org/t/quick-start-guide-v1-4-2/15857/6)) moreover about Settings:System -> Location:Location -> device only mode, it should disable the `A-GPS` functioning also at least for the part which communicates / requests data from remote sources. IMHO, the `A-GPS` inevitably does that, thus disabling it completely it is the only safe way of fulfilling the *device only* user choice/will.

* energy saver at 50%, 100% battery threshold and hysteresis at 87% is too much, 85% at least ([here](knowhow/battery-recharge-and-power-saving.md)) also for 80% the 75% hysteresis threshold is suggested. Probabibly the 95%-90% and 80%-75% would address the needs of those have a fully functional battery and those have not.

* implementing power saving templates to better dealing with this aspect ([>here](https://forum.sailfishos.org/t/please-add-function-for-automatic-power-saving-mode/7322/23)), ([>here](https://forum.sailfishos.org/t/the-bluetooth-crazy-cpu-usage-creates-battery-drain/16070/1)) and ([>here](https://forum.sailfishos.org/t/energy-saving-for-xperia-10-ii-and-iii/15883/1)).

* device lock adding 5/10/30/60 seconds, also ([>here](https://forum.sailfishos.org/t/custom-timeouts-for-automatic-device-lock-or-at-least-more-options/8513/3)). Much probably adding just 1 minute to the list because it seems be the finest granularity. ([>here](https://forum.sailfishos.org/t/custom-timeouts-for-automatic-device-lock-or-at-least-more-options/8513/6)).

* fingerprint reader and bluetooth awakening or a fingerprint restart icon/link in lockscreen ([>here](https://forum.sailfishos.org/t/fingerprint-reader-restart-in-lockscreen/15878/4)) but probably the best approach is to `start sailfish-fpd` service just in those few cases - just 2 - it is needed and bring down soon after it did its work. ([>here](https://forum.sailfishos.org/t/patches-by-ichthyosaurus/15387/48))

* add an option for disabling the `Android Support` autostart and kept it sleeping/ready to start. ([>here](https://forum.sailfishos.org/t/energy-saving-for-xperia-10-ii-and-iii/15883/1))

* add an option in the native browser to let it keeping alive a background tab that is doing some tasks like playing music. ([>here](https://forum.sailfishos.org/t/an-option-to-keep-alive-a-background-tab-in-native-browser/15884/1)).

* this solution about urls encoding [>here](https://forum.sailfishos.org/t/4-4-0-72-browser-url-copy-does-not-encode-uri-string/13152/11) + sanitisation should be applied also to shared links in particular with native browser that fails to open those `URL`s that did not just converted.

* transition to the "*user situational approach*" in setting the smartphone beahviour modes. ([>here](https://forum.sailfishos.org/t/energy-saving-for-xperia-10-ii-and-iii/15883/2))

* in the `Patch Manager` patch list page a (de)activation "*tap to undo*" grace time needs to be added. ([>here](https://forum.sailfishos.org/t/patch-manager-de-activation-tap-to-undo/15986/1))

* add a permanent tethering setting because restarting the network WiFi tethering fails to raise up but WLAN, instead. ([>here](https://forum.sailfishos.org/t/restarting-the-network-wifi-tethering-fails-to-raise-up-but-wlan-instead/15946/1))

* fixing the `bash` regression, a request to include it as standard again. ([>here](https://forum.sailfishos.org/t/4-0-1-45-bash-regression-request-to-include-it-as-standard-again/4659/18))

* add a toggle button to inhibits SSHd for every interface but USB tethering. ([>here](https://forum.sailfishos.org/t/a-toggle-button-to-inhibits-sshd-for-every-interface-but-usb-tethering/15996/1))

* add a timeout to disable WiFi tethering when unused for a certain time. ([>here](https://forum.sailfishos.org/t/a-toggle-button-to-inhibits-sshd-for-every-interface-but-usb-tethering/15996/1))

* add a QRcode creation to access the WiFi network in Setting -> WiFi Sharing page. Unless the PIN / password or the finger print to show the password will unblur also the QRcode ([>here](https://forum.sailfishos.org/t/wifi-sharing-in-settings-does-not-display-a-qrcode/16079/1)).

* a `cron` task scheduled `@reboot`  is needed to fix some files in users/root home have too relaxed permissions set. ([>here](https://forum.sailfishos.org/t/some-files-in-users-root-home-have-too-relaxed-permissions-set/16004/1))

* develop a regular expressions pre-parser/sanitiser to deal with `iptables` rules for `connman` ([>here](https://forum.sailfishos.org/t/the-00-devmode-firewall-conf-does-not-apply/15990/4))

* do not let `lxc@multi-user.service` fails for no reason ([>here](https://forum.sailfishos.org/t/quick-start-guide-v1-5-5-3/15857/39))

* bring `Patch Manager` + `Web Catalog` to the next level and change the *crime novel* into a *love story* fo Sailors ([>here](https://forum.sailfishos.org/t/rfc-adding-shell-scripting-capabilities-will-bring-pm2-to-the-next-level/15987/5)), ([>here](https://forum.sailfishos.org/t/patch-manager-warning-label-to-add/15950/1)), ([>here](https://forum.sailfishos.org/t/rfc-adding-shell-scripting-capabilities-will-bring-pm2-to-the-next-level/15987/16)), ([>here](https://forum.sailfishos.org/t/rfc-adding-shell-scripting-capabilities-will-bring-pm2-to-the-next-level/15987/21)), ([>here](https://forum.sailfishos.org/t/rfc-adding-shell-scripting-capabilities-will-bring-pm2-to-the-next-level/15987/26)) and ([>here](https://forum.sailfishos.org/t/is-there-a-future-for-sailfishos/15463/112)).

* filesystem overlay tricks too old versions of filesystem utils like cp and tar but possibly also prevents that modem/GPS can be correctly configured ([>here](https://forum.sailfishos.org/t/the-coreutils-cp-and-gnu-tar-version-are-too-old-to-support-filesystem-overlay-correctly/16027/1))

* try to optimise the native browser `about:config`, some suggestions ([>here](https://forum.sailfishos.org/t/my-wishes-of-the-next-release-just-fixup-e-g-the-oom-killer-situations/15541/17))

* Considering the **USER BACKUP** section of [this guide](quick-start-guide.md), the Settings:System → System:Backup can be put in condition to work also using SSH connection. Below the “Add cloud account” can be added a button for “Use the SSH connection” with brief instructions. Then, also the restore procedure can be added.

* Evaluate a better and more general approach to backup and restore ([>here](https://forum.sailfishos.org/t/the-home-users-backup-my-backup-app-suggestions-for-improvements/16161/1))

---

**REQUEST OF CHANGES**

* the `sleep 1` takes between 1s and 2.6s to expire on Xperia 10 II despite the power saving mode but power saving makes this **HUGE** time jittering more probable. This should be fixed because it can creates more nasty problems and it is an indicator (common root cause, I suppose) of **HUGE** lag in interactive processes.

* when `ofono` service starts the `GPS`/modem has just read the configuration files from the original vendor partition not from the root overlay under which is mounted and this is the main reason because it is always a cold start.

* add a quick access to Android settings menu which at the moment is available with Settings:System -> Android Support -> Show Licenses -> (back).

* top menu can open the Settings:System menù but in that case it should fork the call otherwise pulling down the top menu makes the child to die and the top menu to retract delivering a bad user experience.

* in top menu, `SIM`s items can put on the same line with the locking screen icon in such a way to save vertical space.

* a single tap on the background raise the first line of the app menu but that raise should be sticky (configurable timeout where 0 means sticky) because usually it lasts too less for being useful.

* `VPN` icon in top menu is highlight when a data connection is active and shows the name of the config used. Unfortunately, when no any data connection is available it turns gray with the standard `VPN` label. This confuses the user about the service is enabled for raising the next connection or not. There are two ways to deal with this lack: 1. keep the icon highlight but rename its label in `VPN` or 2. turns gray but keep the label about the name of the configuration. In both cases, the user should be forbid to rename the `VPN` connection as `VPN` with a case unsentive check also for the file import feature. For a quick 1st implementation, I suggest to replace the label in `VPN:ON` when the `VPN` is not connected but ready to connect and `VPN:NO` otherwise. Another way of deliver this information is to add a green/gray dot to the VPN icon.

* in top menu the *Connect to Internet* icon/menu is appalling useless because everybody uses WiFI / Mobile data icons as long as data is a limited/charged resource while Wifi is not. Moreover the SIM choice in dual-SIM devices is granted in the top menu. Thus *Connect to Internet* expecially if a long press on a SIM leads to the SIM setting menu. Instead, an icon to access the Settings:System -> Connectivity:Mobile network is missing.

* `Pure Black Theme` and `Pure Black Backgrouds` should be delivered with the installation image (installed by default) because they partecipate to energy saving policy in OLED devices. An option, for the auto-enabling power save mode can be added to switch temporarly to these pure-black settings belows a certain battery thresold. For example `20% energy saving, 10% pure black mode` but the user can also choose `10% energy saving, 20% pure black mode`.

* device unlock max number of tires - it is not clear what the devices is going to do about it: a) offering new set of retries after a reboot; b) lock forever until a recognised fingerprint is given but it does not work during rebooting volume undecyphering thus is a quite dangerous statment, thus to exclude; c) delete permently the user data erasing the LUKS key which can be a nice feature to have in combination with a resetting to standard installation as long as the user explicetely choose this option and s/he should not allowed to. In fact, what it happens if the smartphone fall in the hands of someone that make all the tries just for playing with it or with the precise intention of delete your data or let them unaccesible? The best is that after N tries, a timeout 2x-increasing is set and displayed on the screen: 15min, 30min, 60min, 2h, 4h, 8h, 16h, etc.

* add an emergency immediate user data deletion / reset inserting a special `PIN` during the request of the device unlock `PIN` both during the boot or the screen unlocking procedure. A way to implement this, it is a secure erase of the `LUKS` key and continue/force the reboot which will land to a default `SFOS` installation in such a way the smartphone will brought back to the factory settings. About the `SD`/`MMC` card inside if it is present: a similar procedure can be performed but only if the user decided to encrypt it otherwise it supposed that data are not sensitive by choice.
