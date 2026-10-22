.IFNDEF PRINT_INT_O
.EQU PRINT_INT_O,1

.INCLUDE "IO/print_chars.s"

// void print_int_b(int {fd}, int {num})
// Writes binary representation of {num} to file descriptor {fd} (e.g. 1 for stdout, 2 for stderr).
// @param fd X0 — file descriptor to write to (e.g. 1 for stdout, 2 for stderr)
// @param num X1 — binary value to write
print_int_o:
    stp  x29, x30, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    mov  x29, sp //base stack frame pointer 


    sub sp, sp, #80 // 64 bytes + 2 bytes (0b + null terminator) + 14 bytes (padding for 16-byte alignment)
    add x3, sp, #80 // aponta para o fim do buffer

.loop_octal:
    and x2, x1, #7 // pega os 3 bits menos significativos de num
    add x2, x2, #48 // converte 0 para '0' e 1 para '1'
    strb w2, [x3, #-1]! // armazena o caractere no buffer e decrementa o ponteiro

    lsr x1, x1, #3 // shift num para a direita para processar o próximo bit
    cbnz x1, .loop_octal // continua até que num seja 0


    // Adiciona o prefixo "0o" para indicar que é um número octal
    mov x2, #111 // ASCII para 'o'
    strb w2, [x3, #-1]!

    mov x2, #48 // ASCII para '0'
    strb w2, [x3, #-1]!

    mov x1, x3 // x1 aponta para o início da string a ser impressa
    sub x2, x29, x3 // comprimento do buffer = fim_do_buffer - ponteiro_atual

    //x0 já tem o fd
    bl print_chars

    mov sp, x29 //restaura o stack pointer
    ldp x2, x3, [sp], #16 //restaura os registradores usados
    ldp x29, x30, [sp], #16    // restaura o LR (e desalinha o stack)
    ret

.ENDIF


