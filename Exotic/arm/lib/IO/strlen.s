.IFNDEF STRLEN
.EQU STRLEN,1


// int {x0} strlen (char* {char_arr})
//	Returns in {x0} the length of null-terminated char array starting at 
//	x0.
// @param char_arr x0 - null-terminated char array
strlen: 
    stp x1, x2, [sp, #-16]!

    mov x1, x0 //guardando o valor de do endereço em x1
    mov x0, #-1 //strlen counter = -1

.loop_strlen:
    add x0, x0, #1
    ldrb w2, [x1, x0]
    cmp w2, #0
    b.ne .loop_strlen
    
    ldp x1, x2, [sp], #16
    ret
.ENDIF
