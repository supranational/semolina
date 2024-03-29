#!/usr/bin/env perl
#
# Copyright Supranational LLC
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

$flavour = shift;
$output  = shift;

if ($flavour && $flavour ne "void") {
    $0 =~ m/(.*[\/\\])[^\/\\]+$/; $dir=$1;
    ( $xlate="${dir}arm-xlate.pl" and -f $xlate ) or
    ( $xlate="${dir}../../perlasm/arm-xlate.pl" and -f $xlate) or
    die "can't locate arm-xlate.pl";

    open STDOUT,"| \"$^X\" $xlate $flavour $output";
} else {
    open STDOUT,">$output";
}

($r_ptr,$a_ptr,$b_ptr,$n_ptr) = map("x$_", 0..3);

@mod=map("x$_",(4..7));
@a=map("x$_",(8..11));
@b=map("x$_",(12..15));
@t=map("x$_",(16,17,1..3));

$code.=<<___;
.text

.globl	pasta_add
.hidden	pasta_add
.type	pasta_add,%function
.align	5
pasta_add:
	ldp	@a[0],@a[1],[$a_ptr]
	ldp	@b[0],@b[1],[$b_ptr]

	 ldp	@a[2],@a[3],[$a_ptr,#16]
	adds	@a[0],@a[0],@b[0]
	 ldp	@b[2],@b[3],[$b_ptr,#16]
	adcs	@a[1],@a[1],@b[1]
	 ldp	@mod[0],@mod[1],[$n_ptr]
	adcs	@a[2],@a[2],@b[2]
	 ldp	@mod[2],@mod[3],[$n_ptr,#16]
	adcs	@a[3],@a[3],@b[3]
	adc	@t[4],xzr,xzr

	subs	@t[0],@a[0],@mod[0]
	sbcs	@t[1],@a[1],@mod[1]
	sbcs	@t[2],@a[2],@mod[2]
	sbcs	@t[3],@a[3],@mod[3]
	sbcs	xzr,@t[4],xzr

	csel	@a[0],@a[0],@t[0],lo
	csel	@a[1],@a[1],@t[1],lo
	csel	@a[2],@a[2],@t[2],lo
	stp	@a[0],@a[1],[$r_ptr]
	csel	@a[3],@a[3],@t[3],lo
	stp	@a[2],@a[3],[$r_ptr,#16]

	ret
.size	pasta_add,.-pasta_add

.globl	pasta_cneg
.hidden	pasta_cneg
.type	pasta_cneg,%function
.align	5
pasta_cneg:
	ldp	@a[0],@a[1],[$a_ptr]
	ldp	@mod[0],@mod[1],[$n_ptr]

	 ldp	@a[2],@a[3],[$a_ptr,#16]
	subs	@b[0],@mod[0],@a[0]
	 ldp	@mod[2],@mod[3],[$n_ptr,#16]
	 orr	@mod[0],@a[0],@a[1]
	sbcs	@b[1],@mod[1],@a[1]
	 orr	@mod[1],@a[2],@a[3]
	sbcs	@b[2],@mod[2],@a[2]
	 orr	@t[4],@mod[0],@mod[1]
	sbc	@b[3],@mod[3],@a[3]

	cmp	@t[4],#0
	csetm	@t[4],ne
	ands	$b_ptr,$b_ptr,@t[4]

	csel	@a[0],@a[0],@b[0],eq
	csel	@a[1],@a[1],@b[1],eq
	csel	@a[2],@a[2],@b[2],eq
	stp	@a[0],@a[1],[$r_ptr]
	csel	@a[3],@a[3],@b[3],eq
	stp	@a[2],@a[3],[$r_ptr,#16]

	ret
.size	pasta_cneg,.-pasta_cneg

.globl	pasta_sub
.hidden	pasta_sub
.type	pasta_sub,%function
.align	5
pasta_sub:
	ldp	@a[0],@a[1],[$a_ptr]
	ldp	@b[0],@b[1],[$b_ptr]

	 ldp	@a[2],@a[3],[$a_ptr,#16]
	subs	@a[0],@a[0],@b[0]
	 ldp	@b[2],@b[3],[$b_ptr,#16]
	sbcs	@a[1],@a[1],@b[1]
	 ldp	@mod[0],@mod[1],[$n_ptr]
	sbcs	@a[2],@a[2],@b[2]
	 ldp	@mod[2],@mod[3],[$n_ptr,#16]
	sbcs	@a[3],@a[3],@b[3]
	sbc	@t[4],xzr,xzr

	 and	@mod[0],@mod[0],@t[4]
	 and	@mod[1],@mod[1],@t[4]
	adds	@a[0],@a[0],@mod[0]
	 and	@mod[2],@mod[2],@t[4]
	adcs	@a[1],@a[1],@mod[1]
	 and	@mod[3],@mod[3],@t[4]
	adcs	@a[2],@a[2],@mod[2]
	stp	@a[0],@a[1],[$r_ptr]
	adc	@a[3],@a[3],@mod[3]
	stp	@a[2],@a[3],[$r_ptr,#16]

	ret
.size	pasta_sub,.-pasta_sub

.globl	pasta_lshift
.hidden	pasta_lshift
.type	pasta_lshift,%function
.align	5
pasta_lshift:
	ldp	@a[0],@a[1],[$a_ptr]
	ldp	@a[2],@a[3],[$a_ptr,#16]

	ldp	@mod[0],@mod[1],[$n_ptr]
	ldp	@mod[2],@mod[3],[$n_ptr,#16]

.Loop_lshift_mod_256:
	adds	@a[0],@a[0],@a[0]
	sub	$b_ptr,$b_ptr,#1
	adcs	@a[1],@a[1],@a[1]
	adcs	@a[2],@a[2],@a[2]
	adcs	@a[3],@a[3],@a[3]
	adc	@t[4],xzr,xzr

	subs	@b[0],@a[0],@mod[0]
	sbcs	@b[1],@a[1],@mod[1]
	sbcs	@b[2],@a[2],@mod[2]
	sbcs	@b[3],@a[3],@mod[3]
	sbcs	xzr,@t[4],xzr

	csel	@a[0],@a[0],@b[0],lo
	csel	@a[1],@a[1],@b[1],lo
	csel	@a[2],@a[2],@b[2],lo
	csel	@a[3],@a[3],@b[3],lo

	cbnz	$b_ptr,.Loop_lshift_mod_256

	stp	@a[0],@a[1],[$r_ptr]
	stp	@a[2],@a[3],[$r_ptr,#16]

	ret
.size	pasta_lshift,.-pasta_lshift

.globl	pasta_rshift
.hidden	pasta_rshift
.type	pasta_rshift,%function
.align	5
pasta_rshift:
	ldp	@a[0],@a[1],[$a_ptr]
	ldp	@a[2],@a[3],[$a_ptr,#16]

	ldp	@mod[0],@mod[1],[$n_ptr]
	ldp	@mod[2],@mod[3],[$n_ptr,#16]

.Loop_rshift:
	adds	@b[0],@a[0],@mod[0]
	sub	$b_ptr,$b_ptr,#1
	adcs	@b[1],@a[1],@mod[1]
	adcs	@b[2],@a[2],@mod[2]
	adcs	@b[3],@a[3],@mod[3]
	adc	@t[4],xzr,xzr
	tst	@a[0],#1

	csel	@b[0],@b[0],@a[0],ne
	csel	@b[1],@b[1],@a[1],ne
	csel	@b[2],@b[2],@a[2],ne
	csel	@b[3],@b[3],@a[3],ne
	csel	@t[4],@t[4],xzr,ne

	extr	@a[0],@b[1],@b[0],#1
	extr	@a[1],@b[2],@b[1],#1
	extr	@a[2],@b[3],@b[2],#1
	extr	@a[3],@t[4],@b[3],#1

	cbnz	$b_ptr,.Loop_rshift

	stp	@a[0],@a[1],[$r_ptr]
	stp	@a[2],@a[3],[$r_ptr,#16]

	ret
.size	pasta_rshift,.-pasta_rshift
___

print $code;

close STDOUT;
