.IFNDEF PRINT_FLOAT
.EQU PRINT_FLOAT,1

.INCLUDE "IO/print_chars.s"
.INCLUDE "math/expressions/log/log_10.s"
// void print_float(int {fd}, double {value}, long {sig_digits})
// Prints {sig_digits} significant digits of {value} to file descriptor {fd}
// Parâmetros via registradores conforme AAPCS64 — bancos separados: inteiro (x0-x7) vs. FP/SIMD (d0-d7).
// @param fd [x0] — file descriptor to write to (e.g. 1 for stdout, 2 for stderr)
// @param value [d0] — double-precision floating point value to print
// @param sig_digits [x1] — number of significant digits to print
print_float:
    stp x29, x30, [sp, #-16]!
    str d1, [sp, #-16]!
    str d2, [sp, #-16]!
    str d3, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    mov x29, sp 

    sub sp, sp, #16 // para guardar o valor final
    add x8, sp, #16 // x8 no fim do buffer 

    fmov x2, d0

    //special cases
    cbz x2, .ret_pos_zero  //compare x2, if == 0, branch to address 

    ldr x3, neg_zero
    //ldr x3, [x3]
    cmp x2, x3
    b.eq .ret_neg_zero 

    // adr x3, pos_inf
    // ldr x3, [x3]
    ldr x3, pos_inf
    cmp x2, x3
    b.eq .ret_pos_inf

    ldr x3, neg_inf
    cmp x2, x3
    b.eq .ret_neg_inf

    ldr x3, NaN_mask
    
    and x2, x2, x3
    cmp x2, x3
    b.eq .ret_NaN

    //saving value in d2
    fmov d2, d0
    fabs d0, d0            // abs(d0) — substitui psllq+psrlq num só

    ldr  d1, tolerance      // carrega tolerance em d2 (PC-relativo)
    //tolerance precisa estar em d1
    bl log10 //d0 com log10(value)
    frintm d0, d0 //round down (floor())
    fcvtzs x4, d0 //the exponent (power of 10) in x4


    fmov d0, d2 //restore
    fabs d0, d0 // |d0|

    mov x2, #10
    
    scvtf d3, x2 

    mov x2, x4
    add x2, x2, #1 // x2 = exponent+1

    cmp x2, x1 //comparando com os dígitos significantes
    b.ge .huge_number //more digits to left of decimal than sig figs,
				      //so we need to pad extra zeros to the right

    cmp x2, 0 // número inteiro a direita do decimal 
    b.le .small_number // 0. ...

.medium_number: //caso normal, nenhum dos dois acima

.medium_number_shift_loop:

.medium_number_shifted:

.medium_number_print_loop:

.medium_number_not_decimal_point:

.small_number_shift_loop:

.small_number_shifted:

.small_number_print_loop:

.small_number_zeros_loop:

.small_number:

.small_number_no_zeros:


.huge_number:

.huge_number_zeros_loop:

.huge_number_print_loop:

.write_print_float:
    
    b done_print_float

.ret_pos_zero:
    sub x5, x8, #4
    mov x6, x5 //resultado da escrita
    mov w7, #48 //0
    strb w7, [x6, #3]
    mov w7, #46 //.
    strb w7, [x6, #2]
    mov w7, #48 //0
    strb w7, [x6, #1]
    mov w7, #43 //+
    strb w7, [x6, #0]
    
    b .write_print_float

.ret_neg_zero:
    sub x5, x8, #4
    mov x6, x5 //resultado da escrita
    mov w7, #48 //0
    strb w7, [x6, #3]
    mov w7, #46 //.
    strb w7, [x6, #2]
    mov w7, #48 //0
    strb w7, [x6, #1]
    mov w7, #45 //-
    strb w7, [x6, #0]
    
    b .write_print_float


.ret_pos_inf:
    sub x5, x8, #4
    mov x6, x5 //resultado da escrita
    mov w7, #102 //f
    strb w7, [x6, #3]
    mov w7, #110 ///n
    strb w7, [x6, #2]
    mov w7, #73 //I
    strb w7, [x6, #1]
    mov w7, #43 //+
    strb w7, [x6, #0]
    
    b .write_print_float

.ret_neg_inf:
    sub x5, x8, #4
    mov x6, x5 //resultado da escrita
    mov w7, #102 //0
    strb w7, [x6, #3]
    mov w7, #110 //.
    strb w7, [x6, #2]
    mov w7, #73 //0
    strb w7, [x6, #1]
    mov w7, #45 //-
    strb w7, [x6, #0]
    
    b .write_print_float


.ret_NaN_print_float:
    sub x5, x8, #3
    mov x6, x5 //resultado da escrita
    
    mov w7, #78 //N
    strb w7, [x6, #2]
    mov w7, #97 //a
    strb w7, [x6, #1]
    mov w7, #78 //N
    strb w7, [x6, #0]
    
    b .write_print_float

.done_print_float:
    add sp, sp #16
    mov sp, x29 
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16
    ldr d3, [sp], #16
    ldr d2, [sp], #16
    ldr d1, [sp], #16
    ldp x29, x30, [sp], #16 
    ret

.balign 8
neg_zero:
	.quad 0x8000000000000000 //-0.0
pos_inf:
	.quad 0x7FF0000000000000 // +Inf
neg_inf:
	.quad 0xFFF0000000000000 // -Inf
NaN_mask:
	.quad 0x7FF0000000000000 // NaN
tolerance:
	.double 0.0000001


.ENDIF
