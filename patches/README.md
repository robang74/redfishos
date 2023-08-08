## Patches for RedFish OS

This is a list of patches developed to evaluate the potential of `Patch Manager` and how it works.

* **dnsmasq connman integration**: [description](dnsmasq-connman-integration/description.md), patch [v0.1.2](dnsmasq-connman-integration/0.1.2-unified_diff.patch) (system)

    The dnsmasq conflicts with connman because both have their own business with port 53 and /etc/resolv.conf. Therefore, a full integration between these two services is required. 
  
* **fastboot usb3fix script**: [description](fastboot-usb3fix-script/description.md), patch [v0.0.3](fastboot-usb3fix-script/0.0.3-unified_diff.patch) (pcos)

    Provides a script for laptop/PC which aims to solve the USB problems during the flashing procedure.
  
* **set network postroute**: [description](set-network-postroute/description.md), patch [v0.0.2](set-network-postroute/0.0.2-unified_diff.patch) (sfos)

    Provides a shell script for configuring the developer mode for tethering the internet connection.
  
* **sfos ssh connect env**: [description](sfos-ssh-connect-env/description.md), patch [v0.0.5](sfos-ssh-connect-env/0.0.5-unified_diff.patch) (pcos)

    Provides a script for laptop/PC which aims to quickly connect with the SFOS via SSH over the fastest interface available.
  
* **sshd publickey login only**: [description](sshd-publickey-login-only/description.md), patch [v0.0.4](sshd-publickey-login-only/0.0.4-unified_diff.patch) (hybrid)

    Provides a system configuration that allows a safe root login via SSH without using any password.

* **udhcpd tether config fixing**: [description](udhcpd-tether-config-fixing/description.md), patch [v0.0.2](udhcpd-tether-config-fixing/0.0.2-unified_diff.patch) (system)

    Creates /etc/udhcpd.tether and update accordingly the udhcpd service file to provide DHCP service.

* **utilities quick fp restart**: [description](utilities-quick-fp-restart/description.md), patch [v0.0.4](utilities-quick-fp-restart/0.0.4-unified_diff.patch) (hybrid)

    The fingerprint reader service restart script has a 3s sleep which it does not seem useful, anymore.
 
* **x10 ii/i agps config emea**: [description](x10ii-iii-agps-config-emea/description.md), patch [v0.2.9](x10ii-iii-agps-config-emea/0.2.9-unified_diff.patch) (system)

    Provides a system patch for configuring the A/GPS hardware sub-module.

* **x10 ii/i udev rules fixing**: [description](x10ii-iii-udev-rules-fixing/description.md), patch [v0.0.2](x10ii-iii-udev-rules-fixing/0.0.2-unified_diff.patch) (system)

    Provides a system configuration to fix some bugs about the udev service.
 
* **zram swap resize script**: [description](zram-swap-resize-script/description.md), patch [v0.0.9](zram-swap-resize-script/0.0.9-unified_diff.patch) (sfos)

    Provides a shell script to resize the zRAM and to off-loading it to free memory from sleeping in background apps.

For more information about `Patch Manager`, check out this [analysis](../forum/knowhow/system-patch-manager-p1.md) about its shortcomings and future improvements.

## System patches

In order to apply patches to the system a special header has been designed

* [patch_system_header.prod.txt](patch_system_header.prod.txt)

* [patch_system_header.test.txt](patch_system_header.test.txt)

The second one is for testing only, while the first is a general example to use.
