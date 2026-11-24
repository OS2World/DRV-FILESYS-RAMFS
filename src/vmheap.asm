; vmheap.asm - VM block routines of RAMFS (16-bit code, one 32-bit transfer routine).
;
; Original: $Id: vmheap.asm,v 1.4 2003/12/02 17:23:26 root Exp $ (Karl Olsen and maintainers), Public Domain.
; Ported from IBM ALP to Open Watcom WASM (see doc\CHANGES.md). Changes:
;  * the kernel hot-patch (_fix_kernel, _fix_kernel_npx) and the 3DNow!/MMX transfer routine are gone: they
;    patched kernel code of OS/2 14.088-14.095 by pattern and are not safe on newer kernels;
;    the plain DWORD transfer (the original fallback) is the only one;
;  * the 32-bit transfer routine is reached with a link-time far pointer (call far ptr FLAT:) instead of a
;    selector fetched from an undocumented kernel structure at run time;
;  * VMINIT does nothing any more (it is kept because init.c calls it).

.386p

extrn	_DevHlp:dword
extrn	_alloc_flags:dword
extrn	DOS32FLATDS:near

public	_threednow, _verify_memory
ifdef MAX_HEAP
public	_gcbHeapUsed, _gcbHeapMax, _gcVMBlocks, _gcVMFrees, _gcVMAllocs
endif

CONST	segment word public 'DATA' use16
CONST	ends
CONST2	segment word public 'DATA' use16
CONST2	ends

_DATA	segment word public 'DATA' use16
_threednow	dw 0
_verify_memory	dw 1
_DATA	ends

_BSS	segment word public 'BSS' use16
ifdef MAX_HEAP
_gcbHeapUsed	dd 0
_gcbHeapMax	dd 0c0000000h
_gcVMBlocks	dd 0
_gcVMFrees	dd 0
_gcVMAllocs	dd 0
endif
_BSS	ends

DGROUP	group CONST, CONST2, _DATA, _BSS

_TEXT32	segment word public 'CODE' use32

; The DWORD copy procedure (called with a 16:32 far call from the 16-bit routines below):
; DS:ESI = source, ES:EDI = destination, ECX = byte count.
ramfs_dword_transfer	proc far
	mov	ebx, ecx
	cld
	shr	ecx, 2
	and	ebx, 3
	rep	movsd
	mov	ecx, ebx
	rep	movsb
	retf
ramfs_dword_transfer	endp

_TEXT32	ends

_TEXT	segment word public 'CODE' use16

	assume es:nothing, ss:nothing, ds:DGROUP, fs:nothing, gs:nothing

	public	VMVIRTTOFLAT
	public	VMALLOC
	public	VMFREE
	public	VMREADUCHAR
	public	VMREADUSHORT
	public	VMREADBLK
	public	VMWRITEBLK
	public	VMREAD
	public	VMWRITE
	public	VMCOPY
	public	VMINIT


;-----------------------------------------------------------------------------
; FLAT _pascal VMVirtToFlat (void *p);
;-----------------------------------------------------------------------------

VMVIRTTOFLAT	proc near
	push	bp
	mov	bp, sp
	push	si

	movzx	esi, word ptr [bp+4]	; offset of p
	mov	ax, word ptr [bp+6]	; selector of p
	mov	dl, 5Bh			; _DevHlp_VirtToLin
	call	dword ptr [_DevHlp]
	jnc	vvtf_end
	xor	eax, eax
vvtf_end:

	shld	edx, eax, 16
	pop	si
	pop	bp
	ret	4
VMVIRTTOFLAT	endp




;-----------------------------------------------------------------------------
; FLAT _pascal VMAlloc (int fForce, ULONG cbSize);
;-----------------------------------------------------------------------------

VMALLOC	proc near
	push	bp
	mov	bp, sp

