//%ifidn A, B = if identifiers are identical

.macro pushr reg
    str \reg, [sp, #-16]!
.endm

.macro popr reg
    ldr \reg, [sp], #16
.endm

pushr x0
pushr x1

; código

popr x1
popr x0