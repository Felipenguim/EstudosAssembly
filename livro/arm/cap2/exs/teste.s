// main.s — programa de teste para print_uint
.data
demo1: 
    .quad 3577777
str_rand:
        .asciz "Random string for testing.\n"

.global _start
.extern print_uint
.extern print_newline
.extern success_exit
.extern print_string //essa func ta com problema de retorno
.extern print_int
.extern read_char

.text
_start:
    ldr x0, =demo1
    ldr x0, [x0]
    //mov x0, #12345      // número para imprimir
    bl print_uint           // chama sua função para exibir o número
    
    bl print_newline        // pula linha
    ldr x0, =demo1
    ldr x0, [x0]
    bl print_int
    bl print_newline
    bl read_char
    bl print_newline
    bl success_exit
    