ifdef MAX_HEAP
    mov cx, [bp+8]      ; fForce
    or  cx, cx
    jnz va_ok
	mov	ecx, [bp+4]		; cbSize
    add ecx, _gcbHeapUsed
    cmp ecx, _gcbHeapMax
    jbe va_ok
    xor eax, eax
    jmp va_end
va_ok:
endif

	mov	ecx, [bp+4]		; cbSize
	mov	eax, _alloc_flags	; flags
	mov	dl, 57h			; _DevHlp_VMAlloc
	call	dword ptr [_DevHlp]
    jnc	va_alloced
	xor	eax, eax
    jmp va_end
va_alloced:
ifdef MAX_HEAP
	mov	ecx, [bp+4]		; cbSize
    add _gcbHeapUsed, ecx
    inc _gcVMAllocs
    inc _gcVMBlocks
endif
va_end:

	shld	edx, eax, 16
	pop	bp
	ret	6
VMALLOC	endp




;-----------------------------------------------------------------------------
; void _pascal VMFree (FLAT flatBlock, ULONG cbSize);
;-----------------------------------------------------------------------------

VMFREE	proc near
	push	bp
	mov	bp, sp

	mov	eax, [bp+8]		; flatBlock
    or eax, eax
    jz vf_end

	mov	dl, 58h			; _DevHlp_VMFree
	call	dword ptr [_DevHlp]
	jnc	vf_ok
ifdef DEBUG
; Bugs in error handling procedures means we shouldn't do this.
    int 3
endif
    jmp vf_end
vf_ok:
ifdef MAX_HEAP
    inc _gcVMFrees
    dec _gcVMBlocks
    mov ecx, [bp+4]
    cmp ecx, _gcbHeapUsed
    jg  vf_size_nok
    sub _gcbHeapUsed, ecx
vf_size_nok:
endif
vf_end:
	pop	bp
	ret 8
VMFREE	endp




;-----------------------------------------------------------------------------
; UCHAR _pascal VMReadUChar (FLAT flatSrc);
;-----------------------------------------------------------------------------

VMREADUCHAR	proc near
	push	bp
	mov	bp, sp
	mov	ax, offset DOS32FLATDS
	mov	es, ax

	mov	eax, [bp+4]		; flatSrc
	mov	al, es:[eax]

	pop	bp
	ret	4
VMREADUCHAR	endp




;-----------------------------------------------------------------------------
; USHORT _pascal VMReadUShort (FLAT flatSrc);
;-----------------------------------------------------------------------------

VMREADUSHORT	proc near
	push	bp
	mov	bp, sp
	mov	ax, offset DOS32FLATDS
	mov	es, ax

	mov	eax, [bp+4]		; flatSrc
	mov	ax, es:[eax]

	pop	bp
	ret	4
VMREADUSHORT	endp




;-----------------------------------------------------------------------------
; void _pascal VMReadBlk (BLOCK _ss *pBlk, FLAT flatBlk);
;-----------------------------------------------------------------------------

VMREADBLK	proc near
	push	bp
	mov	bp, sp
	push	ds
	mov	ax, offset DOS32FLATDS
	mov	es, ax

	mov	ebx, [bp+4]		; flatBlk
	mov	eax, es:[ebx+0]
	mov	edx, es:[ebx+4]
	lds	bx, dword ptr [bp+8]	; pBlk
	mov	ds:[bx+0], eax
	mov	ds:[bx+4], edx

	pop	ds
	pop	bp
	ret	8
VMREADBLK	endp




;-----------------------------------------------------------------------------
; void _pascal VMWriteBlk (FLAT flatBlk, BLOCK _ss *pBlk);
;-----------------------------------------------------------------------------

VMWRITEBLK	proc near
	push	bp
	mov	bp, sp
	push	ds
	mov	ax, offset DOS32FLATDS
	mov	es, ax

	lds	bx, dword ptr [bp+4]	; pBlk
	mov	eax, ds:[bx+0]
	mov	edx, ds:[bx+4]
	mov	ebx, [bp+8]		; flatBlk
	mov	es:[ebx+0], eax
	mov	es:[ebx+4], edx

	pop	ds
	pop	bp
	ret	8
