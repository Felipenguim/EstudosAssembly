.IFNDEF PRINT_BUFFER_FLUSH
.EQU PRINT_BUFFER_FLUSH,1

///////////////////////////////////////////////////////////////////////////////

// void _print_buffer_flush(int {fd})
// Flushes the PRINT_BUFFER to file descriptor {rdi}.
// @param fd X0 — file descriptor to flush buffer(e.g. 1 for stdout, 2 for stderr)
print_buffer_flush:
	//saving used registers
	stp x9, x15, [sp, #-16]!

	adr x1, PRINT_BUFFER
	.b: 
	adr x9, PRINT_BUFFER_LEN
	ldr x2, [x9] 
	.a:
	mov x8, #64 //SYS_WRITE
	SVC #0

	mov x15, #0
	str x15, [x9] // reset buffer length to 0

	ldp x9, x15, [sp], #16 //restoring used registers

	ret
//se for deixar como macro o PRINT_BUFFER_LEN tem que ser uma label global
//Definida na main

PRINT_BUFFER_LEN:
    .quad 0

.ENDIF
