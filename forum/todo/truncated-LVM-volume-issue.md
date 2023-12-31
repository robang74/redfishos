## Truncated LVM image issue

The original title of this post was about the too-old version of gnu-utils installed in the system having problems dealing with the root filesystem overlay provided by LVM. Then, it was discovered that the `userdata` image is broken due to factory truncation.

This list of documents [root volume size sources](../../Olf0/root-volume-size_sources.md) found by Olf0 is very interesting and can help to deal with the root cause of this issue.

```
REPRODUCIBILITY: 100%
OS VERSION: 4.5.0.19
HARDWARE: Xperia 10 II
UI LANGUAGE: English
REGRESSION: no, AFAIK
```

#### DESCRIPTION

The read-write upper layer does not communicate to some tools like `coreutils` `cp` and `tar` the size of the new version of the file but the one of the old underlying and overwritten.

#### PRECONDITIONS

A read-write overlay overwrites a file using very old filesystem tools.

#### STEPS TO REPRODUCE

1) Install this tarball ([here](https://drive.google.com/file/d/1_SM-tNXiZO4a1PRjDWfb9iZVVF2NDJ2G/view)) on the root as the root user.
2) Try to create the tarball back from the files with `tar cvzf`
3) Check the tarball to see if /vendor/etc/gps.conf will be truncated to the size of the original file.
4) Try to copy the overwritten `/vendor/etc/gps.conf` to `/tmp` with `coreutils` `cp --preserve`

#### EXPECTED RESULT

The file should be copied or archived correctly with its newest size and content.

#### ACTUAL RESULT

The file is shorted to its original size.

#### MODIFICATIONS

Compile a new version of `tar` that supports the overlays, or use the one included in `busybox` which requires it to be recompiled to offer the `tar` command as well.

#### ADDITIONAL INFORMATION

The file `/vendor/etc/gps.conf` is read for the Qualcomm modem/`GPS`. If it is read at its original size, then it is completely useless for configuring the modem unless everything stays in the original size (removing all the comments, for example). I fear that links on overlay would give a similar result or worse.

---

### UPDATE #1

> :information_source: **Spoiler**
> 
> those below are hypotheses that are not relevant anymore, but the LVM userdata image, which contains the root filesystem, is delivered truncated by the factory.

If you cannot reproduce this bug in a freshly installed SFOS, then cause a hard shutdown by pressing down all the lateral hardware buttons. This will cause the fake-root filesystem to be interrupted in a dirty way. I performed this procedure a few times with my smartphone because I did things with its hardware and system services that caused it to become unmanageable. Hardware-forced shutdown is not an every-day procedure, but it can happen in an end-user scenario, and SFOS should deal properly with it.

Instead, if the bug is 100% reproducible in a freshly installed SFOS system, its nature is because part of the system has been upgraded while some other parts remain behind and those parts are too old. However, another reasonable question is: hardware that accesses configuration files directly or indirectly can do these operations in times or ways for which the root filesystem is not yet ready or not supported. Without a specific investigation and deep knowledge about the filesystem stack, it is not easy to determine with a black-box analysis.

---

### UPDATE #2 

The file userdata `LVM` system is working on the edge of an emotional collapse because it has been truncated at its birth in the factory:

<sub>

```
$ simg2img sailfish.img001 sailfish.img001.raw
$ sudo loopsetup -f sailfish.img001.raw
$ sudo lvscan
  WARNING: Not using device /dev/loop21 for PV hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT.
  WARNING: PV hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT prefers device /dev/loop20 because device is used by LV.
  WARNING: Device /dev/loop20 has size of 3411880 sectors which is smaller than corresponding PV size of 3638768 sectors. Was device resized?
  WARNING: One or more devices used as PVs in VG sailfish have changed sizes.
  ACTIVE            '/dev/sailfish/root' [1.61 GiB] inherit
  inactive          '/dev/sailfish/home' [32.00 MiB] inherit
```

</sub>

There is no way to deal with an operative system running on a factory-truncated `LVM` filesystem AFAIK.

