

.IFNDEF MATRIX_INSERT_COLUMN
.EQU MATRIX_INSERT_COLUMN, 1
///////////////////////////////////////////////////////////////////////////////

// void matrix_insert_column(double* {mat}, double* {vec}, uint {rows}, uint {cols}, uint {col})
// inserts {rows}x1 vector at {vec} into column {col} of {rows}x{cols} matrix at {mat}.
// NOTE: works for any 8-byte element type, not just doubles.
// @param mat  X0 — pointer to the first element of the destination matrix
// @param vec  X1 — pointer to the first element of the source column vector
// @param rows X2 — number of rows in the matrix (and elements in the vector)
// @param cols X3 — number of columns in the matrix
// @param col  X4 — index of the column to insert into (0-based)
matrix_insert_column:
	stp x29, x30, [sp, -16]!
	str x5, [sp, -16]!

    
    lsl x4, x4, #3 //target column em offsets de bytes
    add x0, x0, x4 

    lsl x3, x3, #3 
.loop_insert_column:
	ldr x5, [x1]
    str x5, [x0]

	add x1, x1, #8 //next element of source
	add x0, x0, x3
	sub x2, x2, #1
    cbnz x2, .loop_insert_column

	ldr x5, [sp], #16
	ldp x29, x30, [sp], #16
	ret


.ENDIF

