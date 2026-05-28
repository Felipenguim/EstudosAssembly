.IFNDEF PRINT_MEMORY
.EQU PRINT_MEMORY,1

.INCLUDE "IO/print_chars.s"
.INCLUDE "IO/print_int_d.s"
.INCLUDE "IO/print_int_o.s"
.INCLUDE "IO/print_int_h.s"
.INCLUDE "IO/print_int_b.s"

// void print_memory(int {x0}, byte* {x1}, void* {x2}, int {x3})
// Prints {x3} bytes from memory starting at {x1} to file descriptor {x0}.
// {x2} points to the function used to format each byte.
//
// @param x0 — file descriptor (e.g. 1 = stdout)
// @param x1 — starting memory address to print
// @param x2 — function pointer for integer printing (e.g. print_int_h)
// @param x3 — number of bytes to print
//
print_memory:
    stp x29, x30, [sp, #-16]!
    //salvar os registradores usados pela função
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    
    mov x29, sp



    mov x4, x1 //salvando endereço inicial em x4
    mov x5, x2 //salvando func pointer

.outer_loop_memory:
    
    //printando local da memória
    mov x1, x4
    bl print_int_h

    //print ':'

    adr x1, .grammar_memory
    mov x2, #1
    bl print_chars

    mov x6, #8 //bytes por linha

.inner_loop_memory:

    adr x1, .grammar_memory+1
    mov x2, #1
    bl print_chars

    ldrb w1, [x4] //print byte
    blr x5
    add x4, x4, #1
    sub x3, x3, #1
    sub x6, x6, #1
    cmp x6, #0
    b.ne .inner_loop_memory

    //newline
    adr x1, .grammar_memory+2
    mov x2, #1
    bl print_chars

    cmp x3, #0
    b.gt .outer_loop_memory

    //end
    mov sp, x29
    ldp x6, x7, [sp], #16 
    ldp x4, x5, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.grammar_memory:
    .ascii ": \n"
.balign 4
.ENDIF
