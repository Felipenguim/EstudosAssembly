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


    //ver se o numero é de fibonacci em x0

    mov x1, #1 // segundo numero de fibo
    mov x2, #1 //primeiro
    mov x3, #0 //result

    //while x1 < x0

    .loop_is_fibo:
        cmp x1, x0
        b.eq .is
        b.gt .isnot
        add x3, x1, x2
        mov x2, x1
        mov x1, x3
        b .loop_is_fibo

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

