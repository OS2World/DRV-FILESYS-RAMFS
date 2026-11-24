# Provenance of the kernel interface headers

The original RAMFS sources included `fsd.h` and `fsh.h`, the file system driver interface headers of the IBM Device Driver Kit
(they carry the IBM revision lines "fsd.h 6.5 91/12/16" and "fsh.h 6.5 91/10/20"), and the build linked the IBM library
`fshelper.lib`. Those files are IBM material and are not part of this release.

* `src\fsd.h` and `src\fsh.h` are clean-room headers written by OS2World from public documentation (the IBM IFS and physical
  device driver reference books), first for the HFS/2 and FS-EXFAT drivers, which load and run on ArcaOS. For RAMFS the four
  driver-private areas (`vpfsd`, `cdfsd`, `sffsd`, `fsfsd`) were turned into incomplete types, because RAMFS defines them
  itself in `ramfs.h`. They are released into the public domain.
* `fshelper.lib` is not needed: the FSHELPER entry points are imported by ordinal in `Makefile.wat`
  (`FSH_GETVOLPARM` 14, `FSH_WILDMATCH` 27, `FSH_FINDCHAR` 30, `FSH_UPPERCASE` 46, `FSH_CHECKEANAME` 47).
* `src\os2compat.h` supplies a few constants of the 32-bit toolkit (`FIL_*`, `FSCTL_*`, `ERROR_HANDLE_EOF`) and the 64-bit
  integer type, which the 16-bit headers of Open Watcom do not have.
* The original (IBM) header text is still in the git history (tag `upstream-original`) but is not used.
