.IFNDEF PRINT_STRING
.EQU PRINT_STRING,1

.INCLUDE "IO/print_chars.s"

// void print_string(int {fd}, char* {str})
// Writes null-terminated char array starting at {str} to file 
// @param fd X0 — file descriptor to write to (e.g. 1 for stdout, 2 for stderr)
// @param str X1 — pointer to char array to write
print_string:
    str x30, [sp, #-16]!

    mov x2, #-1

.find_null_loop:
    add x2, x2, #1
    ldrb w3, [x1, x2] //load byte at str+len
    cbnz w3, .find_null_loop //continue until hit null terminator
    bl print_chars
    ldr x30, [sp], #16
    ret
.ENDIF
