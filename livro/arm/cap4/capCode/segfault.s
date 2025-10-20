        .section .data
correct:
        .quad -1

        .section .text
        .global _start
_start:
        ldr     x1, =0x3FFFFF //endereço invalido
        ldr     x0, [x1]

        mov     x0, #0        
        mov     x8, #93      
        svc     #0
