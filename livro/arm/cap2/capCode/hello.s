.data 

msg:
    .ascii "Hello, arm64!\n"

len= . -msg

.text

.global _start

_start:


    mov x0, #1  //
    ldr x1, =msg //buffer com o tamanho de msg, coloca no x1 o endereço da string
    ldr x2, =len //count = len
    
    //forma mais simples, passando a len direto e :
    //adr x1, msg     // address of string to write
    //mov x2, #14         // length of string

    mov x8, #64         // syscall number for print
    svc #0              // invoke syscall


    // exit system call (sys_exit = 93)
    mov x0, #0          // exit code
    mov x8, #93         // syscall number for sys_exit
    svc #0              // invoke syscall