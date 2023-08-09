In some cases, the tethering via WiFi stops to deliver the DHCP service, and the reason is related to the `/etc/udhcpd.conf` file, which is replaced by usb-moded with a link pointing to a file in the temporary folder `/run/usb-moded/udhcpd.conf`. The quickest solution is to create a proper file with another name and instruct the `udhcpd` daemon to load the new `/etc/udhcpd.tether` instead of the default one. Moreover, it includes into `connman` firewall rules among the DHCP clients also the DHCP servers to be accepted in input.

== CHANGELOG ==

0.0.3 - udhcpd.service restarts always and waits for the interface to come up. Using systemctl for re/start requires --no-block.

0.0.2 - like v0.0.1 but includes the DHCP server rule for connman firewall configuration.

0.0.1 - create the new /etc/udhcpd.tether and update accordingly the udhcpd service file.
