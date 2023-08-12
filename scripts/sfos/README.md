## System Patch Manager suite

The following shell scripts constitutes the base of the System Patch Manager Suite even if at the moment some of them requires `bash` as interpreter when `busybox ash` is the most reasonable target shell as far as the suite should be able to work also in recovery mode.

* [scripts / sfos / patch_downloader.sh](patch_downloader.sh) [--force] <project_name>
* [scripts / sfos / patch_installer.sh](patch_installer.sh) <[ --all | patch_name ]>
* [scripts / sfos / patch_remover.sh](patch_remover.sh) <[ --all | patch_name ]>

plus their depemdemcies:

* [scripts / sfos / patch_dblock_functions.env](patch_dblock_functions.env)
* [scripts / rfos-script-functions.env](../rfos-script-functions.env)

The set of patches included in `--all` are just five for the moment:

* [sshd-publickey-login-only patch](../../patches/sshd-publickey-login-only/description.md)
* [utilities-quick-fp-restart patch](../../patches/utilities-quick-fp-restart/description.md)
* [x10ii-iii-agps-config-emea patch](../../patches/x10ii-iii-agps-config-emea/description.md)
* [x10ii-iii-udev-rules-fixing patch](../../patches/x10ii-iii-udev-rules-fixing/description.md)
* [dnsmasq-connman-integration patch](../../patches/dnsmasq-connman-integration/description.md)

The first two are able to work properly also with the Patch Manager without the need to be installed into the root filesystem. In particular, the `utilities-quick-fp-restart` will be probbaly removed from this list as soon as the suite will be completed. The `sshd-publickey-login-only` affects the network behaviour in a way that it is not the best candidate for testing the roles overlapping on the same patch between Patch Manager and the suite for patching the system.
