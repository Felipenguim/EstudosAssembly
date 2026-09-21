.IFNDEF MATRIX_POPULATE
.EQU MATRIX_POPULATE, 1

.INCLUDE "SYS/getrandom.s"

///////////////////////////////////////////////////////////////////////////////

// void matrix_populate(double* {x0}, double* {x1}, uint {x2}, uint {x3}, uint {x4}, uint {x5})
// Populates the {x2} x {x3} double-precision matrix beginning at {x0} with
// data read from {x1}, using {x4} bytes between rows and {x5} bytes
// between columns of the source data.
// NOTE: works for any 8-byte element type, not just doubles.
// @param dst        x0 — pointer to the first element of the destination matrix
// @param src        x1 — pointer to the first element to read from the source
// @param rows       x2 — number of rows to populate
// @param cols       x3 — number of columns to populate
// @param row_stride x4 — byte offset between consecutive rows in the source
// @param col_stride x5 — byte offset between consecutive columns in the source
matirx_populate:
	stp x29, x30, [sp, -16]!
	stp x6, x7, [sp, -16]!
	stp x19, x20, [sp, -16]!
    
	lsl x3, x3, #3 //*8, numero de bytes]

	.loop_rows:
		mov x6, #0 //offset para a coluna na matriz

	.loop_cols: //elemento a elemento
		mov x19, x1
		add x19, x19, x6 //pega o elemento com o offset
		mov x7, x19 //x7 com addr de x1
		ldr x20, [x7] // LÊ da fonte para x20
		str x20, [x0] //guarda em destination o elemtno

		add x0, x0, #8 //próximo elemento
		add x6, x6, x5 //

		cmp x6, x3

		b.lo .loop_cols

		add x1, x1, x4 //nex row of source 
		sub x2, x2, #1
		cbnz x2, .loop_rows

	ldp x19, x20, [sp], #16
	ldp x6, x7, [sp], #16
	ldp x29, x30, [sp], #16
	ret


.ENDIF

