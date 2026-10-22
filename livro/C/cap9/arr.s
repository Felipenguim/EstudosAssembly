	.file	"arr.c"
	.intel_syntax noprefix
	.text
	.section .rdata,"dr"
	.align 8
.LC0:
	.ascii "A soma dos elementos do array eh: %d\0"
	.text
	.globl	sum_array
	.def	sum_array;	.scl	2;	.type	32;	.endef
	.seh_proc	sum_array
sum_array:
	push	rbp
	.seh_pushreg	rbp
	mov	rbp, rsp
	.seh_setframe	rbp, 0
	sub	rsp, 48
	.seh_stackalloc	48
	.seh_endprologue
	mov	QWORD PTR 16[rbp], rcx
	mov	QWORD PTR 24[rbp], rdx
	mov	DWORD PTR -4[rbp], 0
	mov	QWORD PTR -16[rbp], 0
	jmp	.L2
.L3:
	mov	rax, QWORD PTR -16[rbp]
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR 16[rbp]
	add	rax, rdx
	mov	eax, DWORD PTR [rax]
	add	DWORD PTR -4[rbp], eax
	add	QWORD PTR -16[rbp], 1
.L2:
	mov	rax, QWORD PTR -16[rbp]
	cmp	rax, QWORD PTR 24[rbp]
	jb	.L3
	mov	eax, DWORD PTR -4[rbp]
	mov	edx, eax
	lea	rax, .LC0[rip]
	mov	rcx, rax
	call	printf
	nop
	add	rsp, 48
	pop	rbp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	push	rbp
	.seh_pushreg	rbp
	mov	rbp, rsp
	.seh_setframe	rbp, 0
	sub	rsp, 64
	.seh_stackalloc	64
	.seh_endprologue
	mov	DWORD PTR 16[rbp], ecx
	mov	QWORD PTR 24[rbp], rdx
	call	__main
	mov	DWORD PTR -32[rbp], 10
	mov	DWORD PTR -28[rbp], 10
	mov	DWORD PTR -24[rbp], 23
	mov	DWORD PTR -20[rbp], 45
	mov	DWORD PTR -16[rbp], 32
	mov	QWORD PTR -8[rbp], 5
	mov	rdx, QWORD PTR -8[rbp]
	lea	rax, -32[rbp]
	mov	rcx, rax
	call	sum_array
	mov	eax, 0
	add	rsp, 64
	pop	rbp
	ret
	.seh_endproc
	.ident	"GCC: (x86_64-posix-seh-rev0, Built by MinGW-Builds project) 13.2.0"
	.def	printf;	.scl	2;	.type	32;	.endef
