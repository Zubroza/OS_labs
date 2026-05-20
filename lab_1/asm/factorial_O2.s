	.file	"factorial.cpp"
	.text
	.p2align 4
	.globl	_Z9factoriali
	.def	_Z9factoriali;	.scl	2;	.type	32;	.endef
	.seh_proc	_Z9factoriali
_Z9factoriali:
.LFB0:
	.seh_endprologue
	cmpl	$1, %ecx
	jle	.L4
	leal	1(%rcx), %r8d
	movl	$2, %eax
	movl	$1, %edx
	testb	$1, %r8b
	je	.L3
	movl	$3, %eax
	movl	$2, %edx
	cmpq	%r8, %rax
	je	.L1
	.p2align 5
	.p2align 4
	.p2align 3
.L3:
	imulq	%rax, %rdx
	leaq	1(%rax), %rcx
	addq	$2, %rax
	imulq	%rcx, %rdx
	cmpq	%r8, %rax
	jne	.L3
.L1:
	movq	%rdx, %rax
	ret
	.p2align 4,,10
	.p2align 3
.L4:
	movl	$1, %edx
	movq	%rdx, %rax
	ret
	.seh_endproc
	.ident	"GCC: (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r3) 14.2.0"
