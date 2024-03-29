#!/usr/bin/env perl
#
# Copyright Supranational LLC
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

$flavour = shift;
$output  = shift;
if ($flavour =~ /\./) { $output = $flavour; undef $flavour; }

$win64=0; $win64=1 if ($flavour =~ /[nm]asm|mingw64/ || $output =~ /\.asm$/);

$0 =~ m/(.*[\/\\])[^\/\\]+$/; $dir=$1;
( $xlate="${dir}x86_64-xlate.pl" and -f $xlate ) or
( $xlate="${dir}../../perlasm/x86_64-xlate.pl" and -f $xlate) or
die "can't locate x86_64-xlate.pl";

open STDOUT,"| \"$^X\" \"$xlate\" $flavour \"$output\""
    or die "can't call $xlate: $!";

# common argument layout
($r_ptr,$a_ptr,$b_org,$n_ptr) = ("%rdi","%rsi","%rdx","%rcx");
$b_ptr = "%rbx";

{ ############################################################## 256 bits add
my @acc=map("%r$_",(8..11, "ax", "si", "bx", "bp", 12));

$code.=<<___;
.text

.globl	pasta_add
.hidden	pasta_add
.type	pasta_add,\@function,4,"unwind"
.align	32
pasta_add:
.cfi_startproc
	push	%rbp
.cfi_push	%rbp
	push	%rbx
.cfi_push	%rbx
	sub	\$8, %rsp
.cfi_adjust_cfa_offset	8
.cfi_end_prologue

	mov	8*0($a_ptr), @acc[0]
	mov	8*1($a_ptr), @acc[1]
	mov	8*2($a_ptr), @acc[2]
	mov	8*3($a_ptr), @acc[3]

.Loaded_a_pasta_add:
	add	8*0($b_org), @acc[0]
	adc	8*1($b_org), @acc[1]
	 mov	@acc[0], @acc[4]
	adc	8*2($b_org), @acc[2]
	 mov	@acc[1], @acc[5]
	adc	8*3($b_org), @acc[3]
	sbb	$b_org, $b_org

	 mov	@acc[2], @acc[6]
	sub	8*0($n_ptr), @acc[0]
	sbb	8*1($n_ptr), @acc[1]
	sbb	8*2($n_ptr), @acc[2]
	 mov	@acc[3], @acc[7]
	sbb	8*3($n_ptr), @acc[3]
	sbb	\$0, $b_org

	cmovc	@acc[4], @acc[0]
	cmovc	@acc[5], @acc[1]
	mov	@acc[0], 8*0($r_ptr)
	cmovc	@acc[6], @acc[2]
	mov	@acc[1], 8*1($r_ptr)
	cmovc	@acc[7], @acc[3]
	mov	@acc[2], 8*2($r_ptr)
	mov	@acc[3], 8*3($r_ptr)

	mov	8(%rsp),%rbx
.cfi_restore	%rbx
	mov	16(%rsp),%rbp
.cfi_restore	%rbp
	lea	24(%rsp),%rsp
.cfi_adjust_cfa_offset	-24
.cfi_epilogue
	ret
.cfi_endproc
.size	pasta_add,.-pasta_add

########################################################################
.globl	pasta_cneg
.hidden	pasta_cneg
.type	pasta_cneg,\@function,4,"unwind"
.align	32
pasta_cneg:
.cfi_startproc
	push	%rbp
.cfi_push	%rbp
	push	%rbx
.cfi_push	%rbx
	push	%r12
.cfi_push	%r12
.cfi_end_prologue

	mov	8*0($a_ptr), @acc[8]	# load a[0:3]
	mov	8*1($a_ptr), @acc[1]
	mov	8*2($a_ptr), @acc[2]
	mov	@acc[8], @acc[0]
	mov	8*3($a_ptr), @acc[3]
	or	@acc[1], @acc[8]
	or	@acc[2], @acc[8]
	or	@acc[3], @acc[8]
	mov	\$-1, @acc[7]

	mov	8*0($n_ptr), @acc[4]	# load n[0:3]
	cmovnz	@acc[7], @acc[8]	# mask = a[0:3] ? -1 : 0
	mov	8*1($n_ptr), @acc[5]
	mov	8*2($n_ptr), @acc[6]
	and	@acc[8], @acc[4]	# n[0:3] &= mask
	mov	8*3($n_ptr), @acc[7]
	and	@acc[8], @acc[5]
	and	@acc[8], @acc[6]
	and	@acc[8], @acc[7]

	sub	@acc[0], @acc[4]	# a[0:3] ? n[0:3]-a[0:3] : 0-0
	sbb	@acc[1], @acc[5]
	sbb	@acc[2], @acc[6]
	sbb	@acc[3], @acc[7]

	or	$b_org, $b_org		# check condition flag

	cmovz	@acc[0], @acc[4]	# flag ? n[0:3]-a[0:3] : a[0:3]
	cmovz	@acc[1], @acc[5]
	mov	@acc[4], 8*0($r_ptr)
	cmovz	@acc[2], @acc[6]
	mov	@acc[5], 8*1($r_ptr)
	cmovz	@acc[3], @acc[7]
	mov	@acc[6], 8*2($r_ptr)
	mov	@acc[7], 8*3($r_ptr)

	mov	0(%rsp),%r12
.cfi_restore	%r12
	mov	8(%rsp),%rbx
.cfi_restore	%rbx
	mov	16(%rsp),%rbp
.cfi_restore	%rbp
	lea	24(%rsp),%rsp
.cfi_adjust_cfa_offset	-24
.cfi_epilogue
	ret
.cfi_endproc
.size	pasta_cneg,.-pasta_cneg

########################################################################
.globl	pasta_sub
.hidden	pasta_sub
.type	pasta_sub,\@function,4,"unwind"
.align	32
pasta_sub:
.cfi_startproc
	push	%rbp
.cfi_push	%rbp
	push	%rbx
.cfi_push	%rbx
	sub	\$8, %rsp
.cfi_adjust_cfa_offset	8
.cfi_end_prologue

	mov	8*0($a_ptr), @acc[0]
	mov	8*1($a_ptr), @acc[1]
	mov	8*2($a_ptr), @acc[2]
	mov	8*3($a_ptr), @acc[3]

	sub	8*0($b_org), @acc[0]
	 mov	8*0($n_ptr), @acc[4]
	sbb	8*1($b_org), @acc[1]
	 mov	8*1($n_ptr), @acc[5]
	sbb	8*2($b_org), @acc[2]
	 mov	8*2($n_ptr), @acc[6]
	sbb	8*3($b_org), @acc[3]
	 mov	8*3($n_ptr), @acc[7]
	sbb	$b_org, $b_org

	and	$b_org, @acc[4]
	and	$b_org, @acc[5]
	and	$b_org, @acc[6]
	and	$b_org, @acc[7]

	add	@acc[4], @acc[0]
	adc	@acc[5], @acc[1]
	mov	@acc[0], 8*0($r_ptr)
	adc	@acc[6], @acc[2]
	mov	@acc[1], 8*1($r_ptr)
	adc	@acc[7], @acc[3]
	mov	@acc[2], 8*2($r_ptr)
	mov	@acc[3], 8*3($r_ptr)

	mov	8(%rsp),%rbx
.cfi_restore	%rbx
	mov	16(%rsp),%rbp
.cfi_restore	%rbp
	lea	24(%rsp),%rsp
.cfi_adjust_cfa_offset	-24
.cfi_epilogue
	ret
.cfi_endproc
.size	pasta_sub,.-pasta_sub

.type	__lshift_mod_256,\@abi-omnipotent
.align	32
__lshift_mod_256:
	add	@acc[0], @acc[0]
	adc	@acc[1], @acc[1]
	 mov	@acc[0], @acc[4]
	adc	@acc[2], @acc[2]
	 mov	@acc[1], @acc[5]
	adc	@acc[3], @acc[3]
	sbb	@acc[8], @acc[8]

	 mov	@acc[2], @acc[6]
	sub	8*0($n_ptr), @acc[0]
	sbb	8*1($n_ptr), @acc[1]
	sbb	8*2($n_ptr), @acc[2]
	 mov	@acc[3], @acc[7]
	sbb	8*3($n_ptr), @acc[3]
	sbb	\$0, @acc[8]

	cmovc	@acc[4], @acc[0]
	cmovc	@acc[5], @acc[1]
	cmovc	@acc[6], @acc[2]
	cmovc	@acc[7], @acc[3]

	ret
.size	__lshift_mod_256,.-__lshift_mod_256

########################################################################
.globl	pasta_lshift
.hidden	pasta_lshift
.type	pasta_lshift,\@function,4,"unwind"
.align	32
pasta_lshift:
.cfi_startproc
	push	%rbp
.cfi_push	%rbp
	push	%rbx
.cfi_push	%rbx
	push	%r12
.cfi_push	%r12
.cfi_end_prologue

	mov	8*0($a_ptr), @acc[0]
	mov	8*1($a_ptr), @acc[1]
	mov	8*2($a_ptr), @acc[2]
	mov	8*3($a_ptr), @acc[3]

.Loop_lshift_mod_256:
	call	__lshift_mod_256
	dec	%edx
	jnz	.Loop_lshift_mod_256

	mov	@acc[0], 8*0($r_ptr)
	mov	@acc[1], 8*1($r_ptr)
	mov	@acc[2], 8*2($r_ptr)
	mov	@acc[3], 8*3($r_ptr)

	mov	0(%rsp),%r12
.cfi_restore	%r12
	mov	8(%rsp),%rbx
.cfi_restore	%rbx
	mov	16(%rsp),%rbp
.cfi_restore	%rbp
	lea	24(%rsp),%rsp
.cfi_adjust_cfa_offset	-24
.cfi_epilogue
	ret
.cfi_endproc
.size	pasta_lshift,.-pasta_lshift

########################################################################
.globl	pasta_rshift
.hidden	pasta_rshift
.type	pasta_rshift,\@function,4,"unwind"
.align	32
pasta_rshift:
.cfi_startproc
	push	%rbp
.cfi_push	%rbp
	push	%rbx
.cfi_push	%rbx
	sub	\$8, %rsp
.cfi_adjust_cfa_offset	8
.cfi_end_prologue

	mov	8*0($a_ptr), @acc[7]
	mov	8*1($a_ptr), @acc[1]
	mov	8*2($a_ptr), @acc[2]
	mov	8*3($a_ptr), @acc[3]

.Loop_rshift_mod_256:
	mov	@acc[7], @acc[0]
	and	\$1, @acc[7]
	mov	8*0($n_ptr), @acc[4]
	neg	@acc[7]
	mov	8*1($n_ptr), @acc[5]
	mov	8*2($n_ptr), @acc[6]

	and	@acc[7], @acc[4]
	and	@acc[7], @acc[5]
	and	@acc[7], @acc[6]
	and	8*3($n_ptr), @acc[7]

	add	@acc[4], @acc[0]
	adc	@acc[5], @acc[1]
	adc	@acc[6], @acc[2]
	adc	@acc[7], @acc[3]
	sbb	@acc[4], @acc[4]

	shr	\$1, @acc[0]
	mov	@acc[1], @acc[7]
	shr	\$1, @acc[1]
	mov	@acc[2], @acc[6]
	shr	\$1, @acc[2]
	mov	@acc[3], @acc[5]
	shr	\$1, @acc[3]

	shl	\$63, @acc[7]
	shl	\$63, @acc[6]
	or	@acc[0], @acc[7]
	shl	\$63, @acc[5]
	or	@acc[6], @acc[1]
	shl	\$63, @acc[4]
	or	@acc[5], @acc[2]
	or	@acc[4], @acc[3]

	dec	%edx
	jnz	.Loop_rshift_mod_256

	mov	@acc[7], 8*0($r_ptr)
	mov	@acc[1], 8*1($r_ptr)
	mov	@acc[2], 8*2($r_ptr)
	mov	@acc[3], 8*3($r_ptr)

	mov	8(%rsp),%rbx
.cfi_restore	%rbx
	mov	16(%rsp),%rbp
.cfi_restore	%rbp
	lea	24(%rsp),%rsp
.cfi_adjust_cfa_offset	-24
.cfi_epilogue
	ret
.cfi_endproc
.size	pasta_rshift,.-pasta_rshift
___
}

print $code;
close STDOUT;
