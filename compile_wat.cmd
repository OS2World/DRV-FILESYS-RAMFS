@echo off
rem compile_wat.cmd - build RAMFS.IFS with Open Watcom 2 (run from the project root)
rem   compile_wat.cmd         build, log in compile.log
rem   compile_wat.cmd trace   clean build with stage markers in FS_INIT (for debugging a boot hang)
rem   compile_wat.cmd objs    only compile the C files (-k: continue after errors)
rem   compile_wat.cmd clean   remove the objects and the log
set WATCOM=C:\WATCOM
set PATH=%WATCOM%\BINP;%WATCOM%\BINW;%PATH%
set EDPATH=%WATCOM%\EDDAT
if not exist "%WATCOM%\BINP\WMAKE.EXE" goto missing_wmake
if "%1"=="clean" goto clean
if "%1"=="objs" goto objs
if "%1"=="trace" goto trace
echo Building RAMFS.IFS ...
"%WATCOM%\BINP\WMAKE.EXE" -h -f Makefile.wat > compile.log 2>&1 < nul
if not exist bin\ramfs.ifs goto build_failed
echo OK: bin\ramfs.ifs
dir bin\ramfs.ifs
goto end
:trace
"%WATCOM%\BINP\WMAKE.EXE" -h -f Makefile.wat clean > compile.log 2>&1
"%WATCOM%\BINP\WMAKE.EXE" -h -f Makefile.wat EXTRA=-dRAMFS_TRACE >> compile.log 2>&1 < nul
if not exist bin\ramfs.ifs goto build_failed
echo OK: bin\ramfs.ifs (trace build)
dir bin\ramfs.ifs
goto end
:objs
"%WATCOM%\BINP\WMAKE.EXE" -h -k -f Makefile.wat objs > compile.log 2>&1 < nul
echo objects built, see compile.log
goto end
:clean
"%WATCOM%\BINP\WMAKE.EXE" -h -f Makefile.wat clean
if exist compile.log del compile.log
goto end
:missing_wmake
echo FAILED: Open Watcom wmake was not found at %WATCOM%\BINP\WMAKE.EXE.
goto end
:build_failed
echo FAILED: see compile.log
:end
