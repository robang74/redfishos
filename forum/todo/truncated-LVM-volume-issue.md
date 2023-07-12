# The coreutils cp and gnu tar version are too old to support filesystem overlay correctly

REPRODUCIBILITY: 100%
OS VERSION: 4.5.0.19
HARDWARE: Xperia 10 II
UI LANGUAGE: English
REGRESSION: no, AFAIK

DESCRIPTION:
============

The read-write upper layer does not communicate to some tools like `coreutils` `cp` and `tar` the size of the new version of the file but the one of the old underlying and overwritten.

PRECONDITIONS:
==============

A read-write overlay, overwritten a file, using very old filesystem tools.

STEPS TO REPRODUCE:
===================

1) Install this tarball ([here](https://t.ly/ZJMA)) on the root as root user
2) Try to create the tarball back from the files with `tar cvzf`
3) Check the tarball the /vendor/etc/gps.conf will be truncated at the size of the original file
4) Try to copy the overwritten `/vendor/etc/gps.conf` to `/tmp` with `coreutils` `cp --preserve`

EXPECTED RESULT:
================

The file should be copied or archived correctly with its newest size and content.

ACTUAL RESULT:
==============

The file is shorten at the original size

MODIFICATIONS:
==============

Compile new version of `tar` that support the overlays or use the one included into `busybox` which requires to be recompiled to offer the `tar` command as well.

ADDITIONAL INFORMATION:
=======================

The file `/vendor/etc/gps.conf` is read for the Qualcomm modem/`GPS`, if it is read at its original size, then it is completely useless for configuring the modem unless everything would stay into the original size (removing all the comments, for example). I fear that links on overlay would give a similar result or worse.

UPDATE  #2 
==========

The file userdata `LVM` system is working on the edge of an emotional collapse because it has been truncated at its birth in the factory:

<small>

```
$ simg2img sailfish.img001 sailfish.img001.raw
$ sudo loopsetup -f sailfish.img001.raw
$ sudo lvscan
  WARNING: Not using device /dev/loop21 for PV hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT.
  WARNING: PV hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT prefers device /dev/loop20 because device is used by LV.
  WARNING: Device /dev/loop20 has size of 3411880 sectors which is smaller than corresponding PV size of 3638768 sectors. Was device resized?
  WARNING: One or more devices used as PVs in VG sailfish have changed sizes.
  ACTIVE            '/dev/sailfish/root' [1.61 GiB] inherit
  inactive          '/dev/sailfish/home' [32.00 MiB] inherit
```
</small>

There is no way to deal with a OS running on a factory-truncated `LVM` filesystem AFAIK.

