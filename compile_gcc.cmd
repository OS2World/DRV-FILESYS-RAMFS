@echo off
rem compile_gcc.cmd - build RAMDISK.EXE (the utility that creates, deletes and reports RAM disks) with GCC 9 / kLIBC
rem   compile_gcc.cmd         build, log in compile_gcc.log, output bin\ramdisk.exe
rem   compile_gcc.cmd clean   remove it and the log
rem Needs GCC 9 (ANPM) and watcom-wlink-hll (wl.exe) with Open Watcom at C:\WATCOM.
set WATCOM=C:\WATCOM
set PATH=C:\usr\bin;%WATCOM%\BINP;%WATCOM%\BINW;%PATH%
set UNIXROOT=C:
set C_INCLUDE_PATH=C:/usr/include;C:/os2tk45/h
set LIBRARY_PATH=C:/usr/lib
set EMXOMFLD_TYPE=WLINK
set EMXOMFLD_LINKER=wl.exe
set EMXOMFLD_PRELINK=0
if "%1"=="clean" goto clean
if not exist bin md bin
if exist bin\ramdisk.exe del bin\ramdisk.exe
echo ==== compile > compile_gcc.log
gcc -Zomf -O2 -Wall -D__32BIT__ -DMERGE -Isrc/tools -o bin/ramdisk.exe src/tools/main.c src/tools/ramdisk.c src/tools/deldisk.c src/tools/maxheap.c src/tools/heapstat.c >> compile_gcc.log 2>&1
if exist bin\ramdisk.exe echo OK: bin\ramdisk.exe
if not exist bin\ramdisk.exe echo FAILED: see compile_gcc.log
goto end
:clean
if exist bin\ramdisk.exe del bin\ramdisk.exe
if exist compile_gcc.log del compile_gcc.log
:end
