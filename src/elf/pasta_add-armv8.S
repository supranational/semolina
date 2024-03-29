.text

.globl	pasta_add
.hidden	pasta_add
.type	pasta_add,%function
.align	5
pasta_add:
	ldp	x8,x9,[x1]
	ldp	x12,x13,[x2]

	ldp	x10,x11,[x1,#16]
	adds	x8,x8,x12
	ldp	x14,x15,[x2,#16]
	adcs	x9,x9,x13
	ldp	x4,x5,[x3]
	adcs	x10,x10,x14
	ldp	x6,x7,[x3,#16]
	adcs	x11,x11,x15
	adc	x3,xzr,xzr

	subs	x16,x8,x4
	sbcs	x17,x9,x5
	sbcs	x1,x10,x6
	sbcs	x2,x11,x7
	sbcs	xzr,x3,xzr

	csel	x8,x8,x16,lo
	csel	x9,x9,x17,lo
	csel	x10,x10,x1,lo
	stp	x8,x9,[x0]
	csel	x11,x11,x2,lo
	stp	x10,x11,[x0,#16]

	ret
.size	pasta_add,.-pasta_add

.globl	pasta_cneg
.hidden	pasta_cneg
.type	pasta_cneg,%function
.align	5
pasta_cneg:
	ldp	x8,x9,[x1]
	ldp	x4,x5,[x3]

	ldp	x10,x11,[x1,#16]
	subs	x12,x4,x8
	ldp	x6,x7,[x3,#16]
	orr	x4,x8,x9
	sbcs	x13,x5,x9
	orr	x5,x10,x11
	sbcs	x14,x6,x10
	orr	x3,x4,x5
	sbc	x15,x7,x11

	cmp	x3,#0
	csetm	x3,ne
	ands	x2,x2,x3

	csel	x8,x8,x12,eq
	csel	x9,x9,x13,eq
	csel	x10,x10,x14,eq
	stp	x8,x9,[x0]
	csel	x11,x11,x15,eq
	stp	x10,x11,[x0,#16]

	ret
.size	pasta_cneg,.-pasta_cneg

.globl	pasta_sub
.hidden	pasta_sub
.type	pasta_sub,%function
.align	5
pasta_sub:
	ldp	x8,x9,[x1]
	ldp	x12,x13,[x2]

	ldp	x10,x11,[x1,#16]
	subs	x8,x8,x12
	ldp	x14,x15,[x2,#16]
	sbcs	x9,x9,x13
	ldp	x4,x5,[x3]
	sbcs	x10,x10,x14
	ldp	x6,x7,[x3,#16]
	sbcs	x11,x11,x15
	sbc	x3,xzr,xzr

	and	x4,x4,x3
	and	x5,x5,x3
	adds	x8,x8,x4
	and	x6,x6,x3
	adcs	x9,x9,x5
	and	x7,x7,x3
	adcs	x10,x10,x6
	stp	x8,x9,[x0]
	adc	x11,x11,x7
	stp	x10,x11,[x0,#16]

	ret
.size	pasta_sub,.-pasta_sub

.globl	pasta_lshift
.hidden	pasta_lshift
.type	pasta_lshift,%function
.align	5
pasta_lshift:
	ldp	x8,x9,[x1]
	ldp	x10,x11,[x1,#16]

	ldp	x4,x5,[x3]
	ldp	x6,x7,[x3,#16]

.Loop_lshift_mod_256:
	adds	x8,x8,x8
	sub	x2,x2,#1
	adcs	x9,x9,x9
	adcs	x10,x10,x10
	adcs	x11,x11,x11
	adc	x3,xzr,xzr

	subs	x12,x8,x4
	sbcs	x13,x9,x5
	sbcs	x14,x10,x6
	sbcs	x15,x11,x7
	sbcs	xzr,x3,xzr

	csel	x8,x8,x12,lo
	csel	x9,x9,x13,lo
	csel	x10,x10,x14,lo
	csel	x11,x11,x15,lo

	cbnz	x2,.Loop_lshift_mod_256

	stp	x8,x9,[x0]
	stp	x10,x11,[x0,#16]

	ret
.size	pasta_lshift,.-pasta_lshift

.globl	pasta_rshift
.hidden	pasta_rshift
.type	pasta_rshift,%function
.align	5
pasta_rshift:
	ldp	x8,x9,[x1]
	ldp	x10,x11,[x1,#16]

	ldp	x4,x5,[x3]
	ldp	x6,x7,[x3,#16]

.Loop_rshift:
	adds	x12,x8,x4
	sub	x2,x2,#1
	adcs	x13,x9,x5
	adcs	x14,x10,x6
	adcs	x15,x11,x7
	adc	x3,xzr,xzr
	tst	x8,#1

	csel	x12,x12,x8,ne
	csel	x13,x13,x9,ne
	csel	x14,x14,x10,ne
	csel	x15,x15,x11,ne
	csel	x3,x3,xzr,ne

	extr	x8,x13,x12,#1
	extr	x9,x14,x13,#1
	extr	x10,x15,x14,#1
	extr	x11,x3,x15,#1

	cbnz	x2,.Loop_rshift

	stp	x8,x9,[x0]
	stp	x10,x11,[x0,#16]

	ret
.size	pasta_rshift,.-pasta_rshift
