// nesse ex deverei abrir um arquivo ler, printar o conteúdo e as coisas dele, o primeiro com mmap e o segundo com stat

// call de stat: fstat	man/ cs/	x8 = 80 	x0 = unsigned int fd(file descriptor)	struct __old_kernel_stat *statbuf	


.set O_RDONLY, 0
.set PROT_READ, 0X1
.set MAP_PRIVATE, 0x2
.set AT_FDCWD, -100


.section .rodata
fname:
    .asciz "raven.txt"

.section .bss
    .align  3
statbuf:
    .skip 144  //a estrutura que a chamada stat retorna, ela usa esse tanto de bytes 


//Abrindo o arquivo 
.global _start

.extern print_string
.extern string_length
.extern success_exit
.extern print_int
.extern print_newline
.extern print_buffer

.text
_start:
    // openat(AT_FDCWD, "rodar.txt", O_RDONLY, 0)
    mov     x0, #AT_FDCWD
    adr     x1, fname
    mov     x2, #O_RDONLY
    mov     x3, #0
    mov     x8, #56          // syscall openat
    svc     #0
    mov     x19, x0          // guarda file descriptor

    //stat => int fstat(int fd, struct stat *statbuf); retorna 0 em x0 se der certo ou menos 1 se der erro
    
    //chamando stat:
    mov x0, x19 //fd
    adr x1, statbuf //buffer para a struct
    mov x8, #80
    svc #0

    adr x2, statbuf
    ldr x0, [x2, #48]   // st_size
    mov x10, x0

    bl print_int
    bl print_newline

    //mmap(NULL, 4096, PROT_READ, MAP_PRIVATE, fd, 0)
    mov x0, #0    //addr = null
    mov x1, #8192 
    mov x2, #PROT_READ
    mov x3, #MAP_PRIVATE
    mov x4, x19 //fd
    mov x5, #0  //offset (onde começar)
    mov x8, #222 //syscall de mmap
    svc #0

    //ponteiro já em x0
    bl print_string


    bl success_exit
