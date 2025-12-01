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
//   1 - endereço de buffer (x0) // o espaço a ser reservado será feito antes da função
//   2 - tamanho (x1)
//Saida:
//  0 em x0 se der errado
// endereço em x0 se der certo
read_word:
    stp x29, x30, [sp, -16]!
    mov x29, sp
    mov x15, x0 //passa o endereço para x15
    mov x12, x1 //passa o len para x12

    //leitura byte a byte:
    mov x3, #0 //vai guardando o tamnho 
    .first_char:
        sub sp, sp, #16
        mov x1, sp 
        mov x8, #63
        mov x0, #0 //stdin
        mov x2, #1 //1 byte a ler
        svc #0
        ldrb w4, [sp]
        add sp, sp, #16
        cmp w4, #0
        b.eq .eof

        cmp w4, #0x10
        b.eq .first_char
        cmp w4, #0x9
        b.eq .first_char
        cmp w4, #0x20
        b.eq .first_char
        
        
        b .store_first
    .store_first:
        sub x11, x12, #1     // tamanho útil (reserva 1 p/ terminador)
        cmp x11, x3
        b.le .failed
        strb w4, [x15, x3] //store byte em x15 + x3
        add x3, x3, #1
    .read_loop:
        sub sp, sp, #16
        mov x1, sp 
        mov x8, #63
        mov x0, #0 //stdin
        mov x2, #1 //1 byte a ler
        svc #0
        ldrb w4, [sp]
        add sp, sp, #16
        cmp w4, #0
        b.eq .finish

        cmp w4, #0x10
        b.eq .finish
        cmp w4, #0x9
        b.eq .finish
        cmp w4, #0x20
        b.eq .finish

        cmp x3, x11
        b.ge .failed
        strb w4, [x15, x3]
        add x3, x3, #1
        b .read_loop

    .finish:
        mov w4, #0
        strb w4, [x15, x3]
        mov x0, x15
        ldp x29, x30, [sp], 16
        ret

    .failed:
        mov x0, '0'  
        ldp x29, x30, [sp], 16
        ret  

    .eof:
        mov x0, '0' 
        ldp x29, x30, [sp], 16
        ret  



// x0 points to a string
// returns x0: number, x1: length
parse_uint:
    mov x15, x0 //guardando o endereço da string
    mov x3, #0 //contador len
    mov x2, #0 //contador real
    mov x0, #0 //conterá o numero final
    mov x12, #10 //multiplicador 
    .parse_loop:
        ldrb w4, [x15, x2] //load byte em w4 o endereço de x15 + valor do contador em x3
        add x2, x2, #1
        cmp w4, #0
        b.eq .end
        cmp w4, #48 
        b.lt .end
        cmp w4, #57
        b.gt .end  //pula se n for digito numerico, se quiser fazer uma versão que limpe é mais tenso
        
        add x3, x3, #1
        sub w4, w4, #48
        mul x0, x0, x12
        add x0, x0, x4
        b .parse_loop
    .end:
        mov x1, x3
        ret


// x0 points to a string
// returns x0: number, x1: length
parse_int:
    mov x15, x0 //guardando o endereço da string
    mov x3, #0 //contador len
    mov x2, #0 //contador real
    mov x0, #0 //conterá o numero final
    mov x12, #10 //multiplicador
    ldrb w4, [x15, x2]
    cmp w4, '-'
    b.eq .negative
    mov x10, #0 //flag de negativo
    .parse_loop_int:
        ldrb w4, [x15, x2] //load byte em w4 o endereço de x15 + valor do contador em x3
        add x2, x2, #1
        cmp w4, #0
        b.eq .end_int
        cmp w4, #48 
        b.lt .end_int
        cmp w4, #57
        b.gt .end_int  //pula se n for digito numerico, se quiser fazer uma versão que limpe é mais tenso
        
        add x3, x3, #1
        sub w4, w4, #48
        mul x0, x0, x12
        add x0, x0, x4
        b .parse_loop_int
    
    .negative:
    add x2, x2, #1
    mov x10, #1 //flag de negativo
    b .parse_loop_int
    
    .end_int:
        cmp x10, #0
        b.eq .fim
        neg x0, x0
        .fim:
            //x0 vem certinho
            mov x1, x3
            ret

// x0 points to a string
// x1 points to another string
// returns 0: s0!=s1 returns 1: s0 == s1
string_equals:
    stp  x29, x30, [sp, -16]!
    mov  x29, sp

    mov x15, x0 //string 0
    mov x12, x1 //string 1

    .loop_str_eq:
        ldrb w2, [x15], #1 //carrega o byte com post-incremento
        ldrb w3, [x12], #1
        cmp x2, x3
        b.ne .strings_not_equal  //se não forem iguais
        cmp x2, #0
        b.ne .loop_str_eq // não acabou, continua o loop
        mov x0, #1 
        ldp x29, x30, [sp], 16
        ret
    .strings_not_equal:
        mov x0, #0  
        ldp x29, x30, [sp], 16
        ret

//recebe em x0 o ponteiro para a string
//recebe em x1 o ponteiro para onde copiar, ponteiro para o buffer
//recebe em x2 o tamanho do buffer
//retorna em x0 o endereço do buffer ou 0 se der erro
string_copy:
    stp x29, x30, [sp, -16]!
    mov x29, sp

    mov x15, x0
    mov x12, x1 //endereço original do buffer
    mov x14, x1
    mov x9, x2 //para não quebrar o x2 no string_length
    bl string_length //devolve tamanho em x0
    cmp x0, x9
    b.gt .buffer_too_small //se o tamanho da string for maior que o buffer, erro
    .loop_copy:
        ldrb w3, [x15], #1
        strb w3, [x12], #1 //não da pra usar x1, ele é alterado no string_length
        cmp w3, #0
        b.ne .loop_copy
        mov x0, x14 //devolve o endereço original do buffer
        ldp x29, x30, [sp], 16
        ret

    .buffer_too_small:
        mov x0, #0
        ldp x29, x30, [sp], 16
        ret
