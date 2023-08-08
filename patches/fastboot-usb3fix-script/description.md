This is NOT for SailFish OS but for GNU/Linux users that wish use fastboot/flash.sh to install SFOS into a mobile device but encountered the USB v3.x fastboot issue or the USB sleeping issue, both related to xhci_pci Linux driver.

This patch achieves the following goals:

- your USB tethering will be much more reliable and it will no go to sleep
- a SSH session via USB will be recovered after a short-time network down
- the flash.sh and fastboot will work as supposed to be

On my USB v3.x-only sleeping ports laptop, it solved the problem completely.

== INSTALL ==

A way is to download the tarball archive and extract the content and rename it, with a single line command execution:

$ curl -L https://t.ly/D3hg9 | tar xvz && mv -f unified_diff.patch fastboot_usb3fix.sh

The patch can be applied in the traditional way or it can also be executed directly because the patch header contains the shell script.

== USAGE ==

sudo ./fastboot_usb3fix.sh 2
sudo /bin/bash flash.sh --force
sudo ./fastboot_usb3fix.sh 3

Check the USB PROBLEMS section in the Quick Start Guide:

-> https://tinyurl.com/27un5juo

== PERFORMANCE ==

Five seconds to set the USB v2.0-only mode and 3 minutes to flash the Xperia 10 II smartphone on a laptop USB v3.x-only (xhcii_pci):

root@pcos# time ./fastboot_usb3fix.sh 2

Sony Ericsson Mobile USB2 mode
USB devices unbinding...
USB hub/ports setting...
USB devices rebinding...
USB power control...
device found in fastboot mode
set USB2 power always on mode

real 0m5.489s
user 0m0.052s
sys  0m0.036s

root@pcos# time bash flash.sh --force
Flash utility v1.2
Detected Linux
Searching device to flash..
Found xxxx, serial:xxxx, baseband:xxxx, bootloader:xxxx
Found matching device with serial xxxx
Fastboot command: fastboot -s xxxx
Ignoring md5sum errors (--force)
>> fastboot -s xxxx getvar secure
<< secure: no

[...]
Flashing completed.
[...]

real 2m50.222s
user 0m3.304s
sys 0m9.674s

== CHANGELOG ==

0.0.3 - changed the license from MIT to GPLv2

0.0.2 - find the connected smartphone and set its USB parameters (deleted)

0.0.1 - first release (deleted)

