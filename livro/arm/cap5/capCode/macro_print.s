.macro print arg
    // Caso seja um número literal
    .if \arg >= 0
        mov x0, #\arg
        bl print_uint
    .else
        // Caso seja um símbolo (label)
        adr x0, \arg
        bl print_string
    .endif
.endm