// .byte -> 8 bits
@ .hword → 16 bits
@ .word → 32 bits
@ .quad → 64 bits


.data
    example1:
        .byte 5, 16, 8, 4, 2, 1

    example2:
        .rept 999
            .byte 42
        .endr    // 999 entradas, cada uma de 1 byte, valor 42

    example3:
        .hword 999     