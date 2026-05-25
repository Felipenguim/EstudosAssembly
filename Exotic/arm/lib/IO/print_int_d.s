.IFNDEF PRINT_INT_D
.EQU PRINT_INT_D,1

.INCLUDE "IO/print_chars.s"

// void print_int_b(int {fd}, int {num})
// Writes binary representation of {num} to file descriptor {fd} (e.g. 1 for stdout, 2 for stderr).
// @param fd X0 — file descriptor to write to (e.g. 1 for stdout, 2 for stderr)
// @param num X1 — binary value to write
print_int_d:
    stp  x29, x30, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    str x6, [sp, #-16]!
    mov  x29, sp //base stack frame pointer 


    sub sp, sp, #64 
    add x3, sp, #64 // aponta para o fim do buffer
    
    mov x4, x1

    tst x1, x1 // test if num is negative
    b.pl 1f // if num is positive, jump to loop
    neg x1, x1 // if num is negative, negate it to make it positive for processing

1:
    mov x5, #10 //divisor

2:
    udiv x6, x1, x5         // x6 = x1 / 10
    msub x2, x6, x5, x1    // x2 = x1 - (x6 * 10)  →  resto (0–9)
    add  x2, x2, #48        // converte para ASCII '0'–'9'
    strb w2, [x3, #-1]!    // armazena no buffer e decrementa ponteiro
    mov  x1, x6             // quociente vira o novo valor
    cbnz x1, 2b

    tst  x4, x4             // checa se original era negativo
    b.pl 3f
    mov  x2, #45            // ASCII '-'
    strb w2, [x3, #-1]!
3:
    mov  x1, x3             // x1 = ponteiro para início da string
    sub  x2, x29, x3        // x2 = comprimento = fim_buffer - ponteiro_atual
    // x0 já tem o fd
    bl   print_chars

    mov  sp, x29
    ldp  x2, x3, [sp], #16
    ldp  x4, x5, [sp], #16
    ldr  x6, [sp], #16
    ldp  x29, x30, [sp], #16
    ret

.ENDIF


