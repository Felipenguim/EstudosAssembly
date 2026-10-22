.macro test a, b, c
    .quad \a
    .quad \b
    .quad \c

.endm

//uso
test 666, 555, 444