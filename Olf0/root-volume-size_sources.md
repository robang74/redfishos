- Source: https://github.com/mer-hybris/hybris-initrd/blob/master/etc/sysconfig/init
- Part of project: https://github.com/mer-hybris/hybris-initrd/
- See also: https://github.com/gemian/gemian/wiki/SailfishLVM
- Original source of this idiocy (Jolla loves to shoot themselves in the foot, regularly and repeatedly):<br/>
  https://github.com/mer-hybris/hybris-initrd/commit/cdfcdb141a37c486365770bd9b5e0e77a9fbe264
- Not merged branch 4gb-root-size: https://github.com/mer-hybris/hybris-initrd/blob/4gb-root-size/etc/sysconfig/init<br/>
  This basically just reverts the former "idiocy commit".
- Finally resolved in a more complicated and intransparent manner by https://github.com/mer-hybris/hybris-initrd/pull/49<br/>
  See https://github.com/mer-hybris/hybris-initrd/blob/master/droid-hal-device-img-boot.inc<br/>
  and https://github.com/mer-hybris/hybris-initrd/commit/de33c73c758fbf53942e941c752c0a927c6efc2c<br/>
  but where is `@LVM_ROOT_PART_SIZE@` coming (i.e., evaluated) from?
- I think I finally (2022) found the mechanism introduced for this, which is described by these two commits:
  - [[sysconf] Transfer variable root_lvm_size to external settings. Contributes to JB#50662 by AndreySV · Pull Request #42 · mer-hybris/hybris-initrd · GitHub](https://github.com/mer-hybris/hybris-initrd/pull/42/files)
  - [[initrd] Pass device-specific environment variables to initrd. JB#54875 · mer-hybris/hybris-initrd@dc15604 · GitHub](https://github.com/mer-hybris/hybris-initrd/commit/dc1560442f2e906887d0ed1ea84ec22f7137ec9d)
