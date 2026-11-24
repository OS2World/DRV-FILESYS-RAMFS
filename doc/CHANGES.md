# Changes from the original RAMFS 1.21

The original state is tagged `upstream-original`; this list is every change, file by file.

## Layout
* Sources stay in `src\`. The Microsoft C / IBM ALP / Link386 makefiles (`makefile`, `tools\makefile`, `patch\makefile`),
  the `rollback.gz` and the original assembler (`vmheap.asm.orig`) are in `doc\original\`. The original documentation
  (`readme.txt`, `todo.txt`, `ramfs.gif`, `ramfs.dot`) is in `doc\`.
* `src\patch\` (the kernel hot-patch, see below) and `src\fshelper.lib` (IBM library) removed from the tree. The patch sources included `ldrmte.h`,
  whose comment says it was derived from SDF files (IBM kernel debugger structure definitions), so they are not kept in the current tree. They are still in the
  git history (tag `upstream-original`).

## Build (no logic change)
* `Makefile.wat`, `compile_wat.cmd` (new): Open Watcom 2. Options translated from the Microsoft C ones: large model, SS != DS,
  no stack checks, packing 1, `-D_ss=far -D_ds=far -DMAX_HEAP`.
  The assembler module is built with WASM, the link recipe is `format os2 lx phys` with the FSHELPER entry points imported
  by ordinal. `compile_wat.cmd trace` builds a debug version with stage markers in `FS_INIT`.
* `compile_gcc.cmd` (new): `RAMDISK.EXE` with GCC 9 / kLIBC, 32-bit (the sources already supported `__32BIT__`).
* `src\os2compat.h` (new, forced into every source file): constants and the 64-bit integer type that the 16-bit OS/2 1.x headers
  of Open Watcom lack.
* All 46 C sources compile unchanged apart from the points below.

## Fixes needed to run on ArcaOS (found by tests on the VM)
* `src\includes.h`: `EXPENTRY` is redefined with `_loadds`. The original build (Microsoft C `-Alfu`) loaded DS at the entry of
  every function; the FS_xxx entry points are called by the kernel with another DS. Without it the boot froze in `FS_INIT`.
* `src\ifslib.c` (new): own `memcpy`, `memset`, `memcmp`, `memchr`, `strlen`, `strcpy`, `strncpy`, `strcmp`, `strstr`, `strlwr`,
  `atol`. The Open Watcom library versions load DS from their pointer arguments and leave it changed (here `strlwr` left DS at the stack
  segment), which a ring 0 driver cannot allow.
* `src\vmheap.asm` (the VM block routines), ported from IBM ALP to WASM, and changed:
  * the 3DNow!/MMX transfer routine and the kernel hot-patch (`_fix_kernel`, `_fix_kernel_npx`) were removed. The patch changes kernel
    code of OS/2 14.088-14.095 by pattern, which is not safe on newer kernels; the plain DWORD copy, the original fallback, is the only one;
  * the DWORD copy is done inline with 32-bit string instructions (address-size prefix 67h). The original reached a 32-bit routine through
    a flat code selector read from an undocumented kernel structure at run time; the separate 32-bit object of an IFS is loaded at privilege
    level 3 and cannot be called from ring 0 (a call through its own selector gave a general protection fault);
  * the routines that use global data load DS themselves; the C variables `_DevHlp` and `_alloc_flags` are declared inside the 16-bit data
    segment (declared outside, the assembler used 32-bit addressing with a far fixup, which also trapped);
  * the heap counters (`_gcbHeapMax` etc.) are in `_DATA`, not in a `BSS` segment (the linker zero-fills `BSS`, so the default memory limit
    would have been 0);
  * `VMINIT` does nothing and is kept because `init.c` calls it.
* `/3`, `/!3` and `/DBCS` (kernel patch options) are still accepted and ignored.

## Boot messages and parameters (new)
* `src\init.c`: quiet by default; `/V` prints `RAMFS: Version 1.22 (built date)`; `/Q` now means no messages at all (it only hid the version
  notice before); `/W` waits for a key; `/AA` beeps. Every message line starts with `RAMFS: `. `DOSREAD` and `DOSBEEP` are imported.
* The version is 1.22.

## Headers
* `src\fsd.h` and `src\fsh.h` replaced by clean-room headers (see `PROVENANCE.md`), `fshelper.lib` not used.

## Tests (ArcaOS 5.1.2 VM, kernel 14.204 SMP, 2026-11-24; scripts in `test\`)
* Boot: silent; with `/V` one `RAMFS:` line.
* Test 1: RAM disk R: created; files, directories with long names, rename; MD5 sums of the 1.27 MB DLL and 20 copies identical; 954 allocations,
  after deleting 904 frees, the remaining 50 blocks are the files and directories that were kept.
* Test 2: 295 files / 21 MB (`C:\OS2\DLL`) copied with XCOPY, same counts and sizes, wildcard counts equal, MD5 sums identical; deep directories,
  directory rename, move; read-only files cannot be deleted until the attribute is cleared; `RAMDISK /DELETE R:` releases everything
  (1819 allocations, 1819 frees, 0 bytes used).
* Not tested: extended attributes, real hardware, SMP load, very large files, a full disk, the `/S`, `/CLU`, `/R` and `/!VM` options.
