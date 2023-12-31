This patch is for your laptop/PC and contains a bash environment that defines some function useful to quickly and easily connect to your SFOS device to avoid you having to type the user and the IP address every time. Moreover, automatically find the quickest network path among those available if there are more than one.

== PRE-REQUISITES ==

This patch requires to having installed on your SFOS device the "SSHd public-key login only" patch:

-> https://coderus.openrepos.net/pm2/project/sshd-publickey-login-only

Optionally installing on your SFOS device also the USB "tethering POSTROUTE setting" patch allows you to quickly and easily set the USB tethering for the developer mode.

== INSTALLATION ==

Save this file in /usr/bin/sfos-ssh-connect.env as text file not as a script and add this line to the end of your ~/.bashrc for the future bash instances:

> source /usr/bin/sfos-ssh-connect.env

and / or manually load into the current bash instance in the same way above. Another way to install this patch on your pcos is the following:

$ curl -sL https://t.ly/npLkn | tar xz -O | sudo patch -p1 -d /

It downloads the archive, expands it and applies the patch creating the script in /usr/bin.

== USAGE ==

* tfish [command] - to use recovery telnet via USB on its default IPv4
* rfish [command] - to use recovery SSH via USB on its default IPv4
* ufish [command] - to use SSH via USB connection on its default IPv4
* wfish [command] - to use SSH via WiFi connection on its default IPv4
* afish [command] - to use the fast route IPv4 for SSH, updates IPv4 default
* sfish [command] - to use the previous route for SSH or it finds the fastest

extras:

* afish getip - set the fastest route IPv4 for establishing the SSH connection
* ufish devtether - enable on the SFOS the tethering via USB in developer mode

== CHANGELOG ==

0.0.4 - license changed from MIT to GPLv2

0.0.3 - extra commands without the underscore, more handy (deleted)

0.0.2 - bugfixed the tfish() for telnet the recovery image (deleted)

0.0.1 - first release (deleted)
