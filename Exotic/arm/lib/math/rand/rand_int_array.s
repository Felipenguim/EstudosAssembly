.IFNDEF RAND_INT_ARRAY
.EQU RAND_INT_ARRAY, 1

.INCLUDE "SYS/getrandom.s"

///////////////////////////////////////////////////////////////////////////////

// void rand_int_array(long* {x0}, int {x1}, unsigned int {x2}, signed long {x3}, signed long {x4})
// Places {x2} random integers into an array starting at {x0}, with
// ({x1}+8) bytes between consecutive elements. Each value satisfies
// {x3}<=value<={x4}.
// Uses the getrandom(2) syscall as entropy source — see rand_int notes:
// RNDR/RNDRRS (FEAT_RNG) require Armv8.5-A, unavailable on this target's
// Cortex-A78AE.
// @param arr x0 — pointer to the destination array (elements are 8-byte longs)
// @param pad x1 — extra padding in bytes between consecutive elements (stride = x1 + 8)
// @param lenght x2 — number of random integers to generate
// @param lb x3 — lower bound (inclusive)
// @param ub x4 — upper bound (inclusive)
// @return x0 - pointer to the destination array
rand_int_array:
	stp x29, x30, [sp, -16]!
    stp x18, x19, [sp, -16]!
    stp x20, x21, [sp, -16]!
    stp x22, x23, [sp, -16]!
    stp x5, x6, [sp, -16]!
    stp x7, x9, [sp, -16]!
	mov x29, sp

    mov x19, x0 //to use later
    mov x20, x0 //point
    mov x21, x1 //offset
    mov x22, x2 //counter
	
    sub x23, x4, x3 //upper -lower
    add x23, x23, #1

	sub sp, sp, #16          // scratch buffer for getrandom, same as rand_int

.loop_rand_int_array:
	
    mov x0, sp              // buf
    mov x1, #8              // buflen: 8 bytes = one 64-bit value
    mov x2, #0               // flags = 0 (may block until the pool is ready)
    _getrandom
    cmp x0, #0
    b.lt .loop_rand_int_array 

    ldr x5, [sp] //value in x5
    udiv x6, x5, x23           // x6 = x5 / range    (quotient)
	msub x7, x6, x23, x5 
    add x0, x3, x7 //number = lower + resto

    str x0, [x20] // grava o valor aleatório no endereço apontado por x20
    add x20, x20, #8
    add x20, x20, x21

    sub x22, x22, #1
    cbnz x22, .loop_rand_int_array

    mov x0, x19

	add sp, sp, #16
    ldp x7, x9, [sp], #16
    ldp x5, x6, [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x18, x19, [sp], #16
	ldp x29, x30, [sp], #16
	ret

.ENDIF
