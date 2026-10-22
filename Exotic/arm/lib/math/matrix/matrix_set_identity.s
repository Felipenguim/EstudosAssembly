

.IFNDEF MATRIX_SET_IDENTITY
.EQU MATRIX_SET_IDENTITY, 1
///////////////////////////////////////////////////////////////////////////////

// void matrix_set_identity(double* {x0}, uint {x1}, uint {x2})
// Sets the {x1}x{x2} double-precision matrix beginning at {x0} to the
// identity matrix. Assumes {x1} == {x2} (square matrix).
// @param mat  x0 — pointer to the first element of the matrix
// @param rows x1 — number of rows
// @param cols x2 — number of columns
matrix_set_identity:
	stp x29, x30, [sp, -16]!
	stp x3, x7, [sp, -16]!
	
    

    fmov d1, #1.0
    movi d0, #0
    mov x3, x2 //x3 n cols 
    str d1, [x0], #8 //primeiro elemento da diagonal
    sub x1, x1, #1

.next_diagonal:
    str d0, [x0], #8 //elemento fora da diagonal {0}
    sub x3, x3, #1
    cbnz x3, .next_diagonal //loop for {x3}+1 elements

    mov x3, x2 //restaurar o numero de colunas
    str d1, [x0], #8 //{1}
    sub x1, x1, #1
    cbnz x1, .next_diagonal


	ldp x3, x7, [sp], #16
	ldp x29, x30, [sp], #16
	ret


.ENDIF

