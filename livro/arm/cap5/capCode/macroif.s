.set x, 5

.if x == 10
    mov x0, #100

.elif x == 15
    mov x0, #115

.elif x == 20
    mov x0, #0

.else
    mov x0, #1

.endif