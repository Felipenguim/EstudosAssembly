.data
codes:
    .ascii "0123456789ABCDEF"

newline:
    .ascii "\n"

.text 
.global _start

print_newline:
    mov x0, 1
    adr x1, newline
    //ldr x1, =newline
    mov x2, 1
    mov x8, #64
    svc #0
    ret

print_hex:
    mov x0, x1 // valor a ser impresso em x1
    
    mov x2, 1 //len vai ser de 1 byte por print
    mov x8, #64  // para o syscall de print

    mov x4, 64 
.loop:
    str x0, [sp, #-16]! // = sub sp, sp, #16   ; move o stack pointer pra baixo e depois str x0, [sp]      ; salva x0 no topo da pilha
    sub x4, x4, #4 // tradução do push

    asr x0, x0, x4
    and x0, x0, #0xF

    adr x1, codes
    add x1, x1, x0

    mov x0, 1

    svc #0

    //pop
    ldr x0, [sp], #16
    cmp x4, #0
    b.ne .loop

    ret

.global _start 

_start:
    ldr x1, =0x1122334455667788 //Da um load criando o valor grande em x1
    bl print_hex
    bl print_newline

    mov x0, #0
    mov x8, #93
    svc #0