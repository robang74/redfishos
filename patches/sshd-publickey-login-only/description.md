In Settings:System -> System:Developers tools page is missing the option to disable the SSH connection by the WiFi or to limit it to accept the public-key login only. Moreover, it is also missing a timeout that shutdown the SSHd and WiFi tethering services after X minutes which have not been used.

> **ATTENTION**: the Patch Manager is not the right tool for this kind of patch because the modem/GPS and ofono will read the config before it has been patched. Follow the manual installation procedure, instead.

Soon or later, this will bring you to regret yourself: you will go around in the city with both services activated, possibly after having chosen `pippo` like root password because you were annoyed to digit it many times a day/hour.

Humans are the weakest link of the security chain, the 2nd weakest link is a poor system configuration. This patch is going to address both because it allows you to keep the SSHd configuration under control and lets you live without the burden of dealing with a long and fingers-cramping password.

#### STEPS TO INSTALL ####

Creation and installation of the RSA key by USB (192.168.2.15) or WiFi tethering (172.28.172.1):

```
pcos:$ ssh-keygen -t rsa -b 4096 -C "sailor@jolla.com" # unless you did before
pcos:$ ssh-copy-id -i ~/.ssh/id_rsa.pub defaultuser@192.168.2.15
pcos:$ ssh defaultuser@192.168.2.15
sfos:$ devel-su /bin/bash
sfos:# install -Dpo root -g root -m 600 -t ~root/.ssh/ ~defaultuser/.ssh/auth*keys
```

In the following these definitions are set:

```
patch_vers=0.0.3
patch_file="/tmp/unified_diff.patch"
patch_opts="-Efp1 -r /dev/null --no-backup-if-mismatch -d/"
patch_save=/root/sshd-rsakey-login-${patch_vers}.patch
patch_link="https://tinyurl.com/2byu5gvc"
```

0. install this patch but do not apply it, just to receive updates notifications
1. download the patch: curl -L $patch_link | tar xz -C /tmp
2. check the patch: patch --dry-run $patch_opts -i $patch_file
3. manually install the patch: patch $patch_opts -i $patch_file
4. save the patch: mv -f $patch_file $patch_save

or a single leap of trust, download, extract, copy and install:

```
curl -L $patch_link | tar xz -O | tee $patch_save | patch $patch_opts
```

The patch is immediately active. No service reload is needed. Test the password-less login, fast and safe:

`pcos:$ ssh root@192.168.2.15`

#### UNINSTALL & RESCUE ####

How to deal with the installed patch in all others cases, please check

-> https://tinyurl.com/249c72w8

The instructions have been provided for another patch but are similar.

#### EXTRA SECURITY ####

At this point you might wonder how/why you forget to re-activate the patch and (re)start the service and find yourself in the previous unsafe scenario. Among the weakest security links (humans), you are particularly attracted to the real-world at the point of forgetting to bite your bits before going for a life. In this case, I suggest you to install qCommand and create two commands with root privileges:

OFF rule: `iptables -I connman-INPUT 1 -p tcp -m tcp --syn --dport 22 ! -i rndis0 -j DROP`

After these, the developer SSHd service will be available only by USB connection, to revert back:

ON rule: `iptables -D connman-INPUT -p tcp -m tcp --syn --dport 22 ! -i rndis0 -j DROP`

To avoid SSH connection from non-local interfaces, some rules has been inserted into 00-devmode-firewall.conf and for example:

```
iptables -I connman-INPUT 1 -p tcp -m tcp --syn --match multiport --dports 22,2222 -i tether -j ACCEPT
iptables -I connman-INPUT 2 -p tcp -m tcp --syn --match multiport --dports 22,2222 ! -i rndis0 -j DROP
```

Then the ON/OFF iptables commands above will do the magic. The port 2222 has been added for backup and to differentiate the ON/OFF rule from the default rule just in case a software bug will delete two times the ON rule would not find a match in the second by default. Another approach is to give a name to the ON rule and delete it by its name.

#### CHANGELOG ####

0.0.5 - like v0.0.4 but with connman in services because the iptables rules for firewalling the SSH daemon on some interfaces.

0.0.4 - like v0.0.3 but with the system patch header. 

This is a hybrid patch, it can be applied to the system or by the Patch Manager

0.0.3 - like v0.0.2 but with rules conformant to connman style + ethernet added

Because connman inject the iptables rules when an interface goes up, I did not have the chance to test [wifi] and [ethernet] sections. However, because those sections were both present in the original file while the new rule associated to them is the same used for [tethering] which works then is reasonable that also those sections will work properly.

0.0.2 - SYN on ports 22 and 2222 filtered on non-local interfaces

0.0.1 - first release
