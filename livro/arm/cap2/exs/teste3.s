.data
demo1: 
    .quad 3577777
str_rand:
    .asciz "-123455"


.global _start
.extern print_uint
.extern print_newline
.extern success_exit
.extern print_string //essa func ta com problema de retorno
.extern print_int
.extern read_char
.extern read_word
.extern parse_uint
.extern parse_int

.text
_start:
    adr x0, str_rand
    bl parse_int
    bl print_int
    bl print_newline
    bl success_exit
