//%define não sabe o que é instrução, registrador, nada.
//É texto → texto.

//.set só aceita expressões numéricas ou relocáveis, por exemplo:

//.set SIZE, 42
//.set FLAG, 0x10

.macro a 
    mov x0, 
.endm

.macro b
    x1
.endm

.global _start

.text
_start:
    a b