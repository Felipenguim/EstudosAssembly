// ARM64 skeleton of utility functions
// Each function currently just clears registers and returns

.data

newline:
    .ascii "\n"


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
        b.eq end
        add x0, x0, #1
        b .loop

    end:       // return em x0
        ret


print_string: //recebe o ponteiro da string em x0, string deve ser terminada em zero
    //x0 deve ter o endereço da string
    mov x19, x0
    bl string_length
    mov x2, x0
    mov x1, x19
    mov x0, 1
    mov x8, #64
    svc #0
    mov x0, #0
    ret


print_char: 
    //x0 deve ter o char a ser impresso
    sub sp, sp, #16 // criar espaço na pilha
    strb w0, [sp]   // salvar o char na pilha
    mov x1, sp // carrega o endereço do char
    mov x0, 1
    mov x2, 1
    mov x8, #64
    mov x0, #0

    add sp, sp, #16 // liberar espaço na pilha
    ret


print_newline:
    mov x0, 1
    adr x1, newline
    mov x2, 1
    mov x8, #64
    mov x0, #0
    ret


print_uint:
    mov x0, #0
    ret


print_int:
    mov x0, #0
    ret


string_equals:
    mov x0, #0
    ret


read_char:
    mov x0, #0
    ret


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


string_copy:
    ret
