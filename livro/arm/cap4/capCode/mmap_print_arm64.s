//mmap_print_arm64
//ler o arquivo selecionado com openat + mmap e imprimir com o printt_string

.set O_RDONLY, 0
.set PROT_READ, 0X1
.set MAP_PRIVATE, 0x2
.set AT_FDCWD, -100


.section .rodata
fname:
    .asciz "rodar.txt"


.global _start

.extern print_string
.extern string_length
.extern success_exit

.text
_start:
    // openat(AT_FDCWD, "rodar.txt", O_RDONLY, 0)
    mov     x0, #AT_FDCWD
    adr     x1, fname
    mov     x2, #O_RDONLY
    mov     x3, #0
    mov     x8, #56          // syscall openat
    svc     #0
    mov     x12, x0          // guarda file descriptor

    //mmap(NULL, 4096, PROT_READ, MAP_PRIVATE, fd, 0)
    mov x0, #0    //addr = null
    mov x1, #4096
    mov x2, #PROT_READ
    mov x3, #MAP_PRIVATE
    mov x4, x12 //fd
    mov x5, #0  //offset (onde começar)
    mov x8, #222 //syscall de mmap
    svc #0

    //ponteiro já em x0
    bl print_string

    bl success_exit


