.data
codes:
    .ascii "0123456789ABCDEF"

newline:
    .ascii "\n"

.text 
.global _start

_start:
    //number in hex
    //mov x0, #0x1122334455667788   o mov grande (maior que 16 bits) não funciona em arm64
    //movz x0, 0x7788, lsl #0 // carrega os 16 bits menos significativos
    //movk x0, 0x5566, lsl #16 // carrega os próximos 16 bits, mantendo os anteriores
    // movk x0, 0x3344, lsl #32
    // movk x0, 0x1122, lsl #48

    ldr x0, =0x1122334455667788 //outra forma de carregar um valor grande

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

    ldr x0, [sp], #16 // = ldr x0, [sp] ; carrega o valor salvo no topo da pilha de volta para x0 e depois add sp, sp, #16 ; move o stack pointer pra cima
    
    cmp x4, #0
    b.ne .loop // se não for zero pula pra .loop
    // poderia mudar as duas instruções acima por cnbz x4, .loop
    
    mov x0, 1
    adr x1, newline
    mov x2, 1
    mov x8, #64
    svc #0

    mov x0, #0          // exit code
    mov x8, #93         // syscall number for sys_exit
    svc #0              // invoke syscall