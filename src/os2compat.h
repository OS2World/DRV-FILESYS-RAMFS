/*
 * os2compat.h - constants of the 32-bit OS/2 toolkit that the original source takes from the IBM DDK headers
 * and that the 16-bit OS/2 1.x headers of Open Watcom (h\os21x) do not have. Forced into every source file by
 * Makefile.wat (-fi=), so the original source files stay unchanged.
 * Public Domain, like RAMFS.
 */
#ifndef RAMFS_OS2COMPAT_H_INCLUDED
#define RAMFS_OS2COMPAT_H_INCLUDED

#ifndef ERROR_HANDLE_EOF
#define ERROR_HANDLE_EOF        38
#endif

/* DosQueryPathInfo / DosQueryFileInfo levels */
#ifndef FIL_STANDARD
#define FIL_STANDARD            1
#define FIL_QUERYEASIZE         2
#define FIL_QUERYEASFROMLIST    3
#define FIL_QUERYFULLNAME       5
#define FIL_NAMEISVALID         6
#endif

/* FS_FSCTL argument types */
#ifndef FSCTL_HANDLE
#define FSCTL_HANDLE            1
#define FSCTL_PATHNAME          2
#define FSCTL_FSDNAME           3
#endif

/* 64-bit integer (low word first): the 16-bit OS/2 1.x headers do not define it */
#ifndef RAMFS_LONGLONG_DEFINED
#define RAMFS_LONGLONG_DEFINED
typedef struct _RAMFS_LONGLONG {
   unsigned long ulLo;
   long          lHi;
} LONGLONG;
typedef LONGLONG far *PLONGLONG;
#endif

#endif
