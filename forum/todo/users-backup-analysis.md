Unfortunately there is no app for SFOS that satisfies the backups need of all the users and this is the main reason for this new thread.

Here below a list of positive contributions towards the aim to develop one which can fulfill the needs of most advanced and end-users.

----

**MY BACKUP APP**

This apps is well-known and widespread but still have limits and issues:

* [my-backup app on OpenRepos](https://openrepos.net/content/slava/my-backup) by @slava 

> **Important:** do not uninstall MyBackup versions 1.0.5 and older. Due to what seems to be a bug in busybox, the uninstall script can end up doing **rm -fr /** on some versions of Sailfish OS. Update the app prior to uninstalling it - update is safe, it doesn’t run that script.

**about this bug**

This is the bugfix commit:

* https://github.com/monich/harbour-mybackup/commit/1f0b799504962837636dd891626f0d8dc9b9197f

and here below the related code

```
%postun
if [ "$1" == 0 ] ; then
  for u in $(getent passwd | cut -d: -f1); do
    eval rm -fr ~$u/.local/share/openrepos-mybackup ||:
  for d in $(getent passwd | cut -d: -f6) ; do
    if [ "$d" != "" ] && [ "$d" != "/" ] && \
       [ -d "$d/.local/share/openrepos-mybackup" ] ; then
      rm -fr "$d/.local/share/openrepos-mybackup" ||:
    fi
  done
fi
```

The command `getent passwd` here would do almost the same as `cut -d: -f1 /etc/passwd` for users or `-f6` for user folders and guess what? Some users might have their home folder in `/` root. In SFOS, a quick way to find the users (humans) is to do `grep ^users: /etc/group because the others are system users. This is the code to find the home folders:

```
for i in $(grep ^users: /etc/group | cut -d: -f4 | tr ',' ' '); 
do grep "^$i:" /etc/passwd; done | cut -d: -f6 |\
grep -E "^/home|^/root"
```
The last grep grants for mistakes: only users that have a home folder in `root` or `home` can be managed. The others? The others should not exist or they are system users. Therefore the code - the @slava shell script uninstall code - is not completely fixed, yet.

However, to stay safe despite the script trying to challenge 114 users currently present in SFOS 4.5.0.19 /etc/passwd while usually 2 or 3 are involved (defaultuser, guest and root), it check for the existence of its own folder creation:

`[ -d "$d/.local/share/openrepos-mybackup" ]`


**dealing safely with paths**

At this point, I took a look to the [current version 1.0.6 of the RPM spec](https://github.com/monich/harbour-mybackup/blob/master/rpm/openrepos-mybackup.spec) file:

```
%install
rm -rf %{buildroot}
```

and I found another recursive deletion **without** any sanity check. Whatever someone can say about the RPM %{buildroot} macro, there are two main rules to safely handling the path in combination with recursive deletion especially if operate by elevated privileges:

1. double quoting the path strings
2. always check that their content is safe and possibly within a range of expectations
3. when the path is a folder always append / at the end of the path (twice does not hurt) 

In the code above @slava leveraged the second part of the second point to grant that the script is going to delete the right folder (or at least not a completely arbitrary one).

**double quoting paths**

Here below just a glimpse of what could happen with not doubled quoted paths:

[quote="slava, post:21, topic:16132"]
Well, this is bash:

```
$ unset x; echo ~$x/y
~/y
$
```
[/quote]

**This** is `bash` when correctly configured (*and -e when you wish to see everything crashing like there were no tomorrow usually on Friday at 4pm*):

```
~$ set -uo pipefail # into /etc/profile
~$ unset x; echo "~$x/y"
bash: x: unbound variable
```

**This** is `busybox` when you do things VS when you use a path for real:

```
# rpm -q busybox
busybox-1.34.1+git2-1.8.1.jolla.aarch64
# ash
# unset x; echo ~$x/y
~
# unset x; echo "~$x/y"
~/y
# set -uo pipefail
# unset x; echo ~$x/y
-bash: x: parameter not set
```

I am not blaming you for missing the quotes, because I constantly do too BUT it is **wrong** and usually on Friday at 4pm you will discover HOW MUCH it is wrong.

**always check paths**

Before executing critical or irreversible operations, always check the path even when operating in a development / constrained environment.

```
%install
rm -rf %{buildroot}
```

In order to limiting the operation above, one could check for something specific in that folder that should exists but it usually has a near-zero chance to exist in every other relevant paths, like:

```
%install
test -f "%{buildroot}/$specfile" && rm -rf "%{buildroot}"
```

plus double quotes, obviously.

---

**about the design**

Usually it is not a good idea to compile code for those tasks which are usually considered system administration like user backup and restore. The compiled code is fine for the GUI but the GUI should use shell scripts. Because the shell scripts are arch-independent, because they are easy to modify and fix or just customize.

The console is the ultimate tool for rescue a system and the system administrators should be able to operate also without the GUI or - in particular - when the GUI is down or in rescue mode. Moreover, separation between GUI shell scripts brings - not only a useful separation between the GUI and the sysadmin level - but also tends to deliver better and more reliable code/apps.

----

**SCRIPTING APPROACH**

The scripting approach is far away to be completed and it seems that everyone developed its own solution in one way or another depending on their personal needs but the general problem has not been challenged yet.

[quote="robang74, post:2, topic:16132"]
In the [Quick Start Guide](../quick-start-guide.md), there is a **USER BACKUP** section in which by two shell scripts and the use of the SSH connection available in developer mode, it is possible to create a backup of the entire user home for every users and restore it.
[/quote]

[quote="robang74, post:24, topic:16132, full:true"]
[quote="ric9k, post:19, topic:16132"]
I prefer to use a command line tool like rsync. (Some users recommend rclone)
[/quote]

The `rsync` is the best choice for additive backups of home users contents while `tar` + `gunzip` is the most suitable option for restoring the smartphone immediately after a re-flashing operation especially when an internet connection is not available, yet or it is not available one well-configured enough to be enough secure to keep the smartphone always in a safe/private status.
[/quote]

---

### Differential backups

Writing about backup, we noticed that some advanced command line utilities like rsync and pigz are missing from the root filesystem after the first boot and they are missing as well into the recovery boot image. Until that utility is not introduced as the default part of usedata and recovery boot images, we cannot rely on them for the SailFish OS refactoring.

However a wise combination of find with -newer and md5sum [filesystem integrity check](../4.5.0.21/README.md#file-tree-checksum) will helps us to deliver a reliable differential backup system that can be adopted for the SailFish OS refactoring, also.

An alternative approach is to build and deliver an off-line tiny set of packages to install immediately after the first boot in such a way that rsync and pigz will be granted as facilities. Obviously, the recovery image refactoring should include these tools, as well.
