This patch aim to fix some `udev` rules that creates a lot of system log messages

#### INSTALLATION ####

```
patch_vers=0.0.1
patch_link='https://t.ly/v8Ar9'
patch_save='/root/set-network-postroute-${patch_vers}.patch'
patch_opts='-Efp1 -r /dev/null --no-backup-if-mismatch -d/'

curl -L $patch_link | tar xz -O | tee $patch_save | patch $patch_opts
```

#### CHANGELOG ####

0.0.2 - like the v0.0.1 but with the system patch header.
0.0.1 - first release, BETA TESTING.
