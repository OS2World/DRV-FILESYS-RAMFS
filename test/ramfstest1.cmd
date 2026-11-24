@echo off
rem RAMFS test 1: create a RAM disk, copy files, compare, directories, long names, rename, delete, heap statistics
set OUT=C:\RAMFS\test1.log
set UNIXROOT=C:
set PATH=C:\usr\bin;%PATH%
set DPATH=C:\OS2\SYSTEM;C:\OS2;C:\OS2\MDOS;%DPATH%
echo ==== ramdisk R: > %OUT%
C:\RAMFS\ramdisk.exe R: TESTRAM >> %OUT% 2>&1
dir R: >> %OUT% 2>&1
echo ==== copy files >> %OUT%
copy C:\CONFIG.SYS R:\config.sys >> %OUT% 2>&1
copy C:\OS2\DLL\PMMERGE.DLL "R:\A long name with spaces.dll" >> %OUT% 2>&1
md R:\sub >> %OUT% 2>&1
md "R:\directory with a longer name" >> %OUT% 2>&1
copy C:\CONFIG.SYS R:\sub\inner.txt >> %OUT% 2>&1
ren R:\sub\inner.txt renamed.txt >> %OUT% 2>&1
for %%j in (1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) do copy C:\OS2\DLL\PMMERGE.DLL R:\big%%j.dll > nul
echo ==== dir >> %OUT%
dir R: /s >> %OUT% 2>&1
echo ==== md5 >> %OUT%
md5sum.exe C:/CONFIG.SYS R:/config.sys R:/sub/renamed.txt C:/OS2/DLL/PMMERGE.DLL "R:/A long name with spaces.dll" R:/big1.dll R:/big20.dll >> %OUT% 2>&1
echo ==== heap >> %OUT%
C:\RAMFS\ramdisk.exe /heap >> %OUT% 2>&1
echo ==== delete >> %OUT%
for %%j in (1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) do del R:\big%%j.dll > nul
del R:\sub\renamed.txt >> %OUT% 2>&1
rmdir R:\sub >> %OUT% 2>&1
dir R: >> %OUT% 2>&1
echo ==== heap after >> %OUT%
C:\RAMFS\ramdisk.exe /heap >> %OUT% 2>&1
echo ==== end >> %OUT%
