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
    //retorna tbm em x0 

    //recebera valor em x0
    //retorno em x0
    .factorial:
        mov x1, x0
        //x0 //acumulador
        
        
        .loop:
            sub x1, x1, #1
            mul x0, x0, x1
            cmp x1, #1
            b.eq .end
            b .loop

    .end:
        bl print_uint
        bl print_newline

        bl success_exit