VMWRITEBLK	endp




;-----------------------------------------------------------------------------
; void _pascal VMRead (void *pDest, FLAT flatSrc, USHORT cbLen);
;-----------------------------------------------------------------------------

VMREAD	proc near
	push	bp
	mov	bp, sp
	push    si
	push	di
	push	ds
	push	es

	sub	ecx, ecx
	mov	cx, [bp+4]		; number of bytes to copy
	xor	edi, edi
	mov	esi, [bp+6]		; source
	les	di, [bp+10]		; destination

	cmp	_verify_memory, 0
	jz	vmread_noverify
	jcxz	vmread_noverify
	mov	ax, es
	mov	dx, 127h		; DH_VerifyAccess && write access
	call	dword ptr [_DevHlp]
	jc	read_failed
vmread_noverify:
	mov	ax, offset DOS32FLATDS
	mov	ds, ax
	call	far ptr FLAT:ramfs_dword_transfer

read_failed:
	pop	es	
	pop	ds
	pop	di
	pop	si
	pop	bp
	ret	10
VMREAD	endp



;-----------------------------------------------------------------------------
; void _pascal VMWrite (FLAT flatDest, void *pSrc, USHORT cbLen);
;-----------------------------------------------------------------------------

VMWRITE	proc near
	push	bp
	mov	bp, sp
	push	si
	push	di
	push	ds
	push	es
	mov	ax, offset DOS32FLATDS
	mov	es, ax

	xor	esi, esi
	xor	ecx, ecx
	mov	cx, word ptr [bp+4]	; cbLen

	cmp	_verify_memory, 0
	jz	vmwrite_noverify
	jcxz	vmwrite_noverify
	mov	ax, [bp+8]		; pSrc/segment
	mov	di, [bp+6]		; pSrc/offset
	mov	dx, 27h			; DH_VerifyAccess && read access
	call	dword ptr [_DevHlp]
	jc	write_failed

vmwrite_noverify:
	lds	si, [bp+6]		; pSrc
	mov	edi, [bp+10]		; flatDest
	call	far ptr FLAT:ramfs_dword_transfer

write_failed:
	pop	es
	pop	ds
	pop	di
	pop	si
	pop	bp
	ret     10
VMWRITE	endp




;-----------------------------------------------------------------------------
; void _pascal VMCopy (FLAT flatDest, FLAT flatSrc, ULONG cbLen);
;-----------------------------------------------------------------------------

VMCOPY	proc near
	push	bp
	mov	bp, sp
	push	es
	push	ds
	push	si
	push	di
	mov	ax, offset DOS32FLATDS
	mov	es, ax
	mov	ds, ax

	mov	edi, [bp+12]		; flatDest
	mov	esi, [bp+8]		; flatSrc
	mov	ecx, [bp+4]     	; cbLen
	mov	edx, ecx
	cmp	edi, esi
	je	vc_end
	ja	vc_backwards

	; move forwards
	call	far ptr FLAT:ramfs_dword_transfer
	jmp	vc_end

vc_backwards:
	; move backwards
	lea	esi, [esi+ecx-1]
	lea	edi, [edi+ecx-1]
	and	ecx, 0003h
	std
	rep	movs byte ptr es:[edi], byte ptr es:[esi]
	sub	esi, 3
	sub	edi, 3
	mov	ecx, edx
	shr	ecx, 2
	rep	movs dword ptr es:[edi], dword ptr es:[esi]
	cld

vc_end:
	pop	di
	pop	si
	pop	ds
	pop	es
	pop	bp
	ret	12
VMCOPY	endp


; Nothing to initialise any more (the original planted a deferred kernel patch here).
VMINIT	proc	near
	ret
VMINIT	endp

_TEXT	ends

	end
