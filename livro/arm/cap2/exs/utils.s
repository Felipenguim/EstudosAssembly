// ARM64 skeleton of utility functions
// Each function currently just clears registers and returns

.data

newline:
    .ascii "\n"
signal:
    .ascii "-"


.section .text
.global string_length
.global print_string
.global print_char
.global print_newline
.global print_uint
.global print_int
.global string_equals
.global read_char
.global read_word
.global parse_uint
.global parse_int
.global string_copy
.global exit
.global success_exit

exit:
// deve receber o x0 com algum código de saída
    mov x8, #93
    svc #0

success_exit:
    mov x0, #0
    mov x8, #93
    svc #0

string_length:
    // Entrada: x0 = endereço da string
    // Saída:   x0 = comprimento (número de caracteres até o byte 0)

    mov x1, x0 
    mov x0, #0
    .loop:
        ldrb w2, [x1], #1 //carrega um byte, tem que ser com w (32 bits)
        cmp w2, #0
        b.eq .done
        add x0, x0, #1
        b .loop

    .done:       // return em x0
        ret


print_string: //recebe o ponteiro da string em x0, string deve ser terminada em zero
    //x0 deve ter o endereço da string

     stp     x29, x30, [sp, -16]!
    mov     x29, sp
    mov x15, x0
    bl string_length
    mov x2, x0 //passa o len para x2
    mov x1, x15 //x15 é o ponteiro, passa o endereço para x1
    mov x0, 1
    mov x8, #64
    svc #0
    mov x0, #0
    ldp     x29, x30, [sp], 16
    ret


print_char: 
    //x0 deve ter o char a ser impresso
    sub sp, sp, #16 // criar espaço na pilha
    strb w0, [sp]   // salvar o char na pilha
    mov x1, sp // carrega o endereço do char
    mov x0, 1
    mov x2, 1
    mov x8, #64
    svc #0

    mov x0, #0

    add sp, sp, #16 // liberar espaço na pilha
    ret


print_newline:
    mov x0, 1
    adr x1, newline
    mov x2, 1
    mov x8, #64
    svc #0
    mov x0, #0
    ret




int_to_string:    
    mov x2, #10 //divisor
    .next_digit:
        //udiv xQ, xN, xD     // xQ = xN / xD  (divisão sem sinal)
        //msub xR, xQ, xD, xN // xR = xN - (xQ * xD)
        udiv x4, x0, x2 
        msub x1, x4, x2, x0 //pega o resto
        add w1, w1, #'0'
        sub x3, x3, #1
        strb w1, [x3]
        mov x0, x4
        cbnz  x0, .next_digit  //compare branch non zero repete enquanto x0 != 0
        ret

// Entrada:
//   x0 = número sem sinal de 64 bits
// Saída:
//   string decimal termina no buffer (terminada em 0)
//   x3 = ponteiro para o início da string
print_uint:
    stp  x29, x30, [sp, -16]!
    mov  x29, sp


    sub sp, sp, #32
    add x3, sp, #32 // aponta para o fim do buffer
    mov w1, #0 //para terminar com nulo 
    strb w1, [x3, #-1]!
    bl int_to_string
    mov x0, x3
    bl print_string
    add sp, sp, #32
    mov x0, #0  
    ldp x29, x30, [sp], 16
    ret

// Entrada:
//  x0 = número sem sinal de 64 bits
print_int:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    sub sp, sp, #32
    add x3, sp, #32 // aponta para o fim do buffer
    mov w1, #0 //para terminar com nulo 
    strb w1, [x3, #-1]!
    mov x15, x0
    //usar o x15 para ver se é positivo ou negativo 
    lsr x12, x0, 63 //poderia usar o tst x0, x0 que já pegaria esse bit de sinal
    cbz x12, .positive //compare e branch se x12 == 0
    mov x0, 1
    adr x1, signal
    mov x2, 1
    mov x8, #64
    svc #0
    mov x0, #0
    neg x15, x15 // só faz se for negativo
    
    .positive:
        mov x0, x15
        bl int_to_string
        mov x0, x3
        bl print_string
        add sp, sp, #32 

        mov x0, #0
        ldp x29, x30, [sp], 16
        ret

    
// devo abrir o espaço na pilha e colocar um ponteiro em x1
read_char:
    stp x29, x30, [sp, -16]!
    mov x29, sp

    sub sp, sp, #16
    mov x1, sp //endereço onde será guardado
    mov x8, 63 //syscall de read
    mov x0, #0 //stdin
    mov x2, #1 //1 byte a ler
    svc #0

    //vai para x0
    cmp x0, #0
    b.eq .nothing

    ldrb w0, [sp]
    bl print_char
    add sp, sp, #16
    ldp x29, x30, [sp], 16
    ret
     
    .nothing: //vem pra ca no ctrl + d
        mov x0, '0' 
        bl print_char
        add sp, sp, #16
        ldp x29, x30, [sp], 16
        ret

//entrada:
//   1 - endereço de buffer (x1) // o espaço a ser reservado será feito antes da função
//   2 - tamanho (x2)
//ACHO Q VAI SER UM LOOP DE READ_CHAR
read_word:
    ret


// x0 points to a string
// returns x0: number, x1: length
parse_uint:
    mov x0, #0
    mov x1, #0
    ret


// x0 points to a string
// returns x0: number, x1: length
parse_int:
    mov x0, #0
    mov x1, #0
    ret

string_equals:
    mov x0, #0
    ret

string_copy:
    ret
