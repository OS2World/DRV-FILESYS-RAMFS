/*
 * fsd.h - kernel records and constants of the OS/2 installable file system (IFS) interface
 *
 * Copyright (c) 2026 OS2World.
 * Released into the public domain,
 * like the rest of RAMFS (public domain; written by OS2World, who holds the rights).
 *
 * Clean-room replacement: written from public documentation, see doc/PROVENANCE.md of the RAMFS project.
 * The structure and constant groups were first written for the HFS/2 port (OS2World,
 * 2026), where they were verified by mounting, reading and writing a volume on ArcaOS;
 * they were completed here from the IFS reference documentation.
 *
 * This header holds the records the kernel hands to the FS_xxx entry points and the
 * value groups of those entry points. It does NOT declare the FS_xxx functions: the
 * driver sources define them with their own argument lists.
 *
 * Constants of the compiler's own OS/2 headers (FILE_*, OPEN_*, FSIL_*, FSCTL_HANDLE,
 * FSCTL_PATHNAME, FSCTL_FSDNAME, CCHMAXPATH, ...) are not repeated.
 */

#ifndef RAMFS_FSD_H_INCLUDED
#define RAMFS_FSD_H_INCLUDED

#ifndef CCHMAXPATH
#define CCHMAXPATH 260
#endif

/* ------------------------------------------------------------------ */
/* Bits of the exported FS_ATTRIBUTE doubleword                         */
/* ------------------------------------------------------------------ */

#define FSA_REMOTE      0x00000001UL    /* driver talks to a remote machine   */
#define FSA_UNC         0x00000002UL    /* driver understands UNC names       */
#define FSA_LOCK        0x00000004UL    /* driver wants byte-range lock calls */
#define FSA_LVL7        0x00000008UL    /* driver answers path-info level 7   */
#define FSA_PSVR        0x00000010UL    /* driver manages remote named pipes  */
/* UNVERIFIED: the 1993 IFS reference predates this bit; the value is the one used
   by other open-source OS/2 file system drivers. */
#define FSA_LARGEFILE   0x00000020UL    /* driver supports files over 2 GB    */

/* ------------------------------------------------------------------ */
/* Sizes of the driver-private work areas the kernel reserves           */
/* ------------------------------------------------------------------ */

#define CDDWORKAREASIZE   8         /* per current-directory record */
#define SFDWORKAREASIZE  30         /* per open file                */
#define VPDWORKAREASIZE  36         /* per mounted volume           */
#define FSFSD_WORK_SIZE  24         /* per directory search         */

#pragma pack(push, 1)

/* ------------------------------------------------------------------ */
/* Volume parameters                                                    */
/* ------------------------------------------------------------------ */

#define VPBTEXTLEN 12

struct vpfsi {                      /* kernel-owned part                    */
    unsigned long  vpi_vid;         /* volume serial number                 */
    unsigned long  vpi_hDEV;        /* device driver handle                 */
    unsigned short vpi_bsize;       /* bytes per sector                     */
    unsigned long  vpi_totsec;      /* sectors on the volume                */
    unsigned short vpi_trksec;      /* sectors per track                    */
    unsigned short vpi_nhead;       /* heads                                */
    char           vpi_text[VPBTEXTLEN]; /* volume label                    */
    void far      *vpi_pDCS;        /* 16:16 pointer to the driver capabilities structure */
    void far      *vpi_pVCS;        /* 16:16 pointer to the volume characteristics structure */
    unsigned char  vpi_drive;       /* drive letter index, A = 0            */
    unsigned char  vpi_unit;        /* unit within the device driver        */
    /* UNVERIFIED (size only): later kernels append a flags word; the driver sources
       do not touch it. */
    unsigned short vpi_flags;       /* memory-capability flags (VPB_*)      */
};

#define VPB_ABOVE16M_ALLOWED   0x0001   /* device may use memory above 16 MB  */
#define VPB_NONCONTIG_ALLOWED  0x0002   /* FSD copes with discontiguous I/O   */

#define UNREAD_ID   0x534E4A52UL    /* volume id marking unreadable media */
#define DAMAGED_ID  0x00000000UL    /* volume id marking a damaged volume */

struct vpfsd;                      /* driver-private volume area: defined by the driver (ramfs.h) */

/* ------------------------------------------------------------------ */
/* Current directory                                                    */
/* ------------------------------------------------------------------ */

struct cdfsi {
    unsigned short cdi_hVPB;        /* volume handle                        */
    unsigned short cdi_end;         /* length of the root part of the path  */
    char           cdi_flags;       /* CDI_* state bits                     */
    char           cdi_curdir[CCHMAXPATH]; /* current directory text        */
};

#define CDI_ISVALID    0x80
#define CDI_ISROOT     0x40
#define CDI_ISCURRENT  0x20

