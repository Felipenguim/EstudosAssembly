//exemplo não funcional de como seria uma máquina de estados simples em assembly ARM

.section .text

.global _start

_start:
    b _A

_A:
    bl getsymbol        // w0 = caractere

    cmp w0, '+'
    b.eq _B

    cmp w0, '-'
    b.eq _B

    // '0' .. '9'
    cmp w0, '0'
    b.lo _E             // abaixo de '0'

    cmp w0, '9'
    b.hi _E             // acima de '9'

    b _C  //estado final correto 

_B:
    bl getsymbol

    cmp w0, #'0'
    b.lo _E

    cmp w0, #'9'
    b.hi _E

    b _C

_C:
    bl getsymbol

    cmp w0, #'0'
    b.lo _E

    cmp w0, #'9'
    b.hi _E

    cbz w0, _D      // se w0 == 0 → sucesso

    b _C            // continua lendo dígitos



_D:
    // sucesso
    bl success_exit



_E:
    // falha
    mov x0, #1
    bl exit