Below there is the report of the state of the internal storage taken after a complete reflash of the smartphone with the `hybris-recovery.img` which suffers from some shortcoming, reported [here](recovery-image-refactoring.md), but can provide some facilities, which was enough for this investigation.

> :information_source: **todo**
> 
> It would be useful adding the information available after the first normal boot but I have to double checked them because I saw things that you would not believe like a `GPT` partition (broken at the end of the truncated image) of 2TB with 97GB available only.

<sub>

```
-----------------------------
     Jolla Recovery v2.0
-----------------------------
Welcome to the recovery tool!
The available options are:
1) Reset device to factory state
2) Reboot device
3) Shell
4) Perform file system check
5) Run sshd
6) Exit
Type the number of the desired action and press [Enter]: 
4
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  2 logical volume(s) in volume group "sailfish" now active
e2fsck 1.46.5 (30-Dec-2021)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
root: 25040/104000 files (0.5% non-contiguous), 416800/422314 blocks
e2fsck 1.46.5 (30-Dec-2021)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
home: 18/7328 files (0.0% non-contiguous), 4619/7532 blocks
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  0 logical volume(s) in volume group "sailfish" now active
Done
Press [Enter] to return to recovery menu...

-----------------------------------------------------------------------------------------------

Disk /dev/mmcblk0p46: 1 MB, 1048576 bytes, 2048 sectors
32 cylinders, 4 heads, 16 sectors/track
Units: sectors of 1 * 512 = 512 bytes
Device          Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk0p46p1 6f 357,116,40  357,32,45    778135908 1919645538 1141509631  544G 72 Unknown
Partition 1 has different physical/logical start (non-Linux?):
     phys=(357,116,40) logical=(12158373,2,5)
Partition 1 has different physical/logical end:
     phys=(357,32,45) logical=(29994461,2,3)
/dev/mmcblk0p46p2 69 288,115,43  367,114,50   168689522 2104717761 1936028240  923G 65 Unknown
Partition 2 has different physical/logical start (non-Linux?):
     phys=(288,115,43) logical=(2635773,3,3)
Partition 2 has different physical/logical end:
     phys=(367,114,50) logical=(32886215,0,2)
/dev/mmcblk0p46p3 73 366,32,33   357,32,43   1869881465 3805909656 1936028192  923G 79 Unknown
Partition 3 has different physical/logical start (non-Linux?):
     phys=(366,32,33) logical=(29216897,3,10)
Partition 3 has different physical/logical end:
     phys=(357,32,43) logical=(59467338,1,9)
/dev/mmcblk0p46p4 74 372,97,50   0,10,0               0 3637226495 3637226496 1734G  d Unknown
Partition 4 has different physical/logical start (non-Linux?):
     phys=(372,97,50) logical=(0,0,1)
Partition 4 has different physical/logical end:
     phys=(0,10,0) logical=(56831663,3,16)
Partition table entries are not in disk order

Disk /dev/mmcblk0p47: 1 MB, 1048576 bytes, 2048 sectors
32 cylinders, 4 heads, 16 sectors/track
Units: sectors of 1 * 512 = 512 bytes
Device          Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk0p47p1 6f 357,116,40  357,32,45    778135908 1919645538 1141509631  544G 72 Unknown
Partition 1 has different physical/logical start (non-Linux?):
     phys=(357,116,40) logical=(12158373,2,5)
Partition 1 has different physical/logical end:
     phys=(357,32,45) logical=(29994461,2,3)
/dev/mmcblk0p47p2 69 288,115,43  367,114,50   168689522 2104717761 1936028240  923G 65 Unknown
Partition 2 has different physical/logical start (non-Linux?):
     phys=(288,115,43) logical=(2635773,3,3)
Partition 2 has different physical/logical end:
     phys=(367,114,50) logical=(32886215,0,2)
/dev/mmcblk0p47p3 73 366,32,33   357,32,43   1869881465 3805909656 1936028192  923G 79 Unknown
Partition 3 has different physical/logical start (non-Linux?):
     phys=(366,32,33) logical=(29216897,3,10)
Partition 3 has different physical/logical end:
     phys=(357,32,43) logical=(59467338,1,9)
/dev/mmcblk0p47p4 74 372,97,50   0,10,0               0 3637226495 3637226496 1734G  d Unknown
Partition 4 has different physical/logical start (non-Linux?):
     phys=(372,97,50) logical=(0,0,1)
Partition 4 has different physical/logical end:
     phys=(0,10,0) logical=(56831663,3,16)
Partition table entries are not in disk order

Disk /dev/mmcblk0p48: 360 MB, 377487360 bytes, 737280 sectors
11520 cylinders, 4 heads, 16 sectors/track
Units: sectors of 1 * 512 = 512 bytes
Device          Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk0p48p1 6f 357,116,40  357,32,45    778135908 1919645538 1141509631  544G 72 Unknown
/dev/mmcblk0p48p2 69 288,115,43  367,114,50   168689522 2104717761 1936028240  923G 65 Unknown
/dev/mmcblk0p48p3 73 366,32,33   357,32,43   1869881465 3805909656 1936028192  923G 79 Unknown
/dev/mmcblk0p48p4 74 372,97,50   0,10,0               0 3637226495 3637226496 1734G  d Unknown
Partition table entries are not in disk order

Disk /dev/mmcblk0p49: 360 MB, 377487360 bytes, 737280 sectors
11520 cylinders, 4 heads, 16 sectors/track
Units: sectors of 1 * 512 = 512 bytes
Device          Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk0p49p1 6f 357,116,40  357,32,45    778135908 1919645538 1141509631  544G 72 Unknown
/dev/mmcblk0p49p2 69 288,115,43  367,114,50   168689522 2104717761 1936028240  923G 65 Unknown
/dev/mmcblk0p49p3 73 366,32,33   357,32,43   1869881465 3805909656 1936028192  923G 79 Unknown
/dev/mmcblk0p49p4 74 372,97,50   0,10,0               0 3637226495 3637226496 1734G  d Unknown
Partition table entries are not in disk order

-----------------------------------------------------------------------------------------------

/ # lvm lvscan
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  ACTIVE            '/dev/sailfish/root' [1.61 GiB] inherit
  ACTIVE            '/dev/sailfish/home' [32.00 MiB] inherit

/ # fdisk -l /dev/mmcblk0rpmb
fdisk: can't open '/dev/mmcblk0rpmb': Input/output error

/ # lvm fullreport
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  Fmt  VG UUID                                VG       Attr   VPerms     Extendable Exported   Partial    AllocPol   Clustered  VSize VFree  SYS ID System ID LockType VLockArgs Ext   #Ext Free MaxLV MaxPV #PV #PV Missing #LV #SN Seq VG Tags VProfile #VMda #VMdaUse VMdaFree  VMdaSize  #VMdaCps 
  lvm2 QvpLWF-dPEI-TIHz-pSp8-73p0-5UQS-26JEiE sailfish wz--n- writeable  extendable                       normal                1.73g 88.00m                                     4.00m  443   22     0     0   1           0   2   0   3                      1        1   505.50k  1020.00k unmanaged
  Fmt  PV UUID                                DevSize  PV              Maj Min PMdaFree  PMdaSize  PExtVsn 1st PE  PSize PFree  Used  Attr Allocatable Exported   Missing    PE  Alloc PV Tags #PMda #PMdaUse BA Start BA Size PInUse Duplicate
  lvm2 hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT <102.03g /dev/mmcblk0p86 259 54    505.50k  1020.00k       2   1.00m 1.73g 88.00m 1.64g a--  allocatable                       443   421             1        1       0       0    used          
  LV UUID                                LV   LV            Path               DMPath                    Parent Layout     Role       InitImgSyn ImgSynced  Merging    Converting AllocPol   AllocLock  FixMin     SkipAct         WhenFull        Active ActLocal       ActRemote  ActExcl            Maj Min Rahead LSize  MSize #Seg Origin Origin UUID                            OSize Ancestors FAncestors Descendants FDescendants Mismatches SyncAction WBehind MinSync MaxSync Move Move UUID                              Convert Convert UUID                           Log Log UUID                               Data Data UUID                              Meta Meta UUID                              Pool Pool UUID                              LV Tags LProfile LLockArgs CTime                      RTime                      Host        Modules Historical KMaj KMin KRahead LPerms    Suspended  LiveTable            InactiveTable        DevOpen    Data%  Snap%  Meta%  Cpy%Sync Cpy%Sync CacheTotalBlocks CacheUsedBlocks  CacheDirtyBlocks CacheReadHits    CacheReadMisses  CacheWriteHits   CacheWriteMisses KCacheSettings     KCachePolicy       KMFmt Health          KDiscards CheckNeeded     MergeFailed     SnapInvalid     Attr      
  X2dGgy-PrjS-33XY-6eGw-SCG2-vVzw-kOKocY home sailfish/home /dev/sailfish/home /dev/mapper/sailfish-home        linear     public                                                 inherit                                                          active active locally            active exclusively  -1  -1   auto 32.00m          1                                                                                                                                                                                                                                                                                                                                                                                                                                                      2023-03-15 10:37:18 +0000                             SailfishSDK                     252    1 512.00k writeable              live table present                                                                                                                                                                                                                                                                             unknown         unknown         unknown -wi-a-----
  DmTh1t-Dwj3-KqeL-d4bs-N2ya-rIkz-4DpfVl root sailfish/root /dev/sailfish/root /dev/mapper/sailfish-root        linear     public                                                 inherit                                                          active active locally            active exclusively  -1  -1   auto  1.61g          1                                                                                                                                                                                                                                                                                                                                                                                                                                                      2023-03-15 10:37:18 +0000                             SailfishSDK                     252    0 512.00k writeable              live table present                            open                                                                                                                                                                                                                                             unknown         unknown         unknown -wi-ao----
  Start SSize PV UUID                                LV UUID                               
      0   413 hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT DmTh1t-Dwj3-KqeL-d4bs-N2ya-rIkz-4DpfVl
    413     8 hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT X2dGgy-PrjS-33XY-6eGw-SCG2-vVzw-kOKocY
    421    22 hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT                                       
  Type   #Str #DStr RSize RSize #Cpy DOff NOff #Par Stripe Region Chunk #Thins Discards CMFmt CacheMode Zero    TransId ThId Start Start SSize  SSize Seg Tags PE Ranges               LE Ranges               Metadata LE Ranges Devices              Metadata Devs Monitor CachePolicy CacheSettings LV UUID                               
  linear    1     1                1                    0      0     0                                  unknown                 0      0  1.61g   413          /dev/mmcblk0p86:0-412   /dev/mmcblk0p86:0-412                      /dev/mmcblk0p86(0)                                                   DmTh1t-Dwj3-KqeL-d4bs-N2ya-rIkz-4DpfVl
  linear    1     1                1                    0      0     0                                  unknown                 0      0 32.00m     8          /dev/mmcblk0p86:413-420 /dev/mmcblk0p86:413-420                    /dev/mmcblk0p86(413)                                                 X2dGgy-PrjS-33XY-6eGw-SCG2-vVzw-kOKocY

----------------------------------------------------------------------------------------------

/ # lvm lvmdiskscan
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  /dev/ram0          [       8.00 MiB] 
  /dev/mmcblk0p32    [       2.00 MiB] 
  /dev/sailfish/root [       1.61 GiB] 
  /dev/ram1          [       8.00 MiB] 
  /dev/mmcblk0p33    [       2.00 MiB] 
  /dev/mmcblk0p1     [       8.00 MiB] 
  /dev/sailfish/home [      32.00 MiB] 
  /dev/ram2          [       8.00 MiB] 
  /dev/mmcblk0p2     [      32.00 MiB] 
  /dev/ram3          [       8.00 MiB] 
  /dev/mmcblk0p3     [      16.00 MiB] 
  /dev/ram4          [       8.00 MiB] 
  /dev/mmcblk0p36    [       2.00 MiB] 
  /dev/ram5          [       8.00 MiB] 
  /dev/mmcblk0p37    [       2.00 MiB] 
  /dev/ram6          [       8.00 MiB] 
  /dev/mmcblk0p6     [       3.50 MiB] 
  /dev/ram7          [       8.00 MiB] 
  /dev/mmcblk0p39    [       2.00 MiB] 
  /dev/mmcblk0p7     [       3.50 MiB] 
  /dev/ram8          [       8.00 MiB] 
  /dev/mmcblk0p40    [       2.00 MiB] 
  /dev/ram9          [       8.00 MiB] 
  /dev/mmcblk0p41    [       2.00 MiB] 
  /dev/ram10         [       8.00 MiB] 
  /dev/mmcblk0p42    [      64.00 MiB] 
  /dev/mmcblk0p10    [       4.00 MiB] 
  /dev/ram11         [       8.00 MiB] 
  /dev/mmcblk0p43    [      64.00 MiB] 
  /dev/mmcblk0p11    [       4.00 MiB] 
  /dev/ram12         [       8.00 MiB] 
  /dev/mmcblk0p44    [      96.00 MiB] 
  /dev/ram13         [       8.00 MiB] 
  /dev/mmcblk0p45    [      96.00 MiB] 
  /dev/ram14         [       8.00 MiB] 
  /dev/ram15         [       8.00 MiB] 
  /dev/mmcblk0p48    [     360.00 MiB] 
  /dev/mmcblk0p49    [     360.00 MiB] 
  /dev/mmcblk0p50    [      32.00 MiB] 
  /dev/mmcblk0p51    [      32.00 MiB] 
  /dev/mmcblk0p54    [      32.64 MiB] 
  /dev/mmcblk0p57    [       8.00 MiB] 
  /dev/mmcblk0p26    [      64.00 MiB] 
  /dev/mmcblk0p27    [      64.00 MiB] 
  /dev/mmcblk0p64    [      16.00 MiB] 
  /dev/mmcblk0rpmb   [      16.00 MiB] 
  /dev/mmcblk0p65    [      32.00 MiB] 
  /dev/mmcblk0p66    [      16.00 MiB] 
  /dev/mmcblk0p67    [       8.00 MiB] 
  /dev/mmcblk0p68    [      64.00 MiB] 
  /dev/mmcblk0p79    [      24.00 MiB] 
  /dev/mmcblk0p80    [      24.00 MiB] 
  /dev/mmcblk0p81    [      64.00 MiB] 
  /dev/mmcblk0p82    [      64.00 MiB] 
  /dev/mmcblk0p83    [     400.00 MiB] 
  /dev/mmcblk0p84    [     400.00 MiB] 
  /dev/mmcblk0p85    [      12.00 GiB] 
  /dev/mmcblk0p86    [    <102.03 GiB] LVM physical volume
  /dev/mmcblk0p87    [      20.00 MiB] 
  3 disks
  55 partitions
  0 LVM physical volume whole disks
  1 LVM physical volume

----------------------------------------------------------------------------------------------

/ # lvm lvs
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  LV   VG       Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home sailfish -wi-a----- 32.00m                                                    
  root sailfish -wi-ao----  1.61g  

----------------------------------------------------------------------------------------------

/ # lvm pvdisplay
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  --- Physical volume ---
  PV Name               /dev/mmcblk0p86
  VG Name               sailfish
  PV Size               <1.74 GiB / not usable 4.74 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              443
  Free PE               22
  Allocated PE          421
  PV UUID               hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT

----------------------------------------------------------------------------------------------

/ # lvm pvs
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  PV              VG       Fmt  Attr PSize PFree 
  /dev/mmcblk0p86 sailfish lvm2 a--  1.73g 88.00m

----------------------------------------------------------------------------------------------

/ # lvm pvscan
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  PV /dev/mmcblk0p86   VG sailfish        lvm2 [1.73 GiB / 88.00 MiB free]
  Total: 1 [1.73 GiB] / in use: 1 [1.73 GiB] / in no VG: 0 [0   ]

----------------------------------------------------------------------------------------------

/ # lvm vgdisplay
$  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  --- Volume group ---
  VG Name               sailfish
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               1.73 GiB
  PE Size               4.00 MiB
  Total PE              443
  Alloc PE / Size       421 / 1.64 GiB
  Free  PE / Size       22 / 88.00 MiB
  VG UUID               QvpLWF-dPEI-TIHz-pSp8-73p0-5UQS-26JEiE

----------------------------------------------------------------------------------------------

/ # lvm vgs
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  VG       #PV #LV #SN Attr   VSize VFree 
  sailfish   1   2   0 wz--n- 1.73g 88.00m

----------------------------------------------------------------------------------------------

/ # lvm vgscan
  Reading all physical volumes.  This may take a while...
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  Found volume group "sailfish" using metadata type lvm2

----------------------------------------------------------------------------------------------

/ # lvm vgscan
  Reading all physical volumes.  This may take a while...
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  Found volume group "sailfish" using metadata type lvm2
/ # lvm version
  LVM version:     2.02.177(2)-git (2017-12-18)
  Library version: 1.02.146-git (2017-12-18)
  Driver version:  4.37.0
  Configuration:   ./configure --host=aarch64-unknown-linux-gnu --build=aarch64-unknown-linux-gnu --target=aarch64-meego-linux-gnu --program-prefix= --disable-dependency-tracking --prefix=/usr --exec-prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib64 --libexecdir=/usr/libexec --localstatedir=/var --sharedstatedir=/var/lib --mandir=/usr/share/man --infodir=/usr/share/info --with-default-dm-run-dir=/run --with-default-run-dir=/run/lvm --with-default-pid-dir=/run --with-default-locking-dir=/run/lock/lvm --with-usrlibdir=/usr/lib64 --enable-lvm1_fallback --enable-fsadm --with-pool=internal --with-user= --with-group= --with-device-uid=0 --with-device-gid=6 --with-device-mode=0660 --with-cache=internal --with-thin=internal --with-thin_check=/usr/sbin/thin_check --with-thin_check=/usr/sbin/thin_check --with-thin_repair=/usr/sbin/thin_repair --with-thin_dump=/usr/sbin/thin_dump --enable-pkgconfig --enable-applib --enable-cmdlib --enable-dmeventd --disable-readline --with-udevdir=/lib/udev/rules.d --enable-udev-rules --disable-profiling --disable-lvmetad

----------------------------------------------------------------------------------------------

/ # fsck
fsck (busybox 1.34.1)
/ # find / -name busybox
/rootfs/usr/bin/busybox
/rootfs/bin/busybox
/ # /rootfs/bin/busybox
/rootfs/bin/busybox: error while loading shared libraries: libselinux.so.1: cannot open shared object file: No such file or directory
/ # /rootfs/usr/bin/busybox
/rootfs/usr/bin/busybox: error while loading shared libraries: libselinux.so.1: cannot open shared object file: No such file or directory
/ # df -h
Filesystem                Size      Used Available Use% Mounted on
none                      1.6G      4.0K      1.6G   0% /dev
none                     10.0M         0     10.0M   0% /tmp
none                    256.0K     12.0K    244.0K   5% /var/run
/dev/sailfish/root        1.5G      1.5G         0 100% /rootfs
none                      1.6G      4.0K      1.6G   0% /rootfs/dev
/ # fsck
fsck        fsck.minix

----------------------------------------------------------------------------------------------

If you continue, this may void your warranty. Are you really SURE? [y/N] [y/N] y
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  2 logical volume(s) in volume group "sailfish" now active
[OK] No lockcode has been set. Proceeding...
Starting sshd on 10.42.66.66.
Login: root
Password: recovery

Press [Enter] to stop sshd...

~$ ssh root@10.42.66.66
root@10.42.66.66's password: 
Permission denied, please try again.
root@10.42.66.66's password: 
Permission denied, please try again.
root@10.42.66.66's password: 
root@10.42.66.66: Permission denied (publickey,password,keyboard-interactive).
```

</sub>
