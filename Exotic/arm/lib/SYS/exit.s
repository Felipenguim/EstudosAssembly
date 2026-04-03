.ifndef EXIT
.set EXIT, 1

.macro _exit
    //mov x0, #0
    //retorna o que estiver em x0
    mov x8, #93
    svc #0
.endm

.endif
