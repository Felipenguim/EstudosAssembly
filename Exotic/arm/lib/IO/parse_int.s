.IFNDEF PARSE_INT
.EQU PARSE_INT,1


// int {x0} parse_int (char* {char_arr})
//	Returns in {x0} the value of null-terminated char array starting at
//	x0.
// NOTE: Hex numbers must include the lower-case 
// 	alphabetic characters (0xabcdef)
// Beware: garbage in, garbage out
// @param char_arr x0 - null-terminated char array
parse_int: 
    stp x1, x2, [sp, #-16]!
    stp x3, x4, [sp, #-16]!

    mov x1, x0 //guardando o endereço

    ldrb w2, [x1, #1] //pega o segundo byte
    mov x0, #0 //retorno
    mov x3, #0 //flag de postivo ou negativo 

    cmp w2, #120 //"x"
    b.eq .hexadecimal
    cmp w2, #98 //"b"
    b.eq .binary 
    cmp w2, #111 //"o"
    b.eq .octal

    //decimal:
    mov x4, #10
    ldrb w2, [x1, #0]
    cmp w2, #45 //"-"
    b.ne .loop_parse_int
    add x1, x1, #1
    mov x3, #1 //negativo
    b .loop_parse_int

.hexadecimal:
    mov x4, #16
    add x1, x1, #2
    b .loop_parse_int

.binary:
    mov x4, #2
    add x1, x1, #2
    b .loop_parse_int

.octal:
    mov x4, #8
    add x1, x1, #2
    b .loop_parse_int


.loop_parse_int:
    ldrb w2, [x1, #0]
    sub x2, x2, #48
    cmp x2, #9
    b.le .not_hex
    sub x2, x2, #39
.not_hex:
    // mul x0, x0, x4
    // add x0, x0, x2
    madd x0, x0, x4, x2

    add x1, x1, #1
    ldrb w2, [x1, #0]
    cmp w2, #0
    b.ne .loop_parse_int

    cmp x3, #0
    b.eq .done_parse_int
    // mov x4, #-1
    // mul x0, x0, x4
    neg x0, x0



.done_parse_int:
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    ret
.ENDIF
