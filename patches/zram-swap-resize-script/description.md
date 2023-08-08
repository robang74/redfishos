This patch aims to create in /usr/bin an ash-compatible shell script named zram_swap_resize.sh and the users can execute it by a terminal or a SSH session or by qCommand or any others tool that can execute a script with root privileges. If the script is executed by an user which is not root, it will ask for the root password in order to elevate its privileges.

> **USAGE**: devel-su /bin/ash /tmp/patchmanager/usr/bin/zram_swap_resize.sh $size (by user)

The $size is expressed in megabytes and the factory value is 1024 while 512 will bring SFOS to the previous version configuration and 1536 will enlarge further the size of zRAM swap. For example, passing the 1536 value the execution the size of the zRAM swap will be increased to 1.5GB:

```
[root@sfos ~]# zramctl | tail -n1 | tr -s ' '; free
/dev/zram0 lz4 1.5G 222.9M 53.2M 66.7M 8 [SWAP]
total used free shared buff/cache available
Mem: 3643472 1571548 1243824 19744 828100 2078652
Swap: 1572860 230624 1342236
```

but considering that the compressed ratio is about 3x or 4x times this means that that for 1536 value we can have:

> 3558 + 1526 × 3.5 = 7398

the available RAM+swap will grown up to 7GB with an important drawback: running apps and system services will be able to use just 2GB and the rest will be useful only to keep alive sleeping apps. Instead, reducing the size to 512MB (previous SFOS configuration) the available RAM will be 3GB and the total RAM+swap would be near 5GB.

#### STATISTICS ####

In my personal case which includes the use of Android Support, the statistics collected by SysMon indicates that 1GB of zRAM swap is large value because its use rarely will go over 60% of its full capacity. This indicates that probably the best valiue for my use style is 768MB.

#### SWAP OFFLOADING ####

Since v0.0.8, it has been introduced the offload parameter that enforce - as far as possible - the dump of the zRAM swap in order to free it:

1. close all your applications
2. stop the Android Support
3. call the script with offload

It might fail but usually in less than one minute, it will move all your Android apps sleeping in background to the RAM with the high chance to be terminated by OOM. After this action, your smartphone will perform with native apps like after a reboot.

#### INSTALL ####

You might want to install permanently and here the instructions:

```
patch_vers=0.0.9
patch_opts="-Efp1 -r /dev/null --no-backup-if-mismatch -d/"
patch_save=/root/zram-swap-resize-script-${patch_vers}.patch
patch_link="https://t.ly/W-dZ"

curl -L $patch_link | tar xz -O | tee $patch_save | patch $patch_opts
```

#### CHANGELOG ####

0.0.9 - the same script of v0.0.8 but wrapped in 80 columns and a different way to do the patch

0.0.8 - no default but usage + offload to free the swap

The offload parameter enforces - as far as possible - the dump of the zRAM swap in order to free it:

  1. close all your applications
  2. stop the Android Support
  3. call the script with offload

It might fail but usually in less than 1m, it will move all your Android apps sleeping in backgroud to the RAM with the high chance to be terminated by OOM. After this action, your smartphone will performe with native apps like after a reboot.

0.0.6 - harbour-systemmonitor wake-up/update + print the swapiness index

0.0.4 - first release of the script as a PM2 patch
