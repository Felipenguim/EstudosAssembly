

.IFNDEF MATRIX_EXTRACT_COLUMN
.EQU MATRIX_EXTRACT_COLUMN, 1
///////////////////////////////////////////////////////////////////////////////

// void matrix_extract_column(double* {vec}, double* {mat}, uint {rows}, uint {cols}, uint {col})
// extracts column {col} of a {rows}x{cols} matrix at {mat} into {rows}x1 vector at {vec}.
// NOTE: works for any 8-byte element type, not just doubles.
// @param vec  X0 — pointer to the first element of the destination column vector
// @param mat  X1 — pointer to the first element of the source matrix
// @param rows X2 — number of rows in the matrix (and elements in the extracted column)
// @param cols X3 — number of columns in the matrix
// @param col  X4 — index of the column to extract (0-based)
matrix_extract_column:
	stp x29, x30, [sp, -16]!
    str x5, [sp, -16]!

    lsl x4, x4, #3 //target column em offsets de bytes
    add x1, x1, x4 //pointer para a source + offset 

    lsl x3, x3, #3 //to indicate byte-width of matrix


.loop_extract_column:
    ldr x5, [x1]
    str x5, [x0]

    add x1, x1, x3 //next element for column in source
    add x0, x0, #8

    sub x2, x2, #1
    cbnz x2, .loop_extract_column
    
    ldr x5, [sp], #16
	ldp x29, x30, [sp], #16
	ret

    


.ENDIF

