.IFNDEF PRINT_STACK
.EQU PRINT_STACK,1

.INCLUDE "IO/print_chars.s"
.INCLUDE "IO/print_int_d.s"
.INCLUDE "IO/print_int_o.s"
.INCLUDE "IO/print_int_h.s"
.INCLUDE "IO/print_int_b.s"

// void print_stack(int {fd}, int {elements}, void* {print_function}  )
//Prints stack elements at stack in fd
// @param fd [x0] — file descriptor to write to (e.g. 1 for stdout, 2 for stderr)
// @param elements [x1] - how many elements to print in the stack
// @param function pointer [x2] - function pointer to the print function 

print_stack:
    stp x29, x30, [sp, #-16]!
    //salvar os registradores usados pela função
    stp x3, x4, [sp, #-16]!
    stp x5, x6, [sp, #-16]!
    
    mov x29, sp


    mov x3, x1 // tracks the offset to the current value to print
    lsl x3, x3, #3 //convert to bytes (elements * 8 (long))
    mov x4, x3  //byte offset from the stack
    add x3, sp, x3 //offset by the stack poiner
    add x3, x3, #48 //ajusta para o primeiro elemento a ser impresso (pula os valores callee saved)
    mov x5, x2 //function pointer para a função de impressão

.loop_stack:
    adr x1, .grammar_stack
    mov x2, #5
    bl print_chars

    //print number of bytes from the stack
    mov x1, x4
    bl print_int_d

    adr x1, .grammar_stack+5
    mov x2, #3
    bl print_chars

    ldr x1, [x3]
    blr x5

    sub x3, x3, #8
    sub x4, x4, #8
    cmp x4, #0
    b.ge .loop_stack

    adr x1, .grammar_stack
    mov x2, #1
    bl print_chars
    //end
    mov sp, x29 
    ldp x5, x6, [sp], #16
    ldp x3, x4, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.grammar_stack:
    .ascii "\n[sp+]:\t"
.balign 4
.ENDIF
