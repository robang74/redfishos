This patch is specifically released for Sony Xperia 10 II & III and European users (EMEA).

ATTENTION: the Patch Manager is not the right tool for this kind of patch because the modem/GPS and ofono will read the config before it has been patched. Follow the manual installation procedure, instead.

== STEPS TO INSTALL ==

In the following these definitions are set:

patch_vers=0.2.2
patch_file="/tmp/unified_diff.patch"
patch_opts="-Efp1 -r /dev/null --no-backup-if-mismatch -d/"
patch_link="https://tinyurl.com/23rotyqs"

0. install this patch but do not apply it, just to receive updates notifications
1. download the patch: curl -L $patch_link | tar xz -C /tmp
2. install gpstoggle package: pkcon install -y gpstoggle (optional)
3. check the patch --dry-run $patch_opts -i $patch_file
4. manually install the patch: patch $patch_opts -i $patch_file
5. save the patch: mv -f $patch_file /etc/agps-config-${patch_vers}.patch
6. ofono restart: systemctl daemon-reload; nohup systemctl restart ofono >/dev/null 2>&1 &

After the installation (a reboot is suggested), the A-GPS will be able to work indoors also and with the 4G mobile connection, thanks to SUPL v2. Moreover, it adopts the HTTPS encrypted protocol to download the XTRA data for configuring the LTE/GPS modem in a secure way. It query the Qualcomm world wide network of SUPL hosts. Thus, the GPS subsystem at SFOS level will be completely independent from Google services.

WARNING: filesystem overlay tricks too old versions of filesystem utils like cp and tar but possibly also prevents that modem/GPS can be correctly configured. Check this bug report https://t.ly/omO0 for more information.

== UNINSTALL & RESCUE ==

How to deal with the installed patch in all others cases, please check

-> https://tinyurl.com/249c72w8

The instructions have been provided for another patch but are similar.

== XTRA AND SSL/TLS ===

The XTRA v3 comes with the full support for receiving all constellations: GPS+GLONASS+BeiDou+Galileo. For synchronizing the modem clock, it uses some European NTP servers. Moreover the modem/GPS injects the exact time/data into the system clock to keep it in sync and stable about drifting.

The CA certificates can be updated with the command line devel-su update-ca-trust executed by root. However, for supl.izatcloud.net are not necessary because the Qualcomm modem is supposed to have its own CA certificates for Qualcomm SUPL hosts services. The TLS is available on both ports and it is mandatory:

~$ openssl s_client -connect supl.izatcloud.net:7275 -state
SSL_connect:SSLv3/TLS write client hello

~$ openssl s_client -connect supl.izatcloud.net:7275 -no_tls1_3 -no_tls1_2 -no_tls1_1 -no_tls1 -state
SSL3 alert write:fatal:protocol version
SSL_connect:error in error

Repeat the tests with port 7276, also.

== PERFORMANCES ==

The cold start, immediately after a smartphone reboot, in standard conditions with a 4G data connection with no any VPN active nor other running services that can influence the network stack, it takes near 30s to reach 30m horizontal accuracy in an indoor fix, less than 15s for the cell area identification (9km range in my case). The first 15s are related to CAcerts injection and almanac update from 4G connection. With an active WiFi tethering connection and a free UDP VPN IPv4-only tunneling, it takes more: near 1m for fixing the point under 100m of h-accuracy, 2m for 15m h-accuracy using 6 satellites of 41 in view.

To halve the cold start time - since patch v.0.1.6 - these CAcerts are included in the patch:

