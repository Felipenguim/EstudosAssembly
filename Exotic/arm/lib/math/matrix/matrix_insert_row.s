

.IFNDEF MATRIX_INSERT_ROW
.EQU MATRIX_INSERT_ROW, 1
///////////////////////////////////////////////////////////////////////////////

// void matrix_insert_row(double* {mat}, double* {vec}, uint {cols}, uint {row})
// inserts 1x{cols} vector at {vec} into row {row} of an {ANY}x{cols} matrix at {mat}.
// NOTE: works for any 8-byte element type, not just doubles.
// @param mat  X0 — pointer to the first element of the destination matrix
// @param vec  X1 — pointer to the first element of the source row vector
// @param cols X2 — number of columns in the matrix (and elements in the vector)
// @param row  X3 — index of the row to insert into (0-based)
matrix_insert_row:
	stp x29, x30, [sp, -16]!
	str x5, [sp, -16]!
    
	lsl x3, x3, #3 //* 8 para ter a len em bytes
	mul x3, x3, x2
	add x0, x0, x3

.loop_insert_row:
	ldr x5, [x1] //grab source
    str x5, [x0] //store in destination

	add x1, x1, #8
	add x0, x0, #8

	sub x2, x2, #1
	cbnz x2, .loop_insert_row

	ldr x5, [sp], #16
	ldp x29, x30, [sp], #16
	ret


.ENDIF

