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

    mov x1, x0 
    mov x0, #0 //resultado final saira em x0
    
    .loop_digits:
        ldrb w3, [x1], #1
        cbz w3, .over
        cmp w3, '0'
        b.lt .over
        cmp w3, '9'
        b.gt .over
        sub w3, w3, '0'

        add x0, x0, x3
        b .loop_digits
    
    .over:
        bl print_int
        bl print_newline

        bl success_exit

