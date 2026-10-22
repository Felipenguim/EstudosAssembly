

.IFNDEF MATRIX_EXTRACT_ROW
.EQU MATRIX_EXTRACT_ROW, 1
///////////////////////////////////////////////////////////////////////////////

// void matrix_extract_row(double* {vec}, double* {mat}, uint {cols}, uint {row})
// extracts row {row} of an {ANY}x{cols} matrix at {mat} into 1x{cols} vector at {vec}.
// NOTE: works for any 8-byte element type, not just doubles.
// @param vec  X0 — pointer to the first element of the destination row vector
// @param mat  X1 — pointer to the first element of the source matrix
// @param cols X2 — number of columns in the matrix (and elements in the extracted row)
// @param row  X3 — index of the row to extract (0-based)
matrix_extract_row:
	stp x29, x30, [sp, -16]!
	str x5, [sp, -16]!
    
	lsl x3, x3, #3 //* 8 para ter a len em bytes
	mul x3, x3, x2
	add x1, x1, x3

.loop_extract_row:
	ldr x5, [x1] //grab source
    str x5, [x0] //store in destination

	add x1, x1, #8
	add x0, x0, #8

	sub x2, x2, #1
	cbnz x2, .loop_extract_row

	ldr x5, [sp], #16
	ldp x29, x30, [sp], #16
	ret


.ENDIF

