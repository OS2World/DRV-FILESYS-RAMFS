# Open Watcom 2.0 Makefile for RAMFS.IFS (run from the project root; compile_wat.cmd does this)
#
# 16-bit IFS: large model, SS != DS, built from the original sources (see doc\CHANGES.md).

WATCOM = C:\WATCOM
CC     = $(WATCOM)\binp\wcc.exe
ASM    = $(WATCOM)\binp\wasm.exe
LINK   = $(WATCOM)\binp\wlink.exe

SRC    = src
BIN    = bin

# the original options of Microsoft C 6.0: -Alfu (large, SS != DS, load DS) -G2s (286, no stack checks) -Zp (pack 1) -J (unsigned char)
# -D_ss=far -D_ds=far: the source uses _ss / _ds as pointer qualifiers
COPT   = -bt=os2 -2 -ml -ecw -s -zdp -zgf -zls -zp=1 -zu -ze -zq -od -of+ -q -dMAX_HEAP -d__COMPACT__ -d_ss=far -d_ds=far -d__16BITS__ -dNULL=0 -fi=$(SRC)\os2compat.h -dINCL_DOSERRORS -dINCL_DOSFILEMGR -dINCL_DOSMISC -i=$(SRC) -i=$(WATCOM)\h -i=$(WATCOM)\h\os21x

OBJS = $(BIN)\allocate.obj $(BIN)\attach.obj $(BIN)\cancello.obj $(BIN)\chdir.obj $(BIN)\chgfilep.obj &
       $(BIN)\close.obj $(BIN)\commit.obj $(BIN)\copy.obj $(BIN)\delete.obj $(BIN)\dopageio.obj &
       $(BIN)\exit.obj $(BIN)\fileattr.obj $(BIN)\fileinfo.obj $(BIN)\fileio.obj $(BIN)\filelock.obj &
       $(BIN)\findclos.obj $(BIN)\findfirs.obj $(BIN)\findfrom.obj $(BIN)\findnext.obj $(BIN)\flushbuf.obj &
       $(BIN)\fsctl.obj $(BIN)\fsinfo.obj $(BIN)\init.obj $(BIN)\ioctl.obj $(BIN)\mkdir.obj $(BIN)\mount.obj &
       $(BIN)\move.obj $(BIN)\newsize.obj $(BIN)\nmpipe.obj $(BIN)\notifycl.obj $(BIN)\notifyfi.obj &
       $(BIN)\notifyne.obj $(BIN)\opencrea.obj $(BIN)\openpage.obj $(BIN)\pathinfo.obj $(BIN)\processn.obj &
       $(BIN)\read.obj $(BIN)\rmdir.obj $(BIN)\setswap.obj $(BIN)\shutdown.obj $(BIN)\verifyun.obj &
       $(BIN)\write.obj $(BIN)\block.obj $(BIN)\ea.obj $(BIN)\find.obj $(BIN)\info.obj $(BIN)\nearheap.obj &
       $(BIN)\util.obj $(BIN)\vmheap.obj

all: $(BIN)\ramfs.ifs .SYMBOLIC

objs: $(OBJS) .SYMBOLIC

.c{$(BIN)}.obj: .AUTODEPEND
	@if not exist $(BIN) mkdir $(BIN)
	@echo CC $<
	$(CC) $(COPT) -fo=$@ -fr=$^&.err $<

$(BIN)\vmheap.obj: $(SRC)\vmheap.asm
	@if not exist $(BIN) mkdir $(BIN)
	@echo ASM $<
	$(ASM) -zq -dMAX_HEAP -fo=$@ $<

.c: $(SRC)

clean: .SYMBOLIC
	@if exist $(BIN)\*.obj del $(BIN)\*.obj
	@if exist $(BIN)\*.err del $(BIN)\*.err

# ---- link ---------------------------------------------------------------------------------------
# 'os2 lx phys' with 16-bit and 32-bit segments: the format of the other open IFS projects (FS-EXFAT, HFS).
# The FSHELPER entry points are imported by ordinal (no import library needed). No run-time start-up code.
$(BIN)\ramfs.ifs: $(OBJS) src\ramfs_exports.lnk
	$(LINK) @<<
format os2 lx phys
name $(BIN)\ramfs.ifs
option quiet
option stack=0
option manyautodata
option nodefaultlibs
option mixed1632
option map=$(BIN)\ramfs.map
option description '@#OS2World:1.22#@RAMFS - RAM IFS (Open Watcom)'
segment type CODE PRELOAD EXECUTEREAD NONSHARED
segment type DATA PRELOAD NONSHARED
import DOSWRITE DOSCALLS.138
import DOS32FLATDS DOSCALLS.370
import FSH_WILDMATCH FSHELPER.27
import FSH_FINDCHAR FSHELPER.30
import FSH_UPPERCASE FSHELPER.46
import FSH_CHECKEANAME FSHELPER.47
import FSH_GETVOLPARM FSHELPER.14
file { $(OBJS) }
library $(WATCOM)\lib286\os2\clibl.lib
@src\ramfs_exports.lnk
<<
