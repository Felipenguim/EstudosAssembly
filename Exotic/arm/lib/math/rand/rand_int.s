.IFNDEF RAND_INT
.EQU RAND_INT, 1

.INCLUDE "SYS/getrandom.s"

///////////////////////////////////////////////////////////////////////////////

// signed long {x0} rand_int(signed long {x0}, signed long {x1})
// Returns in {x0} a random integer between the original {x0} (lower bound)
// and {x1} (upper bound), inclusive: lower <= result <= upper.
// Uses the getrandom(2) syscall as entropy source — RNDR/RNDRRS (FEAT_RNG)
// require Armv8.5-A and are NOT available on this target's Cortex-A78AE.
// Retries on interrupted syscalls (negative return, e.g. EINTR).
// @param x0 — lower bound (inclusive)
// @param x1 — upper bound (inclusive)
// @return x0 — random integer such that lower <= x0 <= upper
rand_int:
    stp x29, x30, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    mov x29, sp 

    mov x4, x0             // x4 = lower bound
	sub x3, x1, x0         // x3 = upper - lower
	add x3, x3, #1        // x3 = range, inclusive width: (upper - lower) + 1

    sub sp, sp, #16 //reserving buffer to use in syscall
    

//had to use a syscall because just arm8.5 has a rand instruction
//mrs x0, RNDR      // ou RNDRRS para "full entropy" (equivalente a RDSEED)
    .loop:
        mov x0, sp              // buf
        mov x1, #8              // buflen: 8 bytes = one 64-bit value
        mov x2, #0               // flags = 0 (may block until the pool is ready)
        _getrandom
        cmp x0, #0
        b.lt .loop   // negative return = error (e.g. EINTR); retry
    //retry até ter um número rand

    ldr x5, [sp] //value in x5
    udiv x6, x5, x3           // x6 = x5 / range    (quotient)
	msub x7, x6, x3, x5       // x7 = x5 - x6*range (remainder, 0<=x7<range)

    //result = lower + resto
    add x0, x4, x7 //return in x0

    add sp, sp, #16 
    mov sp, x29 
    ldp x6, x7, [sp], #16
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldp x29, x30, [sp], #16
    ret
.ENDIF


// udiv x10, x9, x20      // x10 = x9 / x20   (quociente, unsigned)
// msub x11, x10, x20, x9 // x11 = x9 - (x10 * x20)   → resto

