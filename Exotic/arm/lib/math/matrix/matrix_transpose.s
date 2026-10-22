

.IFNDEF MATRIX_TRANSPOSE
.EQU MATRIX_TRANSPOSE, 1
///////////////////////////////////////////////////////////////////////////////

// void matrix_transpose(double* {dst}, double* {src}, uint {rows}, uint {cols})
// transposes {rows}x{cols} matrix at {src} into {cols}x{rows} matrix at {dst}.
// NOTE: works for any 8-byte element type, not just doubles.
// @param dst  X0 — pointer to the first element of the destination (transposed) matrix
// @param src  X1 — pointer to the first element of the source matrix
// @param rows X2 — number of rows in the source matrix
// @param cols X3 — number of columns in the source matrix
matrix_transpose:
	stp x29, x30, [sp, -16]!
	stp x5, x6,  [sp, -16]!
	stp x7, x9,  [sp, -16]!
	str x10,  [sp, -16]!
    
	mov x5, x3 //guardando o n_cols
	mul x5, x5, x2 //n_cols * n_rows
	lsl x5, x5, #3 //n_cols * n_rows em bytes (len total)
	add x5, x5, x1 //endereço no fim de source

	mov x6, x3 //row counter
	mov x7, x2
	lsl x7, x7, #3
	mov x9, x0 //inicio de destination

.loop_matrix_transpose:
	ldr x10, [x1] //grab source
    str x10, [x9] //store in destination

	add x1, x1, #8
	add x9, x9, x7 //movo to next row in dest

	sub x6, x6, #1
	cbnz x6, .loop_matrix_transpose

	cmp x1, x5 //chegou no fim?
	b.ge .done_matrix_transpose

	mov x6, x3 //reset
	add x0, x0, #8
	mov x9, x0 //next column of destination
	
	b .loop_matrix_transpose

.done_matrix_transpose:

	ldr x10, [sp], #16
	ldp x7, x9, [sp], #16
	ldp x5, x6, [sp], #16
	ldp x29, x30, [sp], #16
	ret


.ENDIF

