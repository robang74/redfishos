I have submited a feature request about Patch Manager:

* https://github.com/sailfishos-patches/patchmanager/issues/441

I wish to debate this approach here, if you like to partecipate.

---

#### DESCRIPTION

Reading the description of [this patch](https://coderus.openrepos.net/pm2/project/dnsmasq-connman-integration), we clearly realise that adding shell script capabilies will bring PM2 to the next level. In order to achieve this there are some type of specific scripts to keep in consideration:

- pre-install script: `pre-install.sh`
- post-install script: `post-install.sh`
- pre-remove script: `pre-remove.sh`
- post-remove script: `post-remove.sh`

Which are the same types that are allowed into any kind of package (rpm, deb, etc.). Obviously, these scripts should be executed with `root` privileges and possibly in a decently set enviroment. Possibly a $PATCH_PATH or $PATCH_DIR (with or without the underscore) could be set in order to refer to folder in which the patch archive is extracted. In this way, more files can be added to be parsed by the scripts or copied into the system.

#### ADDITIONAL INFORMATION

This feature can be implemented in two different ways:

- allow to add four scripts for each of that task with .sh extension
- allow to add a single text file with .shell extension which contains 4 sections.

In the last case, something like that:

```
[pre-install]
rm -f /etc/resolv.conf

#[post-install]
#[pre-remove]

[post-remove]
ln -sf /run/connman/resolv.conf /etc/resolv.conf
```

One or another way is indifferent and It is a matter of taste. In .sh case the files do not need to be executable to run but just being interpretable. However, the .sh approach avoid to have a parser to split the .shell single file and moreover, it clears the possible misunderstanding about the chance that every single line will be executed by a different shell instance:

```
/bin/ash pre-install.sh
```
instead of

```
/bin/ash -c "first line"
...
/bin/ash -c "last line"
```

It is suggested to use /bin/ash as default interpreter which is enough powerful in terms of scripting even if does not implement the full set of bashism. This because the scripts relying on /bin/ash can run on /bin/bash as well but in some system /bin/bash could be optional.

---

**UPDATED**

An example of the current limitations of `Patch Manager` which is great for patching the `UI` but completely indadeguate for patching the system.

Due to its way of working the `Patch Manager` is not the right tool for this kind of patches but the `dnsmasq` `RPM` can be fixed with this patch:

* [robang74-dnsmasq-connman-integration-0.0.6.tar.gz](https://coderus.openrepos.net/media/documents/robang74-dnsmasq-connman-integration-0.0.6.tar.gz)

Changelog: 0.0.6 - connman starts after patchmanager and dnsmasq before connman (in my whishes)

In practice, because this patch will not be applied unless Patch Manager will complete is job, sometimes the connman and dnsmasq services will start before their .service files have been patched and therefore the system will not be able to resolv the domain names. More over, the network restart from SailFish Utilities cannot solve the issue and also rebooting might not solve but usually does.

---

There is an intermediate layer of complexity between a `RPM` which offer a lot of features (full feature) at the cost of having to deal with its specific syntax (which is quite complex because it should deal with all the dependencies of the all the packages in the repository and with the installed ones) and executing shell scripts during a `Patch Manager` installation. `Web Catalog` is not the problem because it has to deal with a compressed archive (e.g. `pippo.tar.gz`) while the `Patch Manager` have just to execute 4 simple operations as far as all four scripts files exist. There is a **HUGE** gap between applying a patch (`diff -pruN`) and preparing a `RPM`, in this **HUGE** gap, `Patch Manager` shell scripting capability has its own place.

Fulfilling that gap will step down the curve of people that can learn from doing a patch, doing a patch + scripting and the develop the skills to package an `RPM`. The learning curve should be as smooth as possible in order to enlarge the user-base and in this specific case the user-base means advanced smartphone users that get involved into modding / improving their system. If you expect that people jump from patching and packging, many will be lost. P.S.: BTW, hidden profile is not such a great sign of openess and trust towards the others people.

---

**SYSTEM PM2 PATCHES, IMPLEMENTATION EXAMPLE**

In applying this `Patch Manager` patch, two cases arises

* https://coderus.openrepos.net/pm2/project/x10ii-iii-agps-config-emea

**case #1**: `cacerts_gps` folder exists

```
[root@sfos ~]# ls -al /system/etc/security/cacerts_gps
isrgrootx1.pem -> /tmp/patchmanager/.../isrgrootx1.pem
roots.pem -> /tmp/patchmanager/.../roots.pem
```

**case #2**: `cacerts_gps` folder does not exist

```
[root@sfos ~]# ls -al /system/etc/security/cacerts_gps
cacerts_gps -> /tmp/patchmanager/system/etc/security/cacerts_gps
```

Both case are wrong because `Patch Manager` creates symlink where it was supposed to create dirs and files. In fact, symlinks are not the same story because some tools that operate on the filesystem required a specific option to follow symlinks. Like old versions of the `tar` and `tar` is one of the widely used tool for doing backups. The approach can be easily changed following these examples:

```
mkdir /tmp/test
cd /tmp/test
repourl="coderus.openrepos.net/media/documents"
tarball="robang74-x10ii-iii-agps-config-emea-0.2.0.tar.gz"
curl https://$repourl/$tarball | tar xvzf -
```

The following shell code will works with `-p0` and with `-p1` because the `sed` `regex` deal with `/var`, `new/var` and `./new/var` indifferently and every relative `filepath` is converted into an absolute `/filepath`.

```
files=$(sed -ne "s,^+++ *\.*[^/]*\([^ ]*\).*,/\\1,p" unified_diff.patch)
grep -qe "^+++ */" unified_diff.patch || false
plvl=$?
```

Now it is time to do a backup, for future restore but remember that overlay tricks the old `tar`, therefore a recent `tar` or `busybox` `tar` is needed

```
busybox tar czf /$store_dirpath/patch-$project_name.tar.gz $files
echo "$files" > /$store_dirpath/patch-$project_name.list
```

This determines the uninstall procedure by defining a global non-parametric function

```
patch_uninstall() { 
	rm -f $(cat /$store_dirpath/patch-$project_name.list)
	busybox tar xzf /$store_dirpath/patch-$project_name.tar.gz -C /
}
```

This is useful before apply the `diff` patch in order to creates dir and files not symlinks, therefore the symlinks engine could be ignored

```
patch_apply() {
	ret=0
	for i in $files; do mkdir -p $(basename $i); touch $i; done
	if ! patch -d / $pagrs -p$plvl unified_diff.patch; then 
		patch_uninstall
		ret=$((1+$?))
	fi
	return $ret
}
```

Is a system patch? For example `system_diff.patch` instead of `unified_diff.patch`? No, then uninstall at shutdown time. But why uninstall a patch at shutdown time with the risk that shutdown procedure and the related uninstall procedure can be interupped by a user physical keys controlled switch off? Because the filesystem for UI patches is volatile by default? Also the root filesystem about the reboot? Anyway:

```
num=$(printf "%05d" $(ls -1 /$store_dirpath/[0-9]*.tgz | wc -l))
busybox tar czf /$store_dirpath/$num-$project_name_applied.tar.gz $files
```

At boot time, in something functionally equivalent to `/etc/rc.local` but after all system device has been mounted not just those in `/etc/fstab` but before every `systemd` service will start, will be inserted the restoring procedure which will applies all the patch in their correct sequence

```
files=$(ls -1 /$store_dirpath/[0-9]*_applied.tar.gz)
test "$files" = "" && exit 0
for i in $files; do busybox tar xzf $i -C /; done
```

That's all, unless I forgot or overlooked something essential or important.

----

**UPDATE #1**

This seems promising to install system updates also for those that do not require a reboot:

* https://man7.org/linux/man-pages/man7/systemd.special.7.html

>        system-update.target, system-update-pre.target,
>        system-update-cleanup.service
>            A special target unit that is used for offline system
>            updates.  systemd-system-update-generator(8) will redirect
>            the boot process to this target if /system-update or
>            /etc/system-update exists. For more information see
>            systemd.offline-updates(7).

* https://man7.org/linux/man-pages/man7/systemd.offline-updates.7.html

It seems a general solution that requires - by documentation - a reboot but the reboot is managed by the configuration and not automatically enforced. However, due to its specific nature and delicacy, it can be a better option to add a service ordering related to `system-update.target` or even better `system-update-pre.target` in such a way that the patches which might conflicts with package updates will be applied before making them fail, as expected to be, instead of being overwritten.

**UPDATE #2**

The `Patch Manager` patches can be applied and unapplied many times during a user session and this is great feature :heart_eyes:. However, changing the way in which the `PM2` works some of them might not fall into this category.

For example [DNS Alternative](https://openrepos.net/content/kan/dns-alternative) is delivered like a `RPM` and it proobably it is the best way to have it. Before, it was a `RPM` package a developer might develop a patch. In general the way of providing a change could be exemplified in three main passages:

> 1. system patch -> 2. optional RPM package -> 3. default RPM package 

Which also implies three different level of integration with `SFOS`: unsopported (community only), supported in terms of the repository consistency (community + Jolla) and Jolla supported (commercial support). Which three different level of `SLA` and `QoS` in terms of supporting the end-users.

IMHO, the main difference between a system patch and a `RPM` package is bringing into the system new binaries rather than modify the system configuration. In this second case, having a system patch seems more reasonable expecially for the end-users that can choose to reconfigure the system as they wish - in the same manner they are doing with `UI`.

While `UI` patches can requires an application retart and a fingerprinter reader patch is functionally identical to a patch for e.g. the Settings, those have impact to the network and rely on the installation of 3rd party package e.g. dnsmasq need a little more attention. In fact, restarting network by `SailFish Utilities` do not consider the case in which dnsmasq is installed and configured (to fix). For all the others, a reboot is almost necessary.

This brings us to the conclusion that there are three patches classes:

1. those changes `UI`, app, stand-alone services level: easy to restart
2. those changes complex services like network/d-bus: might or might not be restarted
3. those changes the system at such level that a reboot is needed: restart useless

The #1 and the #3 are almost straightforward cases to deal with. The second is a matter of policy: dnsmasq is optional but supported by network restart because it is an important feature that users usually requires to enable. Or on the other side is a 3rd party unsupported services an then the end-user needs to reboot his/her smartphone.

---

> Settings:System -> Patchmanger:Settings -> Activate enabled Patches when booting

**Why** activating at boot time instead of made them permanent with that option?

This question is extremely relevant - not only for the consequences that brings in terms of constrains - but also because it is a design choice. This design choice should be explained  in details into the documentation otherwise this software have to be re-design from scratch.

No, I cannot make a pull request to fix this because this is an information that WHO designed the software should explain. It could be a very good reason/decision or it was a good reason/decision at that time, e.g. SFOS 2.x but not anymore. 

This is the reason because this design choices should be documented, they aging and they are still impacting despite aging. The temporary workaroud became the product and the product became the legacy. We need to stop this before even it begins, documenting it.

What this has to do with roles? Unless someone plays the product and project manager role in the community those PoVs are missing and in fact - AFAIK - the part of the documentation which refers to this design choice is missing.

---

We evaluate a change betwee "*activate at boot time*" and "*keep persistent*".

We can do a confrontation:

* persistence is easier because we "*patch & forget*"
* forgetting is not a good practice therefore checking
* checking but when?
* every time `Patch Manager` page is shown
* how we can implement this check?
* `pach -Rp0 --dry-run` can fail or not
* is it quick enough?
* yes -> done

Here we are, we can have a `Persistent Patch Manager` with a little of changes. Now, it is your time to play roles or simply express yourself. What good can provide persistence and what problems can cause?

---

About the better solution: 

1. I show that it is easy and feasible to patch the filesystem (files and directory) without creating links to a temporary directory
2. the `Patch Manager` can move easily from "*apply at boot time*" in "*persistent mode*" with check by `--dry-run` option which probably is just implemented because currently the `Patch Manager` is able to detect when a patched file is changed
3. avoid that `Patch Manager` removes patches when the system is asked to go down for shutdown or reboot

In particular about the point #3, I have tested with success and satisfaction a `killall -9 patchmanager`. Obviously this would not provide persistence because `/tmp/patchmanager` is volatile. Now, I have to make another test based on information collected with `find /tmp/patchmanager -type f`.

The test will be similar to the shell script code I presented here:

0. collect the list of files using `find`
1. backup all the system files when all patches are disabled (original versions) which probably is not necessary because it is reasonable that they are stored somewhere
2. kill the `patchmanger`
3. use the list of files to remove the links and replace with real files
4. start again the `patchmanager` to check how is going to behave
5. do a system reboot instead of point #4

Some tests, just before going to edit the two scripts that apply patches and one in `Perl` and another in shell script.

After that, I will probably discover the `SFOS` ill-design choice that constrain the `Patch Manager` to act volatile instead of providing persistence. Or in a lucky scenario, I will simple discover that volatile for `Patch Manager` is not a constrain (or not anymore).

In both cases the result will be a lot of fun. :blush:

**UPDATE**

About the point #2, checking the `/tmp/patchmanager3/patchmanager.log` I found that the check with `patch -Rp0 --dry-run` is exactly what `Patch Manager` does to check that each enabled patch is applied correctly.

---

BTW the main question is: **why a community should care** modding the SFOS in such a manner that can support a *system configuration manager* and a *fleet management tool*?

The first and straightforward answer: a safe and friendly relationship with upgrades but there is **much more** related to these two tools which are missing because the `SFOS` is not designed to support them. That **much more** is also about Jolla profitability therefore Jolla should be **much more** interested in this design-changes than the community.

After all, unless people here wish to follow a strict policy about RPMs repository like Debian, Ubuntu, RedHat, SuSE, etc are doing which brings a lot of top-down organised work (debian is a no-profit foundation, in fact), then those two tools are the solely way to go in order to obtain something equivalent or at least, a restore system to the last working configuration.

By the `ZFS` has filesystem snapshots for this purposes but it is not the right approach for dealing with a fleet of IoT devices. It is tailored for servers even desktop can leverage it with some important constrains (user data, for example).

Finally: am I going to change the `Patch Manager` in order to make it a *system configuration manager*. I do not think so. Since the beginning, I am thinking about another completely different solution much more flexible. But it would be a shame to not learn form what has been done and learning by doing is the best way. Doing *strange* things under your PoV but they seems strange exactly because they are challenging the current system constrains.

**UPDATE #1**

This is a patch which probably will not work because I saw that `Patch Manager` runs in a jail and reasonably with user-privileges and not root-privileges (**update**: it works, after a reboot also). Despite the privileges, it still a proof-of-concept rather than a definitive solution.

<sub>

```
--- /usr/libexec/pm_unapply
+++ /usr/libexec/pm_unapply
@@ -25,7 +25,8 @@
 PATCH_EDITED_NAME="unified_diff_${SYS_BITNESS}bit.patch"
 PATCH_EDITED_BACKUP="$PM_PATCH_BACKUP_DIR"/"$PATCH_EDITED_NAME"
 
-ROOT_DIR="/tmp/patchmanager"
+ROOT_DIR="/"
+TMP_ROOT_DIR="/tmp/patchmanager"
 
 # Applications
 PATCH_EXEC="/usr/bin/patch"
@@ -66,6 +67,7 @@
   exit 0
 }
 
+files=""
 verify_text_patch() {
   if [ -f "$PATCH_FILE" ]; then
     log
@@ -74,6 +76,12 @@
     log "----------------------------------"
     log
 
+    files=$(/bin/sed -ne "s,^+++ *\.*[^/]*\([^ ]*\).*,/\\1,p" "$PATCH_PATH")
+    for i in $files; do
+      [ -L "$i" ] && /bin/rm "$i"
+      [ -f "$TMP_ROOT_DIR/$i" ] && /bin/cp -arf "$TMP_ROOT_DIR/$i" "$i"
+    done
+
     $PATCH_EXEC -R -p 1 -d "$ROOT_DIR" --dry-run < "$PATCH_FILE" 2>&1 | tee -a "$PM_LOG_FILE"
   fi
 }
@@ -87,6 +95,7 @@
     log
 
     $PATCH_EXEC -R -p 1 -d "$ROOT_DIR" --no-backup-if-mismatch < "$PATCH_FILE" 2>&1 | tee -a "$PM_LOG_FILE"
+    for i in $files; do [ -s "$i" ] || /bin/rm -f "$i"; done
   fi
 }
 
--- /usr/libexec/pm_apply
+++ /usr/libexec/pm_apply
@@ -29,7 +29,7 @@
     source /etc/patchmanager/manglelist.conf
 fi
 
-ROOT_DIR="/tmp/patchmanager"
+ROOT_DIR="/"
 
 # Applications
 PATCH_EXEC="/usr/bin/patch"
@@ -69,6 +69,13 @@
     log "Test if already applied patch"
     log "----------------------------------"
     log
+
+    files=$(/bin/sed -ne "s,^+++ *\.*[^/]*\([^ ]*\).*,/\\1,p" "$PATCH_PATH")
+    for i in $files; do
+      if [ -L "$i" ]; then
+        /bin/rm "$i" && /bin/touch "$i"
+      fi
+    done
 
     $PATCH_EXEC -R -p 1 -d "$ROOT_DIR" --dry-run < "$PATCH_PATH" 2>&1 | tee -a "$PM_LOG_FILE"
```

</sub>

**UPDATE #2**

Instead about the current version of `Patch Manager`, I forked it from its github repository. Today with seven patches

* [8 patches on devel branch with an unified view](https://github.com/sailfishos-patches/patchmanager/compare/master...robang74:patchmanager:devel?diff=unified) (slightly tested code)
* [patched files ready to install in a tarball](https://raw.githubusercontent.com/robang74/patchmanager/devel/tgz/patchmanager-unified-pm_scripts-v0.0.8.tgz) (`devel-su curl $link | tar xvz -C /`) 

I have unified the `pm_apply` and `pm_unapply` shells script in a single one `pm_patch.env` because most of the code was redundant.

* `pm_apply` does `source pm_patch.env apply "$@"`
* `pm_unapply` does `source pm_patch.env unapply "$@"`

This would help to maintain such shell script code in the future.

---

**Some few of example**

Using the `patch` without `-r /dev/null` the `.rej` file break the restart of a daemon because that file can be read as part of a `cond.d` folder and mess-up everything. In fact, it did preventing the daemon to load - it is also a daemon fault that should ignore .`origin`, `.rej`, `.rpmold` and `.rpmnew` files:

* https://github.com/sailfishos-patches/patchmanager/commit/21f3e6698049f508e55f6ffc508031c57f522f2e

A simple parsing rule for the patch file path was implemented in C++ code with a couple of loop, here:

* https://github.com/sailfishos-patches/patchmanager/commit/f247da61c2e2df06274b00d40ddc605b98740ade

Here below a succulent corner case:

* https://coderus.openrepos.net/pm2/project/utilities-quick-fp-restart

In this project the patches v0.0.1 and v0.0.2 can be applied multiple times. While the v0.0.3 cannot. You may claim that it is irrelevant. It is not - It going to say that there is not a simple testing tool that check and test the patches in order to validate them.

About a tool to test/validate the patches and to rescue the systems from their application, I just wrote it but not published yet because it is in its early version. I wrote it because, I broke the system - but instead of re-flashing - I did a rescue tool which is a shell script that can easily replace the PM from command line and patching the system. It is far a away to be complete but good enough to let me to rescue my system from the mess that PM did because it does do what is supposed to (or it should do).

So, I confirm you that PM working at system level quickly tends to mess-up the system. However, this should be seen as a limitation not a feature. In fact, it has been reported that PM3 was developed with the purpose of to limit its functionality to the UI. I can live with that as long as and as far as, there is an alternative way to do a system configuration management with templates or a set of patches.

**Lesson Learned**

If we ask a fish to climb a tree and a monkey to swim, both will show poor performances.

To develop a safe and functional configuration manager tool, it is request a system administration united with an embedded system experience plus good skills in scripting, preferably `bash`/`ash`/`sh` `with` sed/`awk` (regular expressions) because `perl` is a write-only language (fast to write and easy to rewrite, again again again).

Instead, technologies like C++, d-bus and Qt5 are for the UI level but it would be better that higher level will not take decisions about how to deal with the system configuration but just help the end-user to choose the configuration s/he prefers.

This separation between the UI (user interface) and the BL (business logic) is especially true and useful for a system configuration management tool which **SHOULD** be available in a shell or a terminal. Otherwise, it will be unavailable when the UI is not available and this would be unacceptable which is the reason because PM2 -> PM3 constrained the Patch Manager in such a way that it can apply just volatile changes.

If we put all the information and skills and experience together, everything make sense, and all the PoV fits in the same puzzle. It was not the PM that need to be jailed but it was needed a clear separation between the UI level and the system level. A clear separation about technologies involved, implementation and design (in the reverse order: design -> implementation -> technologies).

I hope this help for the future.

---

### SYSTEM PATCH MANAGER

You can skip the introductory sections and jump directly to the end where the technical stuff is presented. In case you like that, you my came back here to read the premises.

**Rationale**

A system patch manager should be able to record the changes that are affecting the system and revert / apply them in a fail-safe way. This means that it SHOULD work from a console and it should work from a recovery image with minimum additional requisites, possibly none.

Adding a full scripting capability is a little more complex task than including such script into a package and running them because shell script can do arbitrary things and in some corner cases (and failures) can do untracked / unexpected things that cannot be reverted with counter-acting script (eg. `post-install.sh` -> `pre-remove.sh`).

This is true also for RPM packages - mitigated by the fact that usually packages maintainers have a system test facility that allows them to validate the RPM packages for a wide variety of scenarios and different system configurations - plus - mitigated by the fact that RPM system is a well established way of installing / removing software which is in production since 1997.

---

**Why do not use RPM to patch the system?**

Because the RPM is a system to install software not to apply patches and do traceable system configuration changes. For sure some tools for this aim, exist out of there. Yes, they are named configuration management system. Usually they are tailored for a specific system or highly configurable for a class of system (eg. GNU/Linux distributions). The odd is that in SFOS end-users are used to use Patch Manager from the UI and a kind of integration with it would be easier to introduce them into this new dimension.

Moreover, there are many ways to track unexpected system changes, also. In particular `inotify` approach but can be a little tricky to use on a living system even if it will be probably a long term general solution or alternatively a filesystem that can provide a standard reliable changes log or snapshots by design.

---

**Apply patches to the system can brick it**

Breaking the system in making experiments with SFOS, which is equivalent to using it as any other GNU/Linux system as much as it can be considered similar, it is the main reason because you are using SFOS because there are no really other reason apart fairly tales and a matter of personal taste.

* https://www.tecmint.com/clone-linux-server/

Backup before brick your root filesystem.

---

#### Technical approach

Therefore developing shell scripts that can be integrated with a slightly modified version of the current `Patch Manager` is the main way and storing the system patches into `Web Catalog` is also a good option to go, naturally.

Instead of start adding a generic and arbitrary shell scripting capability, I focused on system configurations and their system services. For this aim adding a header to the patch seems a reasonable easy way to cope with the most interesting and common cases.

This is a testing patch that is going for that way:

* https://coderus.openrepos.net/pm2/project/dnsmasq-connman-integration

Here below an example of such a header for testing purposes:

<sub>

```
#!/bin/bash ## this line for a patch which header is a shell script ############
##
## (C) 2023, Roberto A. Foglietta <roberto.foglietta@gmail.com>
##           released under MIT (tlo.mit.edu) license terms
##
## This is a system patch header example for SailFish OS system patch manager
##
#\header #######################################################################
#
# type: system
# target: sfos
# services: dnsmasq connman
#
## optional fields using tabs instead of spaces just for test ##################
#
#	name: 		dnsmasq-connman-integration	# a comment
#	provider: 	robang74					# another comment
#	version: 	0.1.1						# yes another one
#
## a repetition, a variant and an unrecognised fields just for test ############
#
# name      : dnsmasq-connman-integration-not-fit # this should raise a warning
# services	: dnsmasq, connman;
# string	: "hello world"
#
#/header #######################################################################
#
## put the shell script body between this line and the --- end of header mark ##
---
```

</sub>

Just a set of essential information which the vital part is:

* `services: dnsmasq connman`

because everything else is for separate the volatile UI from the permanent system patches and to separate the application of those patches between the SFOS and your laptop/PC GNU/Linux system.

After all, the beauty of such approach is that can be used also for every GNU/Linux system and every others system which is reasonably similar and provides a shell compatible scripting environment.


