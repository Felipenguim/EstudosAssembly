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
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x11, [sp, #-16]!
    stp x12, x13, [sp, #-16]!
    mov x29, sp 

    sub sp, sp, #64 // para guardar o valor final
    add x8, sp, #64 // x8 no fim do buffer 

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
    b.eq .ret_NaN_print_float

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
    scvtf d3, x2 //radix for decimal in d3

    mov x2, x4
    add x2, x2, #1 // x2 = exponent+1

    cmp x2, x1 //comparando com os dígitos significantes
    b.ge .huge_number //more digits to left of decimal than sig figs,
				      //so we need to pad extra zeros to the right

    cmp x2, #0 // número inteiro a direita do decimal 
    b.le .small_number // 0. ...

.medium_number: //caso normal, nenhum dos dois acima
    mov x9, x1 
    sub x9, x9, x2 // x9 = digits to right of the decimal
.medium_number_shift_loop:
    fmul d0, d0, d3 //d0 *10 até não ser mais decimal
    sub x9, x9, #1 
    cbnz x9, .medium_number_shift_loop

.medium_number_shifted:
    mov x9, x1
    sub x9, x9, x2 // x9 = digits to right of the decimal
    fcvtzs x2, d0 //round para o inteiro mais proximo
    mov x10, #10 
.medium_number_print_loop:
    udiv x11, x2, x10 //x11 quociente
    msub x12, x11, x10, x2// x12 = resto = x2 - x11*10 (o dígito)
    add w12, w12, #48 //ASCII
    sub x9, x9, #1 
    sub x8, x8, #1 //ponteiro do buffer na pilha menos 1 
    strb w12, [x8]
    mov x2, x11 //atualizando para proxima chamada
    cbnz x9, .medium_number_not_decimal_point
    sub  x8, x8, #1
    mov  w13, #46                  // '.'
    strb w13, [x8]

.medium_number_not_decimal_point:
    cbnz x2, .medium_number_print_loop //volta pro loop se não zerou ainda
    //d2 com valor original
    fcmp d2, #0.0
    b.gt .write_print_float
    sub  x8, x8, #1
    mov  w13, #45                  // '-'
    strb w13, [x8]
    b .write_print_float

.small_number:
    mov x9,x2	//{x9}=zeros between decimal and number
	neg x9, x9
	add x1, x1, x9

.small_number_shift_loop:
    fmul d0, d0, d3 //d0 *10 até não ser mais decimal       
    sub x1, x1, #1
	cbnz x1, .small_number_shift_loop

.small_number_shifted:
    fcvtzs x2, d0 //round para o inteiro mais proximo
    mov x10, #10 

.small_number_print_loop:
    udiv x11, x2, x10 //x11 quociente
    msub x12, x11, x10, x2// x12 = resto = x2 - x11*10 (o dígito)
    add w12, w12, #48 //ASCII
    sub x8, x8, #1 //ponteiro do buffer na pilha menos 1 
    strb w12, [x8]
    mov x2, x11
    cbnz x2, .small_number_print_loop
    cbz x9, .small_number_no_zeros

.small_number_zeros_loop:
    sub x8, x8, #1
    mov  w13, #48                  // '0'
    strb w13, [x8]
    sub x9, x9, #1
    cbnz x9, .small_number_zeros_loop

.small_number_no_zeros:
    sub x8, x8, #1
    mov  w13, #46                  // '.'
    strb w13, [x8]
    sub x8, x8, #1
    mov  w13, #48                 // '0'
    strb w13, [x8]
    fcmp d2, #0.0
    b.gt .write_print_float
    sub  x8, x8, #1
    mov  w13, #45                  // '-'
    strb w13, [x8]
    b .write_print_float

.huge_number:
    mov x9,x2
    sub x9, x9, x1
    fcvtzs x2, d0 //round para o inteiro mais proximo
    mov x10, #10
    cbz x9, .huge_number_print_loop

.huge_number_zeros_loop:
    udiv x11, x2, x10 //x11 quociente
    msub x12, x11, x10, x2// x12 = resto = x2 - x11*10 (o dígito)
    sub x8, x8, #1 //ponteiro do buffer na pilha menos 1 
    mov  w13, #48                 // '0'
    strb w13, [x8]
    mov x2, x11
    sub x9, x9, #1
    cbnz x9, .huge_number_zeros_loop

.huge_number_print_loop:
    udiv x11, x2, x10 //x11 quociente
    msub x12, x11, x10, x2// x12 = resto = x2 - x11*10 (o dígito)
    add w12, w12, #48 //ASCII
    sub x8, x8, #1 //ponteiro do buffer na pilha menos 1 
    strb w12, [x8]
    mov x2, x11
    cbnz x2, .huge_number_print_loop
    fcmp d2, #0.0
    b.gt .write_print_float
    sub  x8, x8, #1
    mov  w13, #45                  // '-'
    strb w13, [x8]
    //vai direto pro print

.write_print_float:
    //x0 com fd
    mov x1, x8
    mov x4, sp
    sub x2, x8, x4
    mov x4, #64 //valor usado
    sub x2, x4, x2 //x2 com a vendeira len
    bl print_chars
    b .done_print_float

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
    mov x8, x6
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
    
    mov x8, x6
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
    mov x8, x6
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
    mov x8, x6
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
    mov x8, x6
    b .write_print_float

.done_print_float:
    add sp, sp, #64
    mov sp, x29 
    ldp x12, x13, [sp], #16
    ldp x10, x11, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
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
