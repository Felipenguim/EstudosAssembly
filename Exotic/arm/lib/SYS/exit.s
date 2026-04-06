.ifndef EXIT
.set EXIT, 1

.macro _exit
    //mov x0, #0
    //retorna o que estiver em x0
    //O exit code é só de 8 bits
    mov x8, #93
    svc #0
.endm

.endif
