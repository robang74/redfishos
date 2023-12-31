Investigating the degraded system state in SFOS 4.5.0.19, it was clear that dnsmasq conflicts with connman because both have their own business with port 53 and /etc/resolv.conf. Therefore, a full integration between these two services is required.

ATTENTION: the Patch Manager is not the right tool for this kind of patches and the dnsmasq and connman RPMs should be fixed, instead. Follow the manual installation procedure rather than relying on Patch Manger.

In order to need this patch you wants to install and run the dnsmasq by Simon Kelley before from the Chum market. This patch ignores the DNS proposed by connman (usually your network operator default) and - since v0.0.8 - enables four IPv4 DNS nameservers from adguard-dns.io and quad9.net which offer a filtered-DNS to block advertising and malicious threats. Previous versions were relying on Cloudflare DNS, instead.

== PACKAGES INVOLVED ==

- SailFish Utilities app for restarting the network (optional)
- connman-1.32+git194-1.19.1.jolla.aarch64 (pre-installed)
- dnsmasq-2.86-1.4.1.jolla.aarch64 (to install)

== STEPS TO INSTALL ==

The link in these instructions refers to the last version of this patch, change the $version as per your needs.

In the following these definitions are set:

patch_vers=0.0.9
patch_file="/tmp/unified_diff.patch"
patch_opts="-Efp1 -r /dev/null --no-backup-if-mismatch -d/"
patch_link="https://t.ly/qqg3y"

0. install this patch but do not apply it, just to receive updates notifications
1. download the patch: curl -L $patch_link | tar xz -C /tmp
2. install dnsmasq package: pkcon install -y dnsmasq
3. check the patch: patch --dry-run $patch_opts -i $patch_file
4. manually install the patch: patch $patch_opts -i $patch_file
5. save the patch: mv -f $patch_file /etc/dnsmasq-connman-${patch_vers}.patch
6. clean the dnsmasq folder: rm -f /etc/dnsmasq.d/*.rej /etc/dnsmasq.d/*.orig
7. systemd configs reload: systemctl daemon-reload && systemctl reload connman
8. services restart: nohup systemctl restart dnsmasq connman >/dev/null 2>&1 &
9. check the services status: systemctl --no-pager status dnsmasq connman

At this point your networking will go down and up but not the wifi tethering but the wifi, instead (SFOS 4.5.019 bug).

== STEPS TO RESCUE ==

If you have installed a different version of the patch, you need to uninstall it before applying the new version (cfr. uninstall procedure). Instead, if you experiment problems with the current patch version then you can try with the hard way:

0. grep +++ $patch_file
1. patch -R $patch_opts -i $patch_file
2. patch $patch_opts -i $patch_file

If enforcing the patch does not rescue the system then vi and nano are your friends and the grep shown you the files to deal with.

== STEPS FOR TESTING ==

0. pkcon install -y tcpdump bind-utils
1. tcpdump -vnnS port 53 -i any &
2. timeout 1 curl telnet://127.0.0.1:53 # some tcpdump output will be printed
3. nslookup pippo.it >/dev/null # should be one of nameservers in the patch
4. nslookup pippo.it >/dev/null # should be 127.0.0.1 (cached hostname)
5. killall tcpdump

== STEPS TO UNINSTALL ==

patch_file="/etc/dnsmasq-connman-${patch_vers}.patch"

0. patch check: patch -R --dry-run $patch_opts -i $patch_file
1. patch uninstall: patch -R $patch_opts -i $patch_file
2. remove the dnsmasq package: pkcon remove -y dnsmasq
3. set back the resolv.conf link: ln -sf /run/connman/resolv.conf /etc/resolv.conf
4. follow the install procedure from step #6

== SERVICES RESTART ==

- follow the install procedure from step #7

== CONFLICT ANALYSIS ==

Available at this link: https://tinyurl.com/26lmx6sn

== CHANGELOG ==

0.1.4 - like v0.1.0 but with the system patch header with '-dnsmasq' and does not patch `/etc/dnsmasq.conf`.

The minus in front of the service name stops and disables the service at the patch removal time.

0.1.3 - deleted.

0.1.2 - like v0.1.0 but with the system patch header.

0.1.1 - like v0.1.0 but with a full system patch header for testing

0.1.0 - like 0.0.9 but with the system patch header

0.0.9 - like v0.0.8 but without strict order DNS querying

0.0.8 - like v0.0.7 but with Quad9 + AdGuard alternated DNS nameservers

The best choice is alternating two coherent DNS services together - for reliability - and using a caching system configured for leveraging a large cache to gain speed, privacy and safety. This has been achieved by alternating AdGuard and Quad9 ad-blocking and safe-filtered DNS.

-> AdGuard: https://adguard-dns.io/en/public-dns.html
-> Quad9; https://www.quad9.net

0.0.7 - like v0.0.6 but without 0.0.0.0 because deprecated by IANA standards

About the use of 0.0.0.0 as a black-hole DNS, here in this link below some information:

-> https://serverfault.com/questions/830930/dns-record-contains-0-0-0-0-address

0.0.6 - connman after patchmanager and dnsmasq before connman (deprecated)

Because this patch is not applied unless PM will complete its job, sometimes the connman and dnsmasq services start before their .service files have been patched and therefore the system will not be able to resolve the domain names. Moreover, the network restart from SailFish Utilities cannot solve the issue and also rebooting might not solve it but usually does unless systemd is far away from the factory configuration.

0.0.5 - bind-dynamics replaced bind-interfaces because rndis0 is not always present (obsolete)

Introduced in v0.0.4 the support for waydroid (bind-interfaces) makes the dnsmasq fail to raise when an interface (e.g. nsdis0) is missing. While bind-dynamic enables a network mode which is a hybrid between bind-interfaces and the default: dnsmasq binds the address of individual interfaces, allowing multiple dnsmasq instances, but if a new interfaces or addresses appear, it automatically listens on those.

