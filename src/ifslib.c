/*
 * ifslib.c - the few C library routines RAMFS needs, written in plain C.
 *
 * The routines of the Open Watcom 16-bit library load DS from their far pointer arguments and leave it
 * changed, which a ring 0 file system driver must not do (the compiler assumes DS stays at DGROUP).
 * These versions use only far pointers and never touch DS.
 * Public Domain, like RAMFS.
 */

void far *memcpy (void far *d, const void far *s, unsigned int n)
{
  char far *dd = (char far *) d;
  const char far *ss = (const char far *) s;

  while (n--)
    *dd++ = *ss++;
  return d;
}

void far *memset (void far *d, int c, unsigned int n)
{
  char far *dd = (char far *) d;

  while (n--)
    *dd++ = (char) c;
  return d;
}

int memcmp (const void far *a, const void far *b, unsigned int n)
{
  const unsigned char far *aa = (const unsigned char far *) a;
  const unsigned char far *bb = (const unsigned char far *) b;

  while (n--)
  {
    if (*aa != *bb)
      return (int) *aa - (int) *bb;
    aa++;
    bb++;
  }
  return 0;
}

void far *memchr (const void far *s, int c, unsigned int n)
{
  const unsigned char far *p = (const unsigned char far *) s;

  while (n--)
  {
    if (*p == (unsigned char) c)
      return (void far *) p;
    p++;
  }
  return 0;
}

unsigned int strlen (const char far *s)
{
  unsigned int n = 0;

  while (s[n] != '\0')
    n++;
  return n;
}

char far *strcpy (char far *d, const char far *s)
{
  char far *dd = d;

  while ((*dd++ = *s++) != '\0')
    ;
  return d;
}

char far *strncpy (char far *d, const char far *s, unsigned int n)
{
  char far *dd = d;

  while (n && *s != '\0')
  {
    *dd++ = *s++;
    n--;
  }
  while (n--)
    *dd++ = '\0';
  return d;
}

int strcmp (const char far *a, const char far *b)
{
  while (*a != '\0' && *a == *b)
  {
    a++;
    b++;
  }
  return (int) (unsigned char) *a - (int) (unsigned char) *b;
}

char far *strstr (const char far *h, const char far *n)
{
  unsigned int i;

  if (*n == '\0')
    return (char far *) h;
  for (; *h != '\0'; h++)
  {
    for (i = 0; n[i] != '\0' && h[i] == n[i]; i++)
      ;
    if (n[i] == '\0')
      return (char far *) h;
  }
  return 0;
}

char far *strlwr (char far *s)
{
  char far *p = s;

  for (; *p != '\0'; p++)
    if (*p >= 'A' && *p <= 'Z')
      *p = (char) (*p + ('a' - 'A'));
  return s;
}

long atol (const char far *s)
{
  long v = 0;
  int neg = 0;

  while (*s == ' ' || *s == '\t')
    s++;
  if (*s == '-')
  {
    neg = 1;
    s++;
  }
  else if (*s == '+')
    s++;
  while (*s >= '0' && *s <= '9')
  {
    v = v * 10 + (*s - '0');
    s++;
  }
  return neg ? -v : v;
}
