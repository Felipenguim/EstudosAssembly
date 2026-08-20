.IFNDEF LOG_E
.EQU LOG_E,1


// double log_e (double {x}, double {tolerance})
// Computes Taylor Series approximation of ln({x}) to
// within tolerance {tolerance}, returning in {x}.
// @param x [d0] — value to compute natural log of
// @param tolerance [d1] — approximation tolerance
// @return [d0] — ln(x)
log_e:
    stp x29, x30, [sp, #-16]!
    str d2, [sp, #-16]!
    stp x0, x1, [sp, #-16]!
    str d3, [sp, #-16]!
    str d4, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    str d5, [sp, #-16]!
    str d6, [sp, #-16]!
    mov x29, sp 

    

    //if x<=0 return NaN
    //if x ==1 return 0 float (0.0f)

    movi d2, #0
    fcmp d0, d2
    b.le .ret_NaN
    adr x1, one
    ldr d2, [x1]
    fcmp d0, d2 //fcmp == comisd
    b.eq .ret_zero

    mov x0, #1 //tracks a range adjustment power of 2

    //if 0.5 < x < 1.5 jump into Taylor Series
    fmov d3, #1.5
    fcmp d0, d3
    b.ge .not_in_range
    fmov  d3, #0.5
    fcmp d0, d3
    b.gt .taylor_series_prep


.not_in_range:
    lsl x0, x0, #1
    fsqrt d0, d0 //sqrt x(d0)
    fmov  d3, #1.5
    fcmp d0, d3
    b.ge .not_in_range
    fmov  d3, #0.5
    fcmp d0, d3
    b.le .not_in_range


.taylor_series_prep:
    fmov d4, d0 //d4 trackeia x^k
    fmov  d3, #1.0 
    fsub d4, d4, d3 //expansion around ln(1+x), so adjust into the range
    fneg d3, d4 //d3=-x, multiplier between each term
    mov x2, #1 //tracks integer denominator, k
    movi d0, #0 //tracks the running sum of terms

.taylor_series_loop:
    scvtf d5, x2 //converte k para double
    fmov d6, d4 //d6 = x^k 
    fdiv d6, d6, d5 //d6=(x^k)/k
    fabs d5, d6      // d5 = |d5|
    fcmp d5, d1 //comparing against tolerance
    b.le .done_log_e
    fadd d0, d0, d6
    add x2, x2, #1
    fmul d4, d4, d3 //multiply (x^k)*(-x)
    b .taylor_series_loop


.done_log_e:
    scvtf d3, x0
    fmul d0, d0, d3
    b .leave_pre_cond

.ret_NaN:
    adr x1, NaN
    ldr d0, [x1]
    b .leave_pre_cond

.ret_zero:
    movi d0, #0

.leave_pre_cond:
    mov sp, x29 
    ldr d6, [sp], #16
    ldr d5, [sp], #16
    ldp x2, x3, [sp], #16
    ldr d4, [sp], #16
    ldr d3, [sp], #16
    ldp x0, x1, [sp], #16
    ldr d2, [sp], #16
    ldp x29, x30, [sp], #16
    ret



    // mov sp, x29 
    // ldp x29, x30, [sp], #16
    // ret

.balign 8

one:
    .double 1.0



NaN:
	.quad 0x7FF0000000000001 


.ENDIF



// V2.4s  [ lane3 | lane2 | lane1 | lane0 ]
//         127..96  95..64  63..32  31..0

// umov w0, v1.b[3]     // 0e073c20  byte→w0, zero-extended
// umov x0, v1.d[1]     // 4e183c20  lane alta (double)→x0
// smov w0, v1.b[3]     // 0e072c20  byte→w0, SIGN-extended
// smov x0, v1.h[2]     // 4e0a2c20  half→x0, sign-extended

// V2  [127 ........................................ 0]
//      ┌──────────────────────────────────────────┐
//      │                  Q2  (128)                │
//      │                        ┌──────────────────┤
//      │                        │      D2  (64)    │  ← double
//      │                        │        ┌─────────┤
//      │                        │        │ S2 (32) │  ← float
//      │                        │        │   ┌─────┤
//      │                        │        │   │H2(16)│
//      │                        │        │   │ ┌───┤
//      │                        │        │   │ │B2 │
//      └────────────────────────┴────────┴───┴─┴───┘
