.set O_RDONLY, 0
.set PROT_READ, 0x1
.set MAP_PRIVATE, 0x2
.set AT_FDCWD, -100



.section .rodata
fname:
    .asciz "x.txt"


.global _start

.extern print_string
.extern string_length
.extern success_exit
.extern print_uint
.extern string_to_int
.extern print_newline


.text
_start:

    // openat(AT_FDCWD, "rodar.txt", O_RDONLY, 0)
    mov x0, #AT_FDCWD
    adr x1, fname
    mov x2, #O_RDONLY
    mov x3, #0
    mov x8, #56
    svc #0
    mov x19, x0 // guarda o file descriptor 

    mov x0, #0
    mov x1, #4096
    mov x2, #PROT_READ
    mov x3, #MAP_PRIVATE
    mov x4, x19
    mov x5, #0
    mov x8, #222
    svc #0


    //conteudo em x0 
    bl string_to_int


    //ver se o numero é primo em x0
    cmp x0, #2
    b.le .is

    mov x2, #2 //divisor
     
    udiv x4, x0, x2 
    msub x1, x4, x2, x0
    cmp x1, #0
    b.eq .isnot
    add x2, x2, #1
    //while x2 * x2 <= x0

    .loop_is_primo:
        mul x3, x2, x2
        cmp x3, x0
        b.gt .is
        udiv x4, x0, x2 
        msub x1, x4, x2, x0
        cmp x1, #0
        b.eq .isnot
        add x2, x2, #2
        b .loop_is_primo

    .isnot:
        mov x0, #0
        bl print_int
        bl print_newline
        bl success_exit

    .is:
        mov x0, #1
        bl print_int
        bl print_newline
        bl success_exit

