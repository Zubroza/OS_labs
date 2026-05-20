	.file	"factorial.cpp"
	.text
	.globl	_Z9factoriali
	.def	_Z9factoriali;	.scl	2;	.type	32;	.endef
	.seh_proc	_Z9factoriali
_Z9factoriali:
.LFB0:
	.seh_endprologue
	cmpl	$1, %ecx
	jle	.L4
	leal	1(%rcx), %ecx
	movl	$2, %eax
	movl	$1, %edx
	.p2align 4
.L3:
	imulq	%rax, %rdx
	addq	$1, %rax
	cmpq	%rcx, %rax
	jne	.L3
.L1:
	movq	%rdx, %rax
	ret
.L4:
	movl	$1, %edx
	jmp	.L1
	.seh_endproc
	.ident	"GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r3) 14.2.0"
