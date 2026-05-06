.IFNDEF PRINT_INT_H
.EQU PRINT_INT_H,1

.INCLUDE "IO/print_chars.s"

// void print_int_h(int {fd}, int {num})
// Writes hexadecimal representation of {num} to file descriptor {fd} (e.g. 1 for stdout, 2 for stderr).
// @param fd X0 — file descriptor to write to (e.g. 1 for stdout, 2 for stderr)
// @param num X1 — numerical value to write
print_int_h:
    stp  x29, x30, [sp, #-16]!
    mov  x29, sp //base stack frame pointer 


    sub sp, sp, #80 // 64 bytes + 2 bytes (0b + null terminator) + 14 bytes (padding for 16-byte alignment)
    add x3, sp, #80 // aponta para o fim do buffer

.loop_hex:
    and x2, x1, #15 // pega os 4 bits menos significativos de num
    add x2, x2, #48 //  now correctly contains ascii "0"-"9"
    cmp x2, #57 // compare with ascii "9"
    b.le .insert_byte
    add x2, x2, #39 // adjust {al} for ascii "a"-"f"

.insert_byte: 
    strb w2, [x3, #-1]! // armazena o caractere no buffer e decrementa o ponteiro
    
    lsr x1, x1, #4 // shift num para a direita para processar o próximo bit
    cbnz x1, .loop_hex // continua até que num seja 0


    // Adiciona o prefixo "0x" para indicar que é um número hexadecimal
    mov x2, #120 // ASCII para 'x'
    strb w2, [x3, #-1]!

    mov x2, #48 // ASCII para '0'
    strb w2, [x3, #-1]!

    mov x1, x3 // x1 aponta para o início da string a ser impressa
    sub x2, x29, x3 // comprimento do buffer = fim_do_buffer - ponteiro_atual

    //x0 já tem o fd
    bl print_chars

    mov sp, x29 //restaura o stack pointer
    ldp x29, x30, [sp], #16    // restaura o LR (e desalinha o stack)
    ret

.ENDIF


