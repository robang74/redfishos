## About rescue package

Centos 8 binary RPMs repository:

* https://vault.centos.org/centos/8/BaseOS/aarch64/os/Packages/

    * libattr-2.4.48-3.el8.aarch64.rpm
    * patch-2.7.6-11.el8.aarch64.rpm
    * rsync-3.1.3-12.el8.aarch64.rpm
    * pigz-2.4-4.el8.aarch64.rpm

Just the essential packaged into a gzip tarball:

    * patch-rsync-pigz.tar.gz

to explode directly on the root filesystem preferarbly in /usr/local

`tar -k xvzf /tmp/patch-rsync-pigz.tar.gz -C /` 

or into the volatile /tmp exporting this variables:

```
export PATH=$PATH:/usr/local/bin 
export LD_LIBRARY_PATH=/tmp/usr/local/lib64:$LD_LIBRARY_PATH
```

to set properly the shell enviroment for using the imported binayries in /tmp.
