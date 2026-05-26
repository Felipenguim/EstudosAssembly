.IFNDEF PRINt_ARRAY_INT
.EQU PRINt_ARRAY_INT,1

.INCLUDE "IO/print_chars.s"
.INCLUDE "IO/print_int_d.s"
.INCLUDE "IO/print_int_o.s"
.INCLUDE "IO/print_int_h.s"
.INCLUDE "IO/print_int_b.s"

// void print_array_int(int {fd}, int* {array}, int {num_rows}, int {num_cols}, int{offset between cols and rows} void* {print_function}  )
//Prints out integer array values to file descriptor  using the print function pointer

// @param fd [x0] — file descriptor to write to (e.g. 1 for stdout, 2 for stderr)
// @param fd [x1] - adress of the first element of the array (pointer to int)
// @param num_rows [x2] - number of rows in the array
// @param num_cols [x3] - number of columns in the array
// @param offset [x4] - offset between columns and rows
// @param print_function [x5] — function pointer to the print function to use
print_array_int:
    stp x29, x30, [sp, #-16]!
    //salvar os registradores usados pela função
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x11, [sp, #-16]!
    mov x29, sp

    //total offset in x4 has to be splited in row offset 32 high bits and column offset 32 low bits
    //calculate row offset and column offset
    mov w6, w4       // pega os 32 bits baixos de x4, zero-extende → x6 fica isolado
    lsr x4, x4, #32  // desloca row_offset para baixo

    add x6, x6, #8 //ter o tamanho de long 
    //quantos bytes separam dois elementos adjacentes na mesma linha que é col_offset_extra + sizeof(elemento)

    mov x7, x1 //x7 vai apontar para a row atual
    mov x8, x2 //quantas rows faltam
    mov x9, x3 //quantas colunas tem

    //x4 deve contar a distancia entre A(i,j) e A(i+1,j)
    mov x10, x3 //nCols
    mul x10, x10, x6 //(col_offset_extra + sizeof)(stride) * nCols → distancia entre A(i,j) e A(i+1,j) 
    add x4, x4, x10// x4 = row_offset + (col_offset_extra + sizeof(elemento)) * nCols

    // print `[`;
    adr x1, .grammar
    mov x2, #1
    bl print_chars


.loop_rows:

    mov sp, x29 
    ldp x10, x11, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.grammar:
    ascii "[,];\n"

.ENDIF
