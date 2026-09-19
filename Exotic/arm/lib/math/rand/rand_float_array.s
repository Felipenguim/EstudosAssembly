.IFNDEF RAND_FLOAT_ARRAY
.EQU RAND_FLOAT_ARRAY, 1

.INCLUDE "SYS/getrandom.s"

///////////////////////////////////////////////////////////////////////////////

// double* {x0} rand_float_array(double {d0}, double {d1}, double* {x0}, int {x1}, unsigned int {x2})
// Places {x2} random doubles into an array starting at {x0}, with
// ({x1}+8) bytes between consecutive elements. Each value satisfies
// {d0} <= value < {d1}.
// Uses the getrandom(2) syscall as entropy source — see rand_int notes:
// RNDR/RNDRRS (FEAT_RNG) require Armv8.5-A, unavailable on this target's
// Cortex-A78AE.
// @param lb d0 — lower bound (inclusive)
// @param ub d1 — upper bound (exclusive)
// @param arr x0 — pointer to the destination array (elements are 8-byte doubles)
// @param pad x1 — extra padding in bytes between consecutive elements (stride = x1 + 8)
// @param lenght x2 — number of random doubles to generate
// @return x0 - pointer to the destination array
rand_float_array:
	stp x29, x30, [sp, -16]!
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!
    stp x1, x2, [sp, -16]!
    str x9, [sp, #-16]!
    str d1, [sp, #-16]!
    str d2, [sp, #-16]!
    str d3, [sp, #-16]!
	mov x29, sp

    mov x19, x0 //to use later (return value)
    mov x20, x0 //point
    mov x21, x1 //offset
    mov x22, x2 //counter

	fsub d1, d1, d0                  // d1 = upper - lower (range)
	ldr d3, .tiny_rand_float_array   // d3 = 2^-63, loaded once outside the loop

	sub sp, sp, #16          // scratch buffer for getrandom, same as rand_int

.loop_rand_float_array:
    mov x0, sp              // buf
    mov x1, #8              // buflen: 8 bytes = one 64-bit value
    mov x2, #0              // flags = 0 (may block until the pool is ready)
    _getrandom
    cmp x0, #0
    b.lt .loop_rand_float_array // negative return = error (e.g. EINTR); retry

    ldr x9, [sp]     // x9 = random 64-bit value
    lsr x9, x9, #1   // clear the sign bit — positives only

    scvtf d2, x9        // convert the positive int64 to a double
    fmul d2, d2, d3     // d2 = int-as-double * 2^-63 → fraction in [0,1)
    fmul d2, d2, d1     // d2 = range * fraction
    fadd d2, d2, d0     // d2 = lower + scaled fraction

    str d2, [x20]       // grava o double aleatório no endereço apontado por x20
    add x20, x20, #8
    add x20, x20, x21

    sub x22, x22, #1
    cbnz x22, .loop_rand_float_array

    mov x0, x19

	add sp, sp, #16
    ldr d3, [sp], #16
    ldr d2, [sp], #16
    ldr d1, [sp], #16
    ldr x9, [sp], #16
    ldp x1, x2, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
	ldp x29, x30, [sp], #16
	ret

.balign 8
.tiny_rand_float_array:
	.quad 0x3C00000000000000     // 2^-63, exact bit pattern from the original

.ENDIF
