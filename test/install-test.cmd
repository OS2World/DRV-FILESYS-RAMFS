/* REXX: rfcfg <ifsfile> <params> : copy RAMFS.IFS (as C:\RAMFS\<ifsfile>) and RAMDISK.EXE, put IFS=C:\RAMFS\<ifsfile> <params> after the FAT32.IFS line of C:\CONFIG.SYS */
parse arg ifsfile params
call RxFuncAdd 'SysFileDelete','REXXUTIL','SysFileDelete'
src = 'D:\Projects\Drivers\DRV-FILESYS-RAMFS\bin\'
'md C:\RAMFS >nul 2>&1'
'copy' src'ramfs.ifs C:\RAMFS\'ifsfile' >nul'
'copy' src'ramdisk.exe C:\RAMFS\ramdisk.exe >nul'
cfg = "C:\CONFIG.SYS"
if stream('C:\CONFIG.RAMFS','c','query exists') = '' then 'copy' cfg 'C:\CONFIG.RAMFS >nul'
n = 0
do while lines(cfg) > 0
  n = n + 1
  l.n = linein(cfg)
end
call lineout cfg
tmp = "C:\CONFIG.NEW"
call SysFileDelete tmp
done = 0
do i = 1 to n
  u = translate(strip(l.i))
  if pos('C:\RAMFS\', u) > 0 then iterate
  call lineout tmp, l.i
  if pos('IFS=C:\OS2\FAT32.IFS', u) = 1 & \done then do
    call lineout tmp, 'IFS=C:\RAMFS\'ifsfile params
    done = 1
  end
end
call lineout tmp
'copy' tmp cfg '>nul'
say 'ramfs cfg done' done ifsfile params
