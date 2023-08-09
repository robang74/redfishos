This patch aims to create in /usr/bin an ash-compatible shell script named setnet-postroute.sh and the users can execute it by a terminal or a SSH session or by qCommand or any other tool that can execute a script with root privileges. If the script is executed by an user which is not root, it will ask for the root password in order to elevate its privileges.

USAGE: devel-su /bin/ash /tmp/patchmanager/usr/bin/setnet-postroute.sh (by user)

This helps those who frequently use the developer mode via USB and wish to not have to also have the WiFi tethering enabled for surfing the Internet.

In combination with the SSH password-less system patch, the following steps allows the network tethering via USB on developer mode:

- ssh root@192.168.2.15 /tmp/patchmanager/usr/bin/setnet-postroute.sh

Finally, set the DNSes on your laptop/PC which means:

> 192.168.2.15 → if dnsmasq is running on SFOS or any other equivalent service
> 9.9.9.9, 94.140.14.14, 149.112.112.112, 94.140.15.15 → otherwise

and your SFOS smartphone IP on usb0 as default route:

> 0.0.0.0, 0.0.0.0, 192.168.2.15 → in Ubuntu network manager or equivalent
> sudo route add default gw 192.168.2.15/0 usb0 → by command line

In your case usb0 may have another name but that parameter is optional, you can avoid it or find out the actual interface name with ifconfig or ip a. The settings on your laptop/PC can be permanent but the POSTROUTE nating rule may not be permanent after a reboot and possibly can interfere with other kinds of tethering like the WiFi one. In such a case, you have to run the script again to switch to the new outbound interface, the POSTROUTE rule.

Therefore this patch is for expert users and developers. Util this feature will not added to SFOS and managed by connman, it will be easier to install one of the package listed here:

* usb-moded-connection-sharing-android-connman-config
* usb-moded-connection-sharing-android-config

Unless, you live in developer mode and you are acknowledged about how easy it is cracking WiFi passwords.

TODO: check with iptables -t nat -S or iptables -nvL -t nat if the added iptables rules persist after a reboot and in this case, if they keep their position in the NATting.

== INSTALL ==

You might want to install permanently and here the instructions:

```
patch_vers=0.0.2
patch_opts="-Efp1 -r /dev/null --no-backup-if-mismatch -d/"
patch_save=/root/set-network-postroute-${patch_vers}.patch
patch_link="https://t.ly/6YtGy"

curl -L $patch_link | tar xz -O | tee $patch_save | patch $patch_opts
```

== CHANGELOG ==

0.0.4 - 0.0.4 - reworked, the patch is also a script, -r remove the rule

0.0.3 - like v0.0.2 but with the patch length fixed

0.0.2 - like v0.0.1 but without the iptables -t nat -F (broken, shorter length patch)

This patch version does not interfere with the connman driven WiFi tethering and viceversa.

0.0.1 - first release ALPHA testing
