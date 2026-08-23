.IFNDEF RAND_FLOAT
.EQU RAND_FLOAT, 1

.INCLUDE "SYS/getrandom.s"

///////////////////////////////////////////////////////////////////////////////

// double {d0} rand_float(double {d0}, double {d1})
// Returns in {d0} a random double-precision value such that the original
// {d0} (lower bound) <= result < {d1} (upper bound).
// @param lb d0 — lower bound (inclusive)
// @param ub d1 — upper bound (exclusive)
// @return d0 — random double such that lower <= d0 < upper
rand_float:
	stp x29, x30, [sp, -16]!
    stp x0, x1, [sp, #-16]!
    stp x2, x9, [sp, #-16]!
    str d2, [sp, #-16]!
    str d3, [sp, #-16]!
	mov x29, sp

	sub sp, sp, #16  // scratch buffer for getrandom, same as rand_int

.loop_rand_float:
	mov x0, sp   // buf
	mov x1, #8   // buflen: 8 bytes = one 64-bit value
	mov x2, #0   // flags = 0 (may block until the pool is ready)
	_getrandom
	cmp x0, #0
	b.lt .loop_rand_float  // negative return = error (e.g. EINTR); retry

	ldr x9, [sp]   // x9 = random 64-bit value
	lsr x9, x9, #1 // clear the sign bit — positives only

	scvtf d2, x9   // convert the positive int64 to a double
	ldr d3, .tiny    // d3 = 2^-63 (PC-relative literal load)
	fmul d2, d2, d3                   // d2 = int-as-double * 2^-63 → fraction in [0,1)

	fsub d1, d1, d0    // d1 = upper - lower (range)
	fmul d1, d1, d2       // d1 = range * fraction
	fadd d0, d0, d1    // d0 = lower + scaled fraction

	add sp, sp, #16
    mov sp, x29
    ldr d3, [sp], #16
    ldr d2, [sp], #16
    ldp x2, x9, [sp], #16
    ldp x0, x1, [sp], #16
	ldp x29, x30, [sp], #16
	ret

.balign 8
.tiny:
	.quad 0x3C00000000000000     // 2^-63, exact bit pattern from the original

.ENDIF