Below there is the report of the state of the internal storage taken after a complete re-flash of the smartphone with the `hybris-recovery.img` which suffers of some shortcoming, reported [here](https://forum.sailfishos.org/t/hybris-recovery-img-shortcoming/16112/1). 

**todo**: I will add also the information available after the installation but I have double check them because I saw things that you would not believe like a `GPT` partition (broken at the end of the truncated image) of 2TB with 97GB available only.

<small>

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
Device          Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk0p46p1 6f 357,116,40  357,32,45    778135908 1919645538 1141509631  544G 72 Unknown
Partition 1 has different physical/logical start (non-Linux?):
     phys=(357,116,40) logical=(12158373,2,5)
Partition 1 has different physical/logical end:
     phys=(357,32,45) logical=(29994461,2,3)
/dev/mmcblk0p46p2 69 288,115,43  367,114,50   168689522 2104717761 1936028240  923G 65 Unknown
Partition 2 has different physical/logical start (non-Linux?):
     phys=(288,115,43) logical=(2635773,3,3)
Partition 2 has different physical/logical end:
     phys=(367,114,50) logical=(32886215,0,2)
/dev/mmcblk0p46p3 73 366,32,33   357,32,43   1869881465 3805909656 1936028192  923G 79 Unknown
Partition 3 has different physical/logical start (non-Linux?):
     phys=(366,32,33) logical=(29216897,3,10)
Partition 3 has different physical/logical end:
     phys=(357,32,43) logical=(59467338,1,9)
/dev/mmcblk0p46p4 74 372,97,50   0,10,0               0 3637226495 3637226496 1734G  d Unknown
Partition 4 has different physical/logical start (non-Linux?):
     phys=(372,97,50) logical=(0,0,1)
Partition 4 has different physical/logical end:
     phys=(0,10,0) logical=(56831663,3,16)
Partition table entries are not in disk order

Disk /dev/mmcblk0p47: 1 MB, 1048576 bytes, 2048 sectors
32 cylinders, 4 heads, 16 sectors/track
Units: sectors of 1 * 512 = 512 bytes
Device          Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk0p47p1 6f 357,116,40  357,32,45    778135908 1919645538 1141509631  544G 72 Unknown
Partition 1 has different physical/logical start (non-Linux?):
     phys=(357,116,40) logical=(12158373,2,5)
Partition 1 has different physical/logical end:
     phys=(357,32,45) logical=(29994461,2,3)
/dev/mmcblk0p47p2 69 288,115,43  367,114,50   168689522 2104717761 1936028240  923G 65 Unknown
Partition 2 has different physical/logical start (non-Linux?):
     phys=(288,115,43) logical=(2635773,3,3)
Partition 2 has different physical/logical end:
     phys=(367,114,50) logical=(32886215,0,2)
/dev/mmcblk0p47p3 73 366,32,33   357,32,43   1869881465 3805909656 1936028192  923G 79 Unknown
Partition 3 has different physical/logical start (non-Linux?):
     phys=(366,32,33) logical=(29216897,3,10)
Partition 3 has different physical/logical end:
     phys=(357,32,43) logical=(59467338,1,9)
/dev/mmcblk0p47p4 74 372,97,50   0,10,0               0 3637226495 3637226496 1734G  d Unknown
Partition 4 has different physical/logical start (non-Linux?):
     phys=(372,97,50) logical=(0,0,1)
Partition 4 has different physical/logical end:
     phys=(0,10,0) logical=(56831663,3,16)
Partition table entries are not in disk order

Disk /dev/mmcblk0p48: 360 MB, 377487360 bytes, 737280 sectors
11520 cylinders, 4 heads, 16 sectors/track
Units: sectors of 1 * 512 = 512 bytes
Device          Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk0p48p1 6f 357,116,40  357,32,45    778135908 1919645538 1141509631  544G 72 Unknown
/dev/mmcblk0p48p2 69 288,115,43  367,114,50   168689522 2104717761 1936028240  923G 65 Unknown
/dev/mmcblk0p48p3 73 366,32,33   357,32,43   1869881465 3805909656 1936028192  923G 79 Unknown
/dev/mmcblk0p48p4 74 372,97,50   0,10,0               0 3637226495 3637226496 1734G  d Unknown
Partition table entries are not in disk order

Disk /dev/mmcblk0p49: 360 MB, 377487360 bytes, 737280 sectors
11520 cylinders, 4 heads, 16 sectors/track
Units: sectors of 1 * 512 = 512 bytes
Device          Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/mmcblk0p49p1 6f 357,116,40  357,32,45    778135908 1919645538 1141509631  544G 72 Unknown
/dev/mmcblk0p49p2 69 288,115,43  367,114,50   168689522 2104717761 1936028240  923G 65 Unknown
/dev/mmcblk0p49p3 73 366,32,33   357,32,43   1869881465 3805909656 1936028192  923G 79 Unknown
/dev/mmcblk0p49p4 74 372,97,50   0,10,0               0 3637226495 3637226496 1734G  d Unknown
Partition table entries are not in disk order

-----------------------------------------------------------------------------------------------

/ # lvm lvscan
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  ACTIVE            '/dev/sailfish/root' [1.61 GiB] inherit
  ACTIVE            '/dev/sailfish/home' [32.00 MiB] inherit

/ # fdisk -l /dev/mmcblk0rpmb
fdisk: can't open '/dev/mmcblk0rpmb': Input/output error

/ # lvm fullreport
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  Fmt  VG UUID                                VG       Attr   VPerms     Extendable Exported   Partial    AllocPol   Clustered  VSize VFree  SYS ID System ID LockType VLockArgs Ext   #Ext Free MaxLV MaxPV #PV #PV Missing #LV #SN Seq VG Tags VProfile #VMda #VMdaUse VMdaFree  VMdaSize  #VMdaCps 
  lvm2 QvpLWF-dPEI-TIHz-pSp8-73p0-5UQS-26JEiE sailfish wz--n- writeable  extendable                       normal                1.73g 88.00m                                     4.00m  443   22     0     0   1           0   2   0   3                      1        1   505.50k  1020.00k unmanaged
  Fmt  PV UUID                                DevSize  PV              Maj Min PMdaFree  PMdaSize  PExtVsn 1st PE  PSize PFree  Used  Attr Allocatable Exported   Missing    PE  Alloc PV Tags #PMda #PMdaUse BA Start BA Size PInUse Duplicate
  lvm2 hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT <102.03g /dev/mmcblk0p86 259 54    505.50k  1020.00k       2   1.00m 1.73g 88.00m 1.64g a--  allocatable                       443   421             1        1       0       0    used          
  LV UUID                                LV   LV            Path               DMPath                    Parent Layout     Role       InitImgSyn ImgSynced  Merging    Converting AllocPol   AllocLock  FixMin     SkipAct         WhenFull        Active ActLocal       ActRemote  ActExcl            Maj Min Rahead LSize  MSize #Seg Origin Origin UUID                            OSize Ancestors FAncestors Descendants FDescendants Mismatches SyncAction WBehind MinSync MaxSync Move Move UUID                              Convert Convert UUID                           Log Log UUID                               Data Data UUID                              Meta Meta UUID                              Pool Pool UUID                              LV Tags LProfile LLockArgs CTime                      RTime                      Host        Modules Historical KMaj KMin KRahead LPerms    Suspended  LiveTable            InactiveTable        DevOpen    Data%  Snap%  Meta%  Cpy%Sync Cpy%Sync CacheTotalBlocks CacheUsedBlocks  CacheDirtyBlocks CacheReadHits    CacheReadMisses  CacheWriteHits   CacheWriteMisses KCacheSettings     KCachePolicy       KMFmt Health          KDiscards CheckNeeded     MergeFailed     SnapInvalid     Attr      
  X2dGgy-PrjS-33XY-6eGw-SCG2-vVzw-kOKocY home sailfish/home /dev/sailfish/home /dev/mapper/sailfish-home        linear     public                                                 inherit                                                          active active locally            active exclusively  -1  -1   auto 32.00m          1                                                                                                                                                                                                                                                                                                                                                                                                                                                      2023-03-15 10:37:18 +0000                             SailfishSDK                     252    1 512.00k writeable              live table present                                                                                                                                                                                                                                                                             unknown         unknown         unknown -wi-a-----
  DmTh1t-Dwj3-KqeL-d4bs-N2ya-rIkz-4DpfVl root sailfish/root /dev/sailfish/root /dev/mapper/sailfish-root        linear     public                                                 inherit                                                          active active locally            active exclusively  -1  -1   auto  1.61g          1                                                                                                                                                                                                                                                                                                                                                                                                                                                      2023-03-15 10:37:18 +0000                             SailfishSDK                     252    0 512.00k writeable              live table present                            open                                                                                                                                                                                                                                             unknown         unknown         unknown -wi-ao----
  Start SSize PV UUID                                LV UUID                               
      0   413 hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT DmTh1t-Dwj3-KqeL-d4bs-N2ya-rIkz-4DpfVl
    413     8 hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT X2dGgy-PrjS-33XY-6eGw-SCG2-vVzw-kOKocY
    421    22 hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT                                       
  Type   #Str #DStr RSize RSize #Cpy DOff NOff #Par Stripe Region Chunk #Thins Discards CMFmt CacheMode Zero    TransId ThId Start Start SSize  SSize Seg Tags PE Ranges               LE Ranges               Metadata LE Ranges Devices              Metadata Devs Monitor CachePolicy CacheSettings LV UUID                               
  linear    1     1                1                    0      0     0                                  unknown                 0      0  1.61g   413          /dev/mmcblk0p86:0-412   /dev/mmcblk0p86:0-412                      /dev/mmcblk0p86(0)                                                   DmTh1t-Dwj3-KqeL-d4bs-N2ya-rIkz-4DpfVl
  linear    1     1                1                    0      0     0                                  unknown                 0      0 32.00m     8          /dev/mmcblk0p86:413-420 /dev/mmcblk0p86:413-420                    /dev/mmcblk0p86(413)                                                 X2dGgy-PrjS-33XY-6eGw-SCG2-vVzw-kOKocY

----------------------------------------------------------------------------------------------

/ # lvm lvmdiskscan
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  /dev/ram0          [       8.00 MiB] 
  /dev/mmcblk0p32    [       2.00 MiB] 
  /dev/sailfish/root [       1.61 GiB] 
  /dev/ram1          [       8.00 MiB] 
  /dev/mmcblk0p33    [       2.00 MiB] 
  /dev/mmcblk0p1     [       8.00 MiB] 
  /dev/sailfish/home [      32.00 MiB] 
  /dev/ram2          [       8.00 MiB] 
  /dev/mmcblk0p2     [      32.00 MiB] 
  /dev/ram3          [       8.00 MiB] 
  /dev/mmcblk0p3     [      16.00 MiB] 
  /dev/ram4          [       8.00 MiB] 
  /dev/mmcblk0p36    [       2.00 MiB] 
  /dev/ram5          [       8.00 MiB] 
  /dev/mmcblk0p37    [       2.00 MiB] 
  /dev/ram6          [       8.00 MiB] 
  /dev/mmcblk0p6     [       3.50 MiB] 
  /dev/ram7          [       8.00 MiB] 
  /dev/mmcblk0p39    [       2.00 MiB] 
  /dev/mmcblk0p7     [       3.50 MiB] 
  /dev/ram8          [       8.00 MiB] 
  /dev/mmcblk0p40    [       2.00 MiB] 
  /dev/ram9          [       8.00 MiB] 
  /dev/mmcblk0p41    [       2.00 MiB] 
  /dev/ram10         [       8.00 MiB] 
  /dev/mmcblk0p42    [      64.00 MiB] 
  /dev/mmcblk0p10    [       4.00 MiB] 
  /dev/ram11         [       8.00 MiB] 
  /dev/mmcblk0p43    [      64.00 MiB] 
  /dev/mmcblk0p11    [       4.00 MiB] 
  /dev/ram12         [       8.00 MiB] 
  /dev/mmcblk0p44    [      96.00 MiB] 
  /dev/ram13         [       8.00 MiB] 
  /dev/mmcblk0p45    [      96.00 MiB] 
  /dev/ram14         [       8.00 MiB] 
  /dev/ram15         [       8.00 MiB] 
  /dev/mmcblk0p48    [     360.00 MiB] 
  /dev/mmcblk0p49    [     360.00 MiB] 
  /dev/mmcblk0p50    [      32.00 MiB] 
  /dev/mmcblk0p51    [      32.00 MiB] 
  /dev/mmcblk0p54    [      32.64 MiB] 
  /dev/mmcblk0p57    [       8.00 MiB] 
  /dev/mmcblk0p26    [      64.00 MiB] 
  /dev/mmcblk0p27    [      64.00 MiB] 
  /dev/mmcblk0p64    [      16.00 MiB] 
  /dev/mmcblk0rpmb   [      16.00 MiB] 
  /dev/mmcblk0p65    [      32.00 MiB] 
  /dev/mmcblk0p66    [      16.00 MiB] 
  /dev/mmcblk0p67    [       8.00 MiB] 
  /dev/mmcblk0p68    [      64.00 MiB] 
  /dev/mmcblk0p79    [      24.00 MiB] 
  /dev/mmcblk0p80    [      24.00 MiB] 
  /dev/mmcblk0p81    [      64.00 MiB] 
  /dev/mmcblk0p82    [      64.00 MiB] 
  /dev/mmcblk0p83    [     400.00 MiB] 
  /dev/mmcblk0p84    [     400.00 MiB] 
  /dev/mmcblk0p85    [      12.00 GiB] 
  /dev/mmcblk0p86    [    <102.03 GiB] LVM physical volume
  /dev/mmcblk0p87    [      20.00 MiB] 
  3 disks
  55 partitions
  0 LVM physical volume whole disks
  1 LVM physical volume

----------------------------------------------------------------------------------------------

/ # lvm lvs
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  LV   VG       Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home sailfish -wi-a----- 32.00m                                                    
  root sailfish -wi-ao----  1.61g  

----------------------------------------------------------------------------------------------

/ # lvm pvdisplay
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  --- Physical volume ---
  PV Name               /dev/mmcblk0p86
  VG Name               sailfish
  PV Size               <1.74 GiB / not usable 4.74 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              443
  Free PE               22
  Allocated PE          421
  PV UUID               hh8N8Y-zUlT-QyPV-snk0-RVJt-cnTz-oTFCuT

----------------------------------------------------------------------------------------------

/ # lvm pvs
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  PV              VG       Fmt  Attr PSize PFree 
  /dev/mmcblk0p86 sailfish lvm2 a--  1.73g 88.00m

----------------------------------------------------------------------------------------------

/ # lvm pvscan
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  PV /dev/mmcblk0p86   VG sailfish        lvm2 [1.73 GiB / 88.00 MiB free]
  Total: 1 [1.73 GiB] / in use: 1 [1.73 GiB] / in no VG: 0 [0   ]

----------------------------------------------------------------------------------------------

/ # lvm vgdisplay
$  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  --- Volume group ---
  VG Name               sailfish
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               1.73 GiB
  PE Size               4.00 MiB
  Total PE              443
  Alloc PE / Size       421 / 1.64 GiB
  Free  PE / Size       22 / 88.00 MiB
  VG UUID               QvpLWF-dPEI-TIHz-pSp8-73p0-5UQS-26JEiE

----------------------------------------------------------------------------------------------

/ # lvm vgs
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  VG       #PV #LV #SN Attr   VSize VFree 
  sailfish   1   2   0 wz--n- 1.73g 88.00m

----------------------------------------------------------------------------------------------

/ # lvm vgscan
  Reading all physical volumes.  This may take a while...
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  Found volume group "sailfish" using metadata type lvm2

----------------------------------------------------------------------------------------------

/ # lvm vgscan
  Reading all physical volumes.  This may take a while...
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16711680: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 16769024: Input/output error
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 4096: Input/output error
  Found volume group "sailfish" using metadata type lvm2
/ # lvm version
  LVM version:     2.02.177(2)-git (2017-12-18)
  Library version: 1.02.146-git (2017-12-18)
  Driver version:  4.37.0
  Configuration:   ./configure --host=aarch64-unknown-linux-gnu --build=aarch64-unknown-linux-gnu --target=aarch64-meego-linux-gnu --program-prefix= --disable-dependency-tracking --prefix=/usr --exec-prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib64 --libexecdir=/usr/libexec --localstatedir=/var --sharedstatedir=/var/lib --mandir=/usr/share/man --infodir=/usr/share/info --with-default-dm-run-dir=/run --with-default-run-dir=/run/lvm --with-default-pid-dir=/run --with-default-locking-dir=/run/lock/lvm --with-usrlibdir=/usr/lib64 --enable-lvm1_fallback --enable-fsadm --with-pool=internal --with-user= --with-group= --with-device-uid=0 --with-device-gid=6 --with-device-mode=0660 --with-cache=internal --with-thin=internal --with-thin_check=/usr/sbin/thin_check --with-thin_check=/usr/sbin/thin_check --with-thin_repair=/usr/sbin/thin_repair --with-thin_dump=/usr/sbin/thin_dump --enable-pkgconfig --enable-applib --enable-cmdlib --enable-dmeventd --disable-readline --with-udevdir=/lib/udev/rules.d --enable-udev-rules --disable-profiling --disable-lvmetad

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
Filesystem                Size      Used Available Use% Mounted on
none                      1.6G      4.0K      1.6G   0% /dev
none                     10.0M         0     10.0M   0% /tmp
none                    256.0K     12.0K    244.0K   5% /var/run
/dev/sailfish/root        1.5G      1.5G         0 100% /rootfs
none                      1.6G      4.0K      1.6G   0% /rootfs/dev
/ # fsck
fsck        fsck.minix

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

</small>


---

UPDATE
If you cannot reproduce this bug in a fresh installed SFOS, then cause a hard-shutdown pressing down all the lateral hardware buttons. This will make the fake-root filesystem to be interrupted in a dirty way. I did few times with my smartphone this procedure because I made things with it hardware/systemd services that brings it to a un-manageable state. Hardware forced shutdone is not a every-day procedure but it can happen in a end-user scenario and SFOS should deal properly with it.

Instead, if the bug is 100% reproducible in a fresh installed SFOS system, its nature is because part of the system has been upgraded while some others parts remain behind and that parts are too old. However, another reasonable question is: hardware which accesses directly or indirectly to configuration files can do this operations is times/ways for which fake-root is not yet ready or not supported. Without a specific investigation and a deep knowledege about the filesystem stack, it is not easy to determine with a blackbox ananlisys.

---

`telinit 3` ; do things at that level that have to do with the root filesystem¹; `telinit 6`

We need `telinit 6` because `telinit 5` as well as `reboot` do not work at level 3.

¹ for example trying to cast an instance of udhscpd in order to raise the network 

Enjoy your the beauty failures of `coreutils` trying to read files but crap instead.

<small>

```
[root@Sbriciolo ~]# mount /
mount: /: /dev/mapper/sailfish-root already mounted or mount point busy.
       dmesg(1) may have more information after failed mount system call.
[root@Sbriciolo ~]# lvscan
  /dev/mmcblk0rpmb: read failed after 0 of 4096 at 0: Input/output error
  ACTIVE            '/dev/sailfish/root' [4.88 GiB] inherit
  ACTIVE            '/dev/sailfish/home' [97.14 GiB] inherit
```

</small>

I have tried to `lvresize -r` and `lvextend -r` the `SFOS` image `.raw.img` after having used `simg2img`, `dd if=/dev/zero bs=4k count=$[missing sectors] >> .raw.img`, `kpartix`, `lvchange -ay root`, etc. etc. included `img2simg` before reflashing. A total disater that briked the phone for each different attempt!

BTW, why Jolla do not provide a spare image containing all the clusters? After all, spare image are created for such a reason: large filesystem but most of their size ignored. With the old partition tables there were no problems but with the new ones part of the essential data about partition table check/fixing are saved at the end of such image out of the filesystem and a full spare image should contains them as well. When the image is artificially truncated (why?) then those data are lost.

The `Linux Logical Volume Manager` is an abstraction layer. In fact, it contains a set of commands to deal with the physical devices underlying. If the physical devices are underlying the `LVM` then what I read with `busybox` vs `toybox` (firmware) vs `coreutils` is the overlay filesystem (whatever you wish to call it).

Finally, Jolla included `/vendor` into the root filesystem and THIS is not a good choice as long as the vendor partition exist because there are around other vendor images that can be tried 

Well, dealing with a folder is not such big issue because `mount -o loop,ro alt-vendor.img dir`, then `mv /vendor /vendor.bak` and create and fill the new one, then reboot. But it is not the same thing to flash a partition when the SFOS is not running, not exactly at least.

**Just one question**

What's about `hybris-recovery.img` (available) vs `hybris-boot.img` (default).

* `flash boot_a hybris-boot.img`
* `flash boot_b hybris-boot.img`

The first is completely ignored by `flash.sh` but on `boot_b` can be useful to have the recovery one, or in both boot partition as long as recovery is not the only boot mode that `hybris-recovery.img` can provide. Any suggestions?

**Nope another two questions**

Can concretely contribute to my effort? Or trying to confronting me is just a social engineering approach to squeeze precious information from me for free (gratis)? Just, asking... :face_with_hand_over_mouth:

Would not be better to take care of some stuff on this list, instead? For example fixing the way in which `Patch Manager` parse the filepath in the unified patch? About this, I am going to release new version (`v0.0.9`) of `zram-swap-resize-script` in order to check better what is going to confuse `PM2` about filepath (spoiler: the code, it is the code! :sweat_smile:).

---

The `SailFish OS` userdata `LVM` image is truncated - probably because `fdisk` on the raw.img presents a `MSDOS` partition that live nicely with truncated disk images and this information let someone erroneously think that it was safe to truncate it.

Unfortunately, the information presented are wrong because the image is clearly a `LVM` with two physical devices which one of them to be resized at first boot time because it is just 32Mb. Important data are at the end of disk and this imply that Jolla should have used `img2simg` on the whole 97GB image and did not truncate it before its first 2GB.

Why they did? Because people have not a great day in `simg2img` a 97GB file. Probably there is a solution (physical disk resize at first boot time, for example) for both the problems but I am not an expert of `LVM`.

Anyway, I paid a license to run a proprietary software (Alien Dalvik) on a system with a bricked filesystem and I am not happy about that. Not at all, because I cannot trust an OS with a broken-by-truncation root filesystem and when it goes under pressure it easy to reach the edge of the collapse. This easily explain also the myriad of problems reported here with apparently no a specific reason. The filesystem does its best but cannot do miracles.

---

These techniques may apply to permit you to modify the LVM layout as you wish:

https://gitlab.com/Olf0/sailfishX#332-shrinking-the-home-lvm-volume-and-extending-the-root-one

The problem is not extending the root but to fix the image to flash in a way that it takes its place and do not present anymore problems. In the past, they were not used to truncate the image. Trying to resize a truncate image even if the gap has been filled with zeros bring to nothing useful. What's truncated is gone, forever.

On top of this, I need to understand what I saw on my device like a GPT partition of 2TB.
