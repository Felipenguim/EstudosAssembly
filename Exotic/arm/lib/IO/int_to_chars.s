.IFNDEF INT_TO_CHARS
.EQU INT_TO_CHARS,1

.INCLUDE "IO/mem_copy.s"

///////////////////////////////////////////////////////////////////////////////

// char* {x0} int_to_chars(char* {buf}, long {num})
// Writes the decimal ASCII representation of {num} into {buf}
// (no null terminator, '-' prefix if negative).
// This is the single int->decimal conversion of the lib: print_int_d uses it
// and then prints the buffer; use it directly to build strings in memory
// (headers, messages, ...).
// {buf} must have room for up to 20 chars.
// @param buf x0 — destination buffer
// @param num x1 — signed value to convert
// @return x0 — buf + number of chars written (pointer to the next free byte)
int_to_chars:
    stp  x29, x30, [sp, #-16]!
    stp x1, x2, [sp, #-16]!
    stp x3, x4, [sp, #-16]!
    stp x5, x6, [sp, #-16]!
    mov  x29, sp //base stack frame pointer

    sub sp, sp, #32 // buffer temporário (20 chars + padding)
    add x3, sp, #32 // aponta para o fim do buffer temporário

    mov x4, x1 // guarda o original para checar o sinal depois

    tst x1, x1 // test if num is negative
    b.pl 1f
    neg x1, x1 // negativo -> positivo para processar

1:
    mov x5, #10 //divisor

2:
    udiv x6, x1, x5        // x6 = x1 / 10
    msub x2, x6, x5, x1    // x2 = x1 - (x6 * 10)  ->  resto (0-9)
    add  x2, x2, #48       // converte para ASCII '0'-'9'
    strb w2, [x3, #-1]!    // armazena no buffer e decrementa ponteiro
    mov  x1, x6            // quociente vira o novo valor
    cbnz x1, 2b

    tst  x4, x4            // checa se original era negativo
    b.pl 3f
    mov  x2, #45           // ASCII '-'
    strb w2, [x3, #-1]!
3:
    mov  x1, x3            // x1 = início da string no buffer temporário
    sub  x2, x29, x3       // x2 = comprimento = fim_buffer - ponteiro_atual
    // x0 já tem o destino
    bl   mem_copy          // x0 = buf + comprimento

    mov  sp, x29
    ldp x5, x6, [sp], #16
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    ldp  x29, x30, [sp], #16
    ret

.ENDIF
