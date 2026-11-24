/* #define DEBUG */

#define INCL_DOSINFOSEG
#define INCL_ERRORS
#include <os2.h>

/* The original build (Microsoft C, -Alfu) loaded DS at every function entry. Open Watcom does not, so the
   FS_xxx entry points, which the kernel calls with an arbitrary DS, get an explicit _loadds. */
#undef  EXPENTRY
#define EXPENTRY pascal far _loadds

#define	 APIRET		USHORT

#include "fsd.h"
#include "fsh.h"
#include "ramfs.h"
#include "util.h"
#include "block.h"
#include "ea.h"
#include "nearheap.h"
#include "vmheap.h"
#include "find.h"
#include "info.h"

#include <string.h>
#include <dos.h>
