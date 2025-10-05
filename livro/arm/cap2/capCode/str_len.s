.data
    str_rand:
        .asciz "Random string for testing.\n" //asciz coloca o byte zero no final

.text 
.global _start

strlen:

    mov x0, #0
    .loop:
        ldrb w2, [x1], #1 //carrega um byte, tem que ser com w (32 bits)
        cmp w2, #0
        b.eq end
        add x0, x0, #1
        b .loop

    end:
        ret

_start:
    adrp x1, str_rand
    add  x1, x1, :lo12:str_rand
    bl strlen
    
    mov x8, #93
    svc #0
// sairá dizendo que tem erro, pq x0 não está com 0 e sim com o valor de strlen, mas o valor de strlen está correto e posso ver com echo $?