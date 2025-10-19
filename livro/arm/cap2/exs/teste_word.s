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
.extern read_word

.text
_start:
    sub sp, sp, #64
    mov x0, sp
    mov x1, #64
    bl read_word //endereço saindo em x0
    add sp, sp, #64
    cmp x0, '0'
    b.eq .fail
    bl print_string
    bl print_newline
    bl success_exit
    .fail:
        bl print_char
        bl print_newline
        bl success_exit
    
