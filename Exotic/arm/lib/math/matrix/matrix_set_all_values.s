

.IFNDEF MATRIX_SET_ALL_VALUES
.EQU MATRIX_SET_ALL_VALUES, 1
///////////////////////////////////////////////////////////////////////////////

// void matrix_set_all_values(double* {x0}, uint {x1}, double {d0})
// Sets each of the {x1} contiguous double-precision elements beginning
// at {x0} to the value in {d0}.
// @param mat x0 — pointer to the first element of the matrix
// @param n   x1 — total number of elements to set
// @param val d0 — value written into every element
matrix_set_all_values:
	//stp x29, x30, [sp, -16]!
    
    .loop_set_all_values_matrix: //loop mais cru e simples possível, tentar melhor depois 

        str d0, [x0], #8 //anda para o próximo elemento de 8 bytes 
        //offset post index 
        sub x1, x1, #1
        cbnz x1, .loop_set_all_values_matrix

	//ldp x29, x30, [sp], #16
	ret


.ENDIF

