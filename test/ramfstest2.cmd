@echo off
rem RAMFS test 2: directory tree copy, wildcards, move, directory rename, attributes, delete volume
set OUT=C:\RAMFS\test2.log
set UNIXROOT=C:
set PATH=C:\OS2;C:\usr\bin;%PATH%
set DPATH=C:\OS2\SYSTEM;C:\OS2;C:\OS2\MDOS;%DPATH%
echo ==== create R: > %OUT%
C:\RAMFS\ramdisk.exe R: TEST2 >> %OUT% 2>&1
echo ==== xcopy C:\OS2\DLL to R:\dll >> %OUT%
md R:\dll >> %OUT% 2>&1
C:\OS2\XCOPY.EXE C:\OS2\DLL\*.* R:\dll\ /s /e > nul 2>> %OUT%
dir C:\OS2\DLL /s | C:\usr\bin\tail.exe -3 >> %OUT% 2>&1
dir R:\dll /s | C:\usr\bin\tail.exe -3 >> %OUT% 2>&1
echo ==== wildcards >> %OUT%
dir R:\dll\p*.dll | C:\usr\bin\tail.exe -4 >> %OUT% 2>&1
dir R:\dll\*.dll /b | C:\usr\bin\wc.exe -l >> %OUT% 2>&1
dir C:\OS2\DLL\*.dll /b | C:\usr\bin\wc.exe -l >> %OUT% 2>&1
echo ==== md5 of 6 files >> %OUT%
md5sum.exe C:/OS2/DLL/PMMERGE.DLL R:/dll/PMMERGE.DLL C:/OS2/DLL/DOSCALL1.DLL R:/dll/DOSCALL1.DLL C:/OS2/DLL/PMWIN.DLL R:/dll/PMWIN.DLL >> %OUT% 2>&1
echo ==== directories >> %OUT%
md R:\a >> %OUT% 2>&1
md R:\a\b >> %OUT% 2>&1
md R:\a\b\c >> %OUT% 2>&1
copy C:\CONFIG.SYS R:\a\b\c\deep.txt >> %OUT% 2>&1
ren R:\a newname >> %OUT% 2>&1
dir R:\newname\b\c >> %OUT% 2>&1
C:\usr\bin\mv.exe R:/newname/b/c/deep.txt R:/moved.txt >> %OUT% 2>&1
md5sum.exe C:/CONFIG.SYS R:/moved.txt >> %OUT% 2>&1
echo ==== attributes >> %OUT%
C:\OS2\ATTRIB.EXE +r R:\moved.txt >> %OUT% 2>&1
del R:\moved.txt >> %OUT% 2>&1
C:\OS2\ATTRIB.EXE R:\moved.txt >> %OUT% 2>&1
C:\OS2\ATTRIB.EXE -r R:\moved.txt >> %OUT% 2>&1
del R:\moved.txt >> %OUT% 2>&1
dir R:\moved.txt >> %OUT% 2>&1
echo ==== heap >> %OUT%
C:\RAMFS\ramdisk.exe /heap >> %OUT% 2>&1
echo ==== delete the tree and the volume >> %OUT%
rmdir R:\newname\b\c >> %OUT% 2>&1
C:\RAMFS\ramdisk.exe /delete R: >> %OUT% 2>&1
dir R: >> %OUT% 2>&1
C:\RAMFS\ramdisk.exe /heap >> %OUT% 2>&1
echo ==== end >> %OUT%
