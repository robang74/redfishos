## Users backup analysis

Unfortunately, there is no app for SFOS that satisfies the backup needs of all the users, and this is the main topic of this page.

Here below is a list of positive contributions towards the aim of developing one that can fulfil the needs also of the most advanced end-users.

----

### MY BACKUP APP

This app is well-known and widespread, but it still has limits and issues:

* [my-backup app on OpenRepos](https://openrepos.net/content/slava/my-backup) by @slava 

> wrote in the app description:
> 
> **Important:** do not uninstall MyBackup versions 1.0.5 and older. Due to what seems to be a bug in busybox, the uninstall script can end up doing **rm -fr /** on some versions of Sailfish OS. Update the app prior to uninstalling it - update is safe, it doesn’t run that script.

About this bug, this is the bugfix commit:

* https://github.com/monich/harbour-mybackup/commit/1f0b799504962837636dd891626f0d8dc9b9197f

and here below is the related code:

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

The command `getent passwd` here would do almost the same as `cut -d: -f1 /etc/passwd` for users or `-f6` for user folders and guess what? Some users might have their home folder in `/` root. In SFOS, a quick way to find the users (humans) is to do `grep ^users: /etc/group because the others are system users.

This is the code to find the home folders:

```
for i in $(grep ^users: /etc/group | cut -d: -f4 | tr ',' ' '); 
do grep "^$i:" /etc/passwd; done | cut -d: -f6 |\
grep -E "^/home|^/root"
```

The last `grep` grants against mistakes: only users that have a home folder in `root` or `home` can be managed. The others? The others should not exist, or they are system users. Therefore, the @slava shell script uninstall code is not completely fixed yet.

However, to stay safe despite the script trying to deal with 114 users currently present in SFOS 4.5.0.19 /etc/passwd while usually 2 or 3 are involved (defaultuser, guest and root), we should check for the existence of a specific folder:

```
[ -d "$d/.local/share/openrepos-mybackup" ]
```

<sup>________</sup>

**dealing safely with paths**

At this point, I took a look at the [current version 1.0.6 of the RPM spec](https://github.com/monich/harbour-mybackup/blob/master/rpm/openrepos-mybackup.spec) file:

```
%install
rm -rf %{buildroot}
```

and I found another recursive deletion **without** any sanity check. Whatever someone we can say about the RPM %{buildroot} macro, there are two main rules for safely handling the path in combination with recursive deletion, especially if operating with elevated privileges.

1. Double-quoting the path strings, especially when they are carried into a variable. This would allow us to deal with paths containing spaces, but on the other side, the variable cannot contain multiple paths unless it is a multi-line content variable, so a `for` cycle should be used.

2. Always check that their content is correct before use and possibly within a range of expectations. Again, this can be easily done using a `for` cycle rather than acting on the variable itself, which can contain a multiple-line item list.

3. When the path is a folder, always append / at the end of the path string, like `/home/pippo/bin/` but NOT at the end of a variable that is supposed to contain a folder path, like `rm -rf "${void}"/` and obviously avoid `rm -rf` in scripts as much as possible.

<sup>________</sup>

**double quoting paths**

Here below is just a glimpse of what could happen with not-double-quoted paths:

> @slava wrote:
> 
> Well, this is bash:
> 
> ```
> $ unset x; echo ~$x/y
> ~/y
> $ ```

**This** is `bash` when correctly configured with `set -e` when you wish to see everything crashing like there were no tomorrow, usually on Friday at 4 p.m.:

```
~$ set -uo pipefail # into /etc/profile
~$ unset x; echo "~$x/y"
bash: x: unbound variable
```

**This** is `busybox` when you do things versus when you use a path for real:

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

I am not blaming people for missing the double-quotes in the scripts, because I constantly do it too, BUT it is **wrong** and usually on Friday at 4 p.m. you will discover HOW MUCH it is wrong.

However, I hate the idea of having to deal with paths that have spaces in them, but unfortunately, this is something unavoidable when home users are the targets of our scripts.

<sup>________</sup>

**always check paths**

Before executing critical or irreversible operations, always check the path, even when operating in a development or constrained environment.

```
%install
rm -rf %{buildroot}
```

In order to limit the operation above, one could check for something specific in that folder that should exist, which usually has a near-zero chance to exist in every other relevant path, like:

```
%install
test -e "%{buildroot}/$an-expected-file" && rm -rf "%{buildroot}"
```

with double quotes, obviously.

---

### ABOUT THE DESIGN

Usually, it is not a good idea to compile code for those tasks that are considered system administration activities, like user backup and restore.

The compiled code is fine for the GUI but the GUI should use shell scripts when acting on the filesystem level. Because:

* the shell scripts are architecture-independent;
* they are easy to modify, easy to fix, or just to customise;
* they can be changed during a manual system rescue activity to include corner cases that have been overlooked or for a badly bricked system far away from a working system;
* they can also work when the GUI support is unavailable;
* they can also work from the recovery image.

The console is the ultimate tool for rescuing a system, and the system administrators should be able to operate without the GUI or, in particular, when the GUI is down or in recovery mode.

Moreover, separation between GUI shell scripts brings not only a useful separation between the GUI and the sysadmin level but also tends to deliver better and more reliable by-design code for apps.

----

### BACKUP & RECOVERY SCRIPTS

The script suite for backup and recovery is far from being completed, and it seems that everyone has developed their own solution in one way or another depending on their personal needs, but the general problem has not been challenged yet.

> @robang74 wrote:
> 
> In the [Quick Start Guide](../quick-start-guide.md), there is a **USER BACKUP** section in which, by two shell scripts and the use of the SSH connection available in developer mode, it is possible to create a backup of the entire user home for every user and restore it.

> > @robang74 wrote:
> > 
> > @ric9k wrote:
> > 
> > I prefer to use a command line tool like rsync. (Some users recommend rclone)
> 
> The `rsync` is the best choice for additive backups of home users contents. While `tar` + `gunzip` is the most suitable option for restoring the smartphone immediately after a re-flashing operation, especially when an internet connection is not yet available, is not available at all, or is not well-configured enough to keep the smartphone always in a safe and private status.

<sup>________</sup>

**Differential backups**

Some advanced command-line utilities like `rsync` and `pigz` are missing from the root filesystem after the first boot, and they are also missing from the recovery boot image.

Until these utilities are introduced as default parts of `usedata` and `recovery boot` images, we cannot rely on them for the SailFish OS refactoring.

However, a wise combination of `find` with `-newer` and `md5sum` filesystem integrity checks will help us deliver a reliable differential backup system.

An alternative approach is to provide a tiny archive of tools to install immediately after the first boot, in such a way that `rsync` and `pigz` will be granted by default.

Obviously, the recovery image refactoring should include these tools as well.

