.text	

.globl	_pasta_add
.private_extern	_pasta_add

.p2align	5
_pasta_add:
.cfi_startproc
	.byte	0xf3,0x0f,0x1e,0xfa


	pushq	%rbp
.cfi_adjust_cfa_offset	8
.cfi_offset	%rbp,-16
	pushq	%rbx
.cfi_adjust_cfa_offset	8
.cfi_offset	%rbx,-24
	subq	$8,%rsp
.cfi_adjust_cfa_offset	8


	movq	0(%rsi),%r8
	movq	8(%rsi),%r9
	movq	16(%rsi),%r10
	movq	24(%rsi),%r11

L$oaded_a_pasta_add:
	addq	0(%rdx),%r8
	adcq	8(%rdx),%r9
	movq	%r8,%rax
	adcq	16(%rdx),%r10
	movq	%r9,%rsi
	adcq	24(%rdx),%r11
	sbbq	%rdx,%rdx

	movq	%r10,%rbx
	subq	0(%rcx),%r8
	sbbq	8(%rcx),%r9
	sbbq	16(%rcx),%r10
	movq	%r11,%rbp
	sbbq	24(%rcx),%r11
	sbbq	$0,%rdx

	cmovcq	%rax,%r8
	cmovcq	%rsi,%r9
	movq	%r8,0(%rdi)
	cmovcq	%rbx,%r10
	movq	%r9,8(%rdi)
	cmovcq	%rbp,%r11
	movq	%r10,16(%rdi)
	movq	%r11,24(%rdi)

	movq	8(%rsp),%rbx
.cfi_restore	%rbx
	movq	16(%rsp),%rbp
.cfi_restore	%rbp
	leaq	24(%rsp),%rsp
.cfi_adjust_cfa_offset	-24

	.byte	0xf3,0xc3
.cfi_endproc	



.globl	_pasta_cneg
.private_extern	_pasta_cneg

.p2align	5
_pasta_cneg:
.cfi_startproc
	.byte	0xf3,0x0f,0x1e,0xfa


	pushq	%rbp
.cfi_adjust_cfa_offset	8
.cfi_offset	%rbp,-16
	pushq	%rbx
.cfi_adjust_cfa_offset	8
.cfi_offset	%rbx,-24
	pushq	%r12
.cfi_adjust_cfa_offset	8
.cfi_offset	%r12,-32


	movq	0(%rsi),%r12
	movq	8(%rsi),%r9
	movq	16(%rsi),%r10
	movq	%r12,%r8
	movq	24(%rsi),%r11
	orq	%r9,%r12
	orq	%r10,%r12
	orq	%r11,%r12
	movq	$-1,%rbp

	movq	0(%rcx),%rax
	cmovnzq	%rbp,%r12
	movq	8(%rcx),%rsi
	movq	16(%rcx),%rbx
	andq	%r12,%rax
	movq	24(%rcx),%rbp
	andq	%r12,%rsi
	andq	%r12,%rbx
	andq	%r12,%rbp

	subq	%r8,%rax
	sbbq	%r9,%rsi
	sbbq	%r10,%rbx
	sbbq	%r11,%rbp

	orq	%rdx,%rdx

	cmovzq	%r8,%rax
	cmovzq	%r9,%rsi
	movq	%rax,0(%rdi)
	cmovzq	%r10,%rbx
	movq	%rsi,8(%rdi)
	cmovzq	%r11,%rbp
	movq	%rbx,16(%rdi)
	movq	%rbp,24(%rdi)

	movq	0(%rsp),%r12
.cfi_restore	%r12
	movq	8(%rsp),%rbx
.cfi_restore	%rbx
	movq	16(%rsp),%rbp
.cfi_restore	%rbp
	leaq	24(%rsp),%rsp
.cfi_adjust_cfa_offset	-24

	.byte	0xf3,0xc3
.cfi_endproc	



.globl	_pasta_sub
.private_extern	_pasta_sub

.p2align	5
_pasta_sub:
.cfi_startproc
	.byte	0xf3,0x0f,0x1e,0xfa


	pushq	%rbp
.cfi_adjust_cfa_offset	8
.cfi_offset	%rbp,-16
	pushq	%rbx
.cfi_adjust_cfa_offset	8
.cfi_offset	%rbx,-24
	subq	$8,%rsp
.cfi_adjust_cfa_offset	8


	movq	0(%rsi),%r8
	movq	8(%rsi),%r9
	movq	16(%rsi),%r10
	movq	24(%rsi),%r11

	subq	0(%rdx),%r8
	movq	0(%rcx),%rax
	sbbq	8(%rdx),%r9
	movq	8(%rcx),%rsi
	sbbq	16(%rdx),%r10
	movq	16(%rcx),%rbx
	sbbq	24(%rdx),%r11
	movq	24(%rcx),%rbp
	sbbq	%rdx,%rdx

	andq	%rdx,%rax
	andq	%rdx,%rsi
	andq	%rdx,%rbx
	andq	%rdx,%rbp

	addq	%rax,%r8
	adcq	%rsi,%r9
	movq	%r8,0(%rdi)
	adcq	%rbx,%r10
	movq	%r9,8(%rdi)
	adcq	%rbp,%r11
	movq	%r10,16(%rdi)
	movq	%r11,24(%rdi)

	movq	8(%rsp),%rbx