struct cdfsd;                      /* driver-private current directory area (ramfs.h) */

/* ------------------------------------------------------------------ */
/* Open file (system file table entry)                                  */
/* ------------------------------------------------------------------ */

struct sffsi {
    unsigned long  sfi_mode;        /* access and sharing mode              */
    unsigned short sfi_hVPB;        /* volume handle                        */
    unsigned short sfi_ctime;       /* creation time                        */
    unsigned short sfi_cdate;       /* creation date                        */
    unsigned short sfi_atime;       /* last access time                     */
    unsigned short sfi_adate;       /* last access date                     */
    unsigned short sfi_mtime;       /* last write time                      */
    unsigned short sfi_mdate;       /* last write date                      */
    unsigned long  sfi_size;        /* length in bytes                      */
    unsigned long  sfi_position;    /* file pointer                         */
    unsigned short sfi_UID;         /* user id of first opener              */
    unsigned short sfi_PID;         /* process id of first opener           */
    unsigned short sfi_PDB;         /* DOS-box process block of first opener*/
    unsigned short sfi_selfsfn;     /* this entry's own file number         */
    unsigned char  sfi_tstamp;      /* ST_* timestamp request bits          */
    unsigned short sfi_type;        /* STYPE_* kind of object               */
    unsigned long  sfi_pPVDBFil;    /* performance counter block pointer    */
    unsigned char  sfi_DOSattr;     /* DOS attribute byte                   */
    LONGLONG       sfi_sizel;       /* 64-bit length (the compiler's OS/2 headers define LONGLONG) */
    LONGLONG       sfi_positionl;   /* 64-bit file pointer                  */
};

#define ST_SCREAT   0x01            /* stamp creation time          */
#define ST_PCREAT   0x02            /* propagate creation time      */
#define ST_SWRITE   0x04            /* stamp last-write time        */
#define ST_PWRITE   0x08            /* propagate last-write time    */
#define ST_SREAD    0x10            /* stamp last-access time       */
#define ST_PREAD    0x20            /* propagate last-access time   */

#define STYPE_FILE    0
#define STYPE_DEVICE  1
#define STYPE_NMPIPE  2
#define STYPE_FCB     4

struct sffsd;                      /* driver-private open file area (ramfs.h) */

/* ------------------------------------------------------------------ */
/* Directory search                                                     */
/* ------------------------------------------------------------------ */

struct fsfsi {
    unsigned short fsi_hVPB;
};

struct fsfsd;                      /* driver-private search area (ramfs.h) */

/* ------------------------------------------------------------------ */
/* Byte-range lock record (FS_FILELOCKS / FS_CANCELLOCKREQUEST)         */
/* ------------------------------------------------------------------ */

/* UNVERIFIED: layout taken from the user-level lock record of DosSetFileLocks. */
struct filelock {
    long lOffset;                   /* start of range */
    long lRange;                    /* length of range */
};

/* ------------------------------------------------------------------ */
/* FS_FSCTL argument block                                              */
/* ------------------------------------------------------------------ */

struct SF {                         /* iArgType == FSCTL_ARG_FILEINSTANCE */
    struct sffsi far *psffsi;
    struct sffsd far *psffsd;
};

struct CD {                         /* iArgType == FSCTL_ARG_CURDIR */
    struct cdfsi far *pcdfsi;
    struct cdfsd far *pcdfsd;
    char far         *pPath;
    unsigned short    iCurDirEnd;
};

union argdat {                      /* iArgType == FSCTL_ARG_NULL: unused */
    struct SF sf;
    struct CD cd;
};

/* ------------------------------------------------------------------ */
/* FS_DOPAGEIO command list                                             */
/* ------------------------------------------------------------------ */

struct PageCmd {
    unsigned char Cmd;              /* read / write / write-verify          */
    unsigned char Priority;
    unsigned char Status;           /* PGIO_ATTEMPTED / PGIO_FAILED         */
    unsigned char Error;            /* error code for this transfer         */
    unsigned long Addr;             /* physical or 16:16 virtual address    */
    unsigned long FileOffset;       /* page-aligned offset in the page file */
};

struct PageCmdHeader {
    unsigned char InFlags;          /* PGIO_FI_* */
    unsigned char OutFlags;         /* PGIO_FO_*, must be zero on entry */
    unsigned char OpCount;          /* number of entries that follow */
    unsigned char Pad;
    unsigned long Reserved1;
    unsigned long Reserved2;
    unsigned long Reserved3;
    struct PageCmd PageCmdList[1];
};

/* ------------------------------------------------------------------ */
/* FS_FILEIO command list (layouts from the IFS reference, FS_FILEIO)   */
/* ------------------------------------------------------------------ */

#define FILEIO_LOCK     0           /* Cmd values */
#define FILEIO_UNLOCK   1
#define FILEIO_SEEK     2
#define FILEIO_READ     3
#define FILEIO_WRITE    4