- CyberTrust Root CA used by Google SUPL service (https://pki.goog/roots.pem)
- ISRGRootX1 used by Let's Encrypt service (https://letsencrypt.org/certs/isrgrootx1.pem)

In this way the size of the certificates fell down from 1026Kb (system) to 76Kb (patch).

== SCREENSHOTS ==

Both taken indoors, the first with GPSinfo (native app) and the other with GPStest (android app).

== CHANGELOG ==

0.2.9 - like v0.2.2 but with the system patch header.

0.2.2 - like v0.2.0 but with gps.conf miniaturised to the original size

Because the WARNING #2 explained into the description, the gps.conf size has been reported to the original file one. In the source package you will find the gps.conf.sh used to miniaturise it and the gps.conf.full with all the comments that describes the various options. Follow the instructions given into description!

0.2.0 - like the v0.1.9 but with LPP_PROFILE tuned for LTE (4G) localisation services

0.1.9 - like v0.1.7 but without 5G support but with a real cacerts_gps folder and IPv4-only SUPL services

Support for 5G could mess-up those phone which are 4G-only or equipped with a SIM 4G-resticted. Resticting the SUPL services to work with IPv4-only allows those limited their SIM APN to IPv4-only, mainly for preventing IPv6 data leaks from free VPNs.

0.1.8 - like v0.1.7 but without 5G support and proxy app string setting but with a real cacerts_gps folder (alternatives: v0.1.7 or v0.1.9)

Support for 5G could mess-up those phone which are 4G-only or equipped with a SIM 4G-resticted. Commenting the string for the prox app makes this patch an alternative of v0.1.9.

0.1.7 - like 0.1.6 but zeroed the GPS_LOCK which allows the GPS to receive signals and being ready to fix the point (alternative v0.1.6)

The bit mask configures how GPS functionalities should be locked when user turns off GPS on Settings: bit 0x1 for MO GPS, sbit 0x2 for NI GPS, default: both MO and NI locked for maximal privacy. Actual configuration GPS_LOCK = 0, both unlocked when GPS is off in Settings.

0.1.6 - like v0.1.5 but faster because injects just 76Kb of CAcerts

0.1.5 - 5G + autocheck for XTRA version and as many custom settings as possible (obsolete)

The SFOS versions 4.4 and 4.5 compatibility added, let me know about. The IPv4-only and XTRA throttling have been disabled because these 2 aspects will be investigated later. The XTRA autocheck has been enabled because GPS reboot with v2. The alternative version offers a set of customised features which might perform better or worse depending also on the device model (X10II, X10III, XA2, etc.).

0.1.2 - autocheck for XTRA version and as many defaults settings as possible (obsolete)

The SFOS versions 4.4 and 4.5 compatibility added, let me know about. The IPv4-only and XTRA throttling have been disabled because these 2 aspects will be investigated later. The XTRA autocheck has been enabled because GPS reboot with v2. The alternative version offers a set of customised features which might perform better or worse depending also on the device model (X10II, X10III, XA2, etc.).

0.1.1 - based on v0.1.0 but enables as many features as possible (obsolete)

0.1.0 - check for XTRA v3 and left as much as possible to modem/GPS discrection + no throttle (obsolete)

0.0.9 - XTRA: global almanac + no throttle (broken)

The XTRA_INTERVAL = 86400 does not work as expected, broken.

0.0.8 - bugfix: typo in supl.izatcloud.net + XTRA throttle (broken)

The XTRA_INTERVAL = 86400 does not work as expected, broken.

The GPS engine is not limited about energy consumption thus it works at his best also when SFOS is in energy saving mode. However, its load has been limited by XTRA_THROTTLE_ENABLED = 1 because it is able to lag the SFOS, in particular the GUI and some apps might also crash. After all, a subsystem should not impact on the whole system otherwise it is a source of DoS.

0.0.7 - query the Qualcomm SUPL host + XTRA engine throttle (broken)

0.0.6 - multiple CAcerts PATHs (obsolete)

0.0.4 - bugfix in XTRA, it was loading the v3 without all constellations (obsolete)

0.0.3 - supl.google.com with its cacerts for TLS de/encryption (obsolete)

0.0.2 - XTRA v3 with GPS+GLONASS+BeiDou+Galileo (obsolete)

0.0.1 - first release (obsolete)