.cfi_restore	%rbx
	movq	16(%rsp),%rbp
.cfi_restore	%rbp
	leaq	24(%rsp),%rsp
.cfi_adjust_cfa_offset	-24

	.byte	0xf3,0xc3
.cfi_endproc	



.p2align	5
__lshift_mod_256:
.cfi_startproc
	.byte	0xf3,0x0f,0x1e,0xfa

	addq	%r8,%r8
	adcq	%r9,%r9
	movq	%r8,%rax
	adcq	%r10,%r10
	movq	%r9,%rsi
	adcq	%r11,%r11
	sbbq	%r12,%r12

	movq	%r10,%rbx
	subq	0(%rcx),%r8
	sbbq	8(%rcx),%r9
	sbbq	16(%rcx),%r10
	movq	%r11,%rbp
	sbbq	24(%rcx),%r11
	sbbq	$0,%r12

	cmovcq	%rax,%r8
	cmovcq	%rsi,%r9
	cmovcq	%rbx,%r10
	cmovcq	%rbp,%r11

	.byte	0xf3,0xc3
.cfi_endproc



.globl	_pasta_lshift
.private_extern	_pasta_lshift

.p2align	5
_pasta_lshift:
.cfi_startproc
	.byte	0xf3,0x0f,0x1e,0xfa


	pushq	%rbp
.cfi_adjust_cfa_offset	8
.cfi_offset	%rbp,-16
	pushq	%rbx
.cfi_adjust_cfa_offset	8
.cfi_offset	%rbx,-24
	pushq	%r12
.cfi_adjust_cfa_offset	8
.cfi_offset	%r12,-32


	movq	0(%rsi),%r8
	movq	8(%rsi),%r9
	movq	16(%rsi),%r10
	movq	24(%rsi),%r11

L$oop_lshift_mod_256:
	call	__lshift_mod_256
	decl	%edx
	jnz	L$oop_lshift_mod_256

	movq	%r8,0(%rdi)
	movq	%r9,8(%rdi)
	movq	%r10,16(%rdi)
	movq	%r11,24(%rdi)

	movq	0(%rsp),%r12
.cfi_restore	%r12
	movq	8(%rsp),%rbx
.cfi_restore	%rbx
	movq	16(%rsp),%rbp
.cfi_restore	%rbp
	leaq	24(%rsp),%rsp
.cfi_adjust_cfa_offset	-24

	.byte	0xf3,0xc3
.cfi_endproc	



.globl	_pasta_rshift
.private_extern	_pasta_rshift

.p2align	5
_pasta_rshift:
.cfi_startproc
	.byte	0xf3,0x0f,0x1e,0xfa


	pushq	%rbp
.cfi_adjust_cfa_offset	8
.cfi_offset	%rbp,-16
	pushq	%rbx
.cfi_adjust_cfa_offset	8
.cfi_offset	%rbx,-24
	subq	$8,%rsp
.cfi_adjust_cfa_offset	8


	movq	0(%rsi),%rbp
	movq	8(%rsi),%r9
	movq	16(%rsi),%r10
	movq	24(%rsi),%r11

L$oop_rshift_mod_256:
	movq	%rbp,%r8
	andq	$1,%rbp
	movq	0(%rcx),%rax
	negq	%rbp
	movq	8(%rcx),%rsi
	movq	16(%rcx),%rbx

	andq	%rbp,%rax
	andq	%rbp,%rsi
	andq	%rbp,%rbx
	andq	24(%rcx),%rbp

	addq	%rax,%r8
	adcq	%rsi,%r9
	adcq	%rbx,%r10
	adcq	%rbp,%r11
	sbbq	%rax,%rax

	shrq	$1,%r8
	movq	%r9,%rbp
	shrq	$1,%r9
	movq	%r10,%rbx
	shrq	$1,%r10
	movq	%r11,%rsi
	shrq	$1,%r11

	shlq	$63,%rbp
	shlq	$63,%rbx
	orq	%r8,%rbp
	shlq	$63,%rsi
	orq	%rbx,%r9
	shlq	$63,%rax
	orq	%rsi,%r10
	orq	%rax,%r11

	decl	%edx
	jnz	L$oop_rshift_mod_256

	movq	%rbp,0(%rdi)
	movq	%r9,8(%rdi)
	movq	%r10,16(%rdi)
	movq	%r11,24(%rdi)

	movq	8(%rsp),%rbx
.cfi_restore	%rbx
	movq	16(%rsp),%rbp
.cfi_restore	%rbp
	leaq	24(%rsp),%rsp
.cfi_adjust_cfa_offset	-24

	.byte	0xf3,0xc3
.cfi_endproc	

