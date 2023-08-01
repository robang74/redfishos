### 1st-boot setup after flashing

> :warning: **WARNING NOTE**
> 
> These `adaptation0`, `aliendalvik`, `sailfish-eas`, `xt9` repositories are enabled by default, but it is wrong because they can be refreshed only when the device has a Jolla account. Otherwise, a relative long timeout for each of them keeps the refresh procedure stuck. Therefore, the Jolla account creation and deletion actions must take care of enabling and disabling them, which must be set as disabled by default. Until this fix will be implemented and provided this script deal with this aspect enabling or disabling those repositories.

This script provides a *standard* system configuration immediately after the first boot, after the flashing procedure:

* [pcos / sfos-first-setup.sh](sfos-first-setup.sh) is now available for testing by advanced end-user

* [pcos / sfos-ssh-connect.env](sfos-ssh-connect.env) - is the bash environment required by the script above for SSH automatic connection.

* [sfos-ssh-connect-env patch](https://coderus.openrepos.net/pm2/project/sfos-ssh-connect-env) - it is the script that enable the quick & safe password-less root-login via SSH, a system setup-up required by the environment above. 

The *standard* term here means about a starting point from which it is supposed everyone wishes to debug and fix the SFOS is put on working for quick results comparison and their [reproducibility](https://www.ncbi.nlm.nih.gov/books/NBK547546/#_sec_ch3_2_). Plus, it adds those command-line tools like `pigz` and `rsync` that are useful in doing advanced root filesystem and users home folders backups.