struct CmdLock {                    /* followed by LockCnt struct Lock records */
    unsigned short Cmd;
    unsigned short LockCnt;
    unsigned long  TimeOut;         /* ms; 0 no wait, 0xFFFFFFFF wait forever  */
};

struct Lock {
    unsigned short Share;           /* 0 exclusive, 1 read-only for others */
    long           Start;
    long           Length;
};

struct CmdUnLock {                  /* followed by UnlockCnt struct UnLock records */
    unsigned short Cmd;
    unsigned short UnlockCnt;
};

struct UnLock {
    long Start;
    long Length;
};

struct CmdSeek {
    unsigned short Cmd;
    unsigned short Method;          /* 0 absolute, 1 relative to current, 2 relative to end */
    long           Position;
    long           Actual;
};

struct CmdIO {
    unsigned short Cmd;             /* FILEIO_READ or FILEIO_WRITE */
    void far      *Buffer;
    unsigned short BufferLen;
    unsigned short Actual;
};

/* UNVERIFIED: 64-bit lock record of FS_FILELOCKSL / FS_CANCELLOCKREQUESTL;
   the field names are the ones the driver sources use, the layout is two 64-bit
   values (offset, length) like struct filelock. */
struct filelockl {
    LONGLONG FileOffset;
    LONGLONG RangeLength;
};

#pragma pack(pop)

#define PGIO_FI_ORDER   0x01
#define PGIO_FO_DONE    0x01
#define PGIO_FO_ERROR   0x02
#define PGIO_ATTEMPTED  0x0F
#define PGIO_FAILED     0xF0

/* flags for the *pFlags word of FS_OPENPAGEFILE */
#define PGIO_FIRSTOPEN  0x00000001UL
#define PGIO_PADDR      0x00004000UL
#define PGIO_VADDR      0x00008000UL

/* ------------------------------------------------------------------ */
/* Parameter value groups, one block per entry point                    */
/* ------------------------------------------------------------------ */

#define IOFL_WRITETHRU  0x10        /* IOflag: write through the cache */
#define IOFL_NOCACHE    0x20        /* IOflag: do not cache the data   */

#define FSA_ATTACH       0x00       /* FS_ATTACH flag values */
#define FSA_DETACH       0x01
#define FSA_ATTACH_INFO  0x02

#define CD_EXPLICIT  0x00           /* FS_CHDIR flag values */
#define CD_VERIFY    0x01
#define CD_FREE      0x02

#define CFP_RELBEGIN  0x00          /* FS_CHGFILEPTR origin values */
#define CFP_RELCUR    0x01
#define CFP_RELEND    0x02

#define FS_CL_ORDINARY  0           /* FS_CLOSE type values */
#define FS_CL_FORPROC   1
#define FS_CL_FORSYS    2

#define FS_COMMIT_ONE   1           /* FS_COMMIT type values */
#define FS_COMMIT_ALL   2

#define FA_RETRIEVE  0x00           /* FS_FILEATTRIBUTE flag values */
#define FA_SET       0x01

#define FI_RETRIEVE  0x00           /* FS_FILEINFO flag values */
#define FI_SET       0x01

#define FF_NOPOS  0x00              /* FS_FIND* position-return flag */
#define FF_GETPOS 0x01

#define FLUSH_RETAIN   0x00         /* FS_FLUSHBUF flag values */
#define FLUSH_DISCARD  0x01

#define FSCTL_ARG_FILEINSTANCE  0x01    /* FS_FSCTL iArgType values */
#define FSCTL_ARG_CURDIR        0x02
#define FSCTL_ARG_NULL          0x03

#define FSCTL_FUNC_NONE      0x00   /* FS_FSCTL function values */
#define FSCTL_FUNC_NEW_INFO  0x01
#define FSCTL_FUNC_EASIZE    0x02

#define INFO_RETRIEVE  0x00         /* FS_FSINFO flag values */
#define INFO_RETREIVE  0x00         /* historical misspelling, same value */
#define INFO_SET       0x01

#define MOUNT_MOUNT        0x00     /* FS_MOUNT flag values */
#define MOUNT_VOL_REMOVED  0x01
#define MOUNT_RELEASE      0x02
#define MOUNT_ACCEPT       0x03

#define FOC_NEEDEAS  0x01           /* FS_OPENCREATE *pfgenflag bit */

#define PI_RETRIEVE  0x00           /* FS_PATHINFO flag values */
#define PI_SET       0x01

#define SD_BEGIN     0x00           /* FS_SHUTDOWN type values */
#define SD_COMPLETE  0x01

#define VUN_PASS1  0x0000           /* FS_VERIFYUNCNAME flag values */
#define VUN_PASS2  0x0001

#endif /* RAMFS_FSD_H_INCLUDED */
