.IFNDEF PRINT_REGISTERS
.EQU PRINT_REGISTERS,1

.INCLUDE "IO/print_chars.s"
.INCLUDE "IO/print_int_d.s"
.INCLUDE "IO/print_int_o.s"
.INCLUDE "IO/print_int_h.s"
.INCLUDE "IO/print_int_b.s"

// void print_int_registers(int {fd}, void* {print_function})
//Prints out register values to file descriptor  using the print function pointer
// Parâmetros passados via pilha pelo caller (slots de 16 bytes cada).
// Após salvar x30 na entrada:
// @param fd [SP+0] — file descriptor to write to (e.g. 1 for stdout, 2 for stderr)
// @param print_function [SP+16] — function pointer to the print function to use
print_registers:
    stp x29, x30, [sp, #-16]!
    mov x29, sp 
//x29 vai guardar o valor do stack pointer antes dos valores dos registradores serem empilhados

//       Endereço    Conteúdo
// SP+32  ──────── │ print_fn  │  ← ldr xN, [sp, #32]
// SP+16  ──────── │    fd     │  ← ldr xN, [sp, #16]
// SP+0   ──────── │   x30     │  ← ldr x30, [sp], #16 no retorno
    
    //salvar todos os registradores x0-x15 na pilha para poder imprimi-los
    stp x14, x15, [sp, #-16]!   // push primeiro
    stp x12, x13, [sp, #-16]!
    stp x10, x11, [sp, #-16]!
    stp x8,  x9,  [sp, #-16]!
    stp x6,  x7,  [sp, #-16]!
    stp x4,  x5,  [sp, #-16]!
    stp x2,  x3,  [sp, #-16]!
    stp x0,  x1,  [sp, #-16]!   // push por último

    //sp ta em 128 bytes abaixo de x30, ou seja, sp+128 = x30

    //pegar o fd e o ponteiro para a função de impressão
    ldr x7, [x29, #16]
    ldr x5, [x29, #32]
    mov x3, sp
    adr x4, .register_names

    //valor para ver se já pegou todos os regs
    adr x6, .register_names
    add x6, x6, #80 //pula os nomes dos registradores

    //imprimir os nomes dos registradores
.loop_print_registers:
    
    mov x0, x7
    mov x1, x4
    mov x2, #5 //tamanho da string a ser impressa (e.g. "x0 =")
    bl print_chars

    //imprimir o valor do registrador atual
    mov x0, x7
    ldr x1, [x3], #8
    blr x5 

    add x4, x4, #5
    cmp x4, x6
    b.lo .loop_print_registers
    
    //print the final newline
    mov x0, x7 //usando o fd passado
    adr x1, newline
    mov x2, #1
    bl print_chars

    //restore stack and return
    ldp x0,  x1,  [sp], #16
    ldp x2,  x3,  [sp], #16
    ldp x4,  x5,  [sp], #16
    ldp x6,  x7,  [sp], #16
    ldp x8,  x9,  [sp], #16
    ldp x10, x11, [sp], #16
    ldp x12, x13, [sp], #16
    ldp x14, x15, [sp], #16


    mov sp, x29 
    ldp x29, x30, [sp], #16
    ret

.register_names:
    .ascii "\nx0 =\nx1 =\nx2 =\nx3 =\nx4 =\nx5 =\nx6 =\nx7 ="
    .ascii "\nx8 =\nx9 =\nx10=\nx11=\nx12=\nx13=\nx14=\nx15="

newline:
    .ascii "\n"


.balign 4 //tem que alinhar o tamanho total da string para múltiplo de 4 para garantir que o endereço de cada nome de registrador seja divisível por 4, o que é necessário para acessar os valores dos registradores usando ldr xN, [x3], #8 (que lê 8 bytes e incrementa o ponteiro em 8). Sem esse alinhamento, o acesso aos valores dos registradores pode ser incorreto devido a endereços desalinhados.

.ENDIF
