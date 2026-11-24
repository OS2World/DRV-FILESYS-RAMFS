# RAMFS - IFS-based RAM disk for OS/2 and ArcaOS

RAMFS.IFS is an installable file system driver that keeps its files in RAM: any number of RAM drives, long file names,
extended attributes, memory taken from OS/2 as files are created and given back when they are deleted. The data is lost at
reboot, which makes a RAM drive a good place for `TEMP` and `TMP`.

| | |
|---|---|
| Status | working in a virtual machine: create, copy, rename, move, delete, deep directories, 295 files / 21 MB tree, delete of the volume, no memory leaks; alpha |
| Version | 1.22 (update of version 1.21) |
| Tested on | ArcaOS 5.1.2 (kernel 14.204 SMP) in a VirtualBox virtual machine, uniprocessor use. Not tested on real hardware. |
| License | public domain, see `LICENSE` |
| Authors | Karl Olsen (RAMFS), Andrew Belov (later versions), OS2World (this update) |
| Original source | https://github.com/OS2World/DRV-FILESYS-RAMFS (tag `upstream-original`, version 1.21) |
| Build tools | Open Watcom 2 (the IFS), GCC 9 for OS/2 (`RAMDISK.EXE`) |

## Install

1. Back up `CONFIG.SYS` and know how to edit it at boot (Alt+F1): a bad file system driver can stop the boot.
2. Copy `RAMFS.IFS` and `RAMDISK.EXE` to a directory, for example `C:\RAMFS`.
3. Add to `CONFIG.SYS` (after the other `IFS=` lines):

```
IFS=C:\RAMFS\RAMFS.IFS /M:512M
CALL=C:\RAMFS\RAMDISK.EXE R: TEMP
```

4. Reboot. `RAMDISK R: label` creates the drive R: (here at every boot through `CALL=`).

`RAMDISK /DELETE R:` deletes a drive, `RAMDISK /HEAP` shows the memory statistics, `RAMDISK /HEAP:128M` changes the memory limit.
The manual of the original is `doc\readme.txt`.

## Parameters of RAMFS.IFS

The driver is quiet at boot (only errors are shown), following the EDM2 "Suggestion for OS/2 and eComStation Drivers Arguments".
Every message starts with `RAMFS: `.

| Parameter | Effect |
|---|---|
| `/V` | print the version (and a note if `/M` was used) |
| `/Q` | no messages at all, not even errors (before 1.22 `/Q` only hid the version notice) |
| `/W` | wait for a key after the messages |
| `/AA` | beep when the driver loaded |
| `/M:<size>` | limit the memory RAMFS may use (default 3 GB), for example `/M:512M` |
| `/S:<size>` | free space reported to programs (default 64M) |
| `/CLU:<ranges>` | variable-length cluster configuration |
| `/R` | make the files non-swappable |
| `/!VM` | do not verify memory addresses |

`/3`, `/!3` and `/DBCS` are still accepted but do nothing: they belonged to a kernel patch that is no longer in the driver (see below).
The full description of the other options is in `doc\readme.txt`.

## Build

From the project root on ArcaOS (Open Watcom 2 in `C:\WATCOM`; GCC 9 and `watcom-wlink-hll` from ANPM for the utility):

```
compile_wat.cmd         the driver      -> bin\ramfs.ifs     (log: compile.log)
compile_gcc.cmd         RAMDISK.EXE     -> bin\ramdisk.exe   (log: compile_gcc.log)
compile_wat.cmd trace   debug build of the driver: FS_INIT prints stage markers (for finding a boot hang)
```

The IFS is a 16-bit module (Open Watcom `wcc -ml`, `wlink format os2 lx phys`, FSHELPER entry points imported by ordinal; see
`Makefile.wat`). The original Microsoft C / IBM ALP / Link386 files are in `doc\original`.

## Test

`test\ramfstest1.cmd` and `test\ramfstest2.cmd` create a RAM disk, copy files and a directory tree, compare MD5 sums, test
long names, directories, rename and move, read-only files and the heap statistics, and delete the volume. `test\install-test.cmd`
is the REXX script that put the driver into the CONFIG.SYS of the test VM. They contain the paths of the test machine.

## Known issues

* Alpha: tested only in a virtual machine. Extended attributes were not tried in this version.
* No file locking (`DosSetFileLocks`) and no `DosFindNotify`, so WPS folders on a RAMFS drive do not refresh by themselves
  (as in the original).
* `RAMDISK /DELETE` may take time with many small files and was called "unstable" by the original author.
* The 3DNow!/MMX transfer routine and the kernel hot-patch of the original are not included (see `doc\CHANGES.md`).

## Changelog

See [doc/CHANGES.md](doc/CHANGES.md).
