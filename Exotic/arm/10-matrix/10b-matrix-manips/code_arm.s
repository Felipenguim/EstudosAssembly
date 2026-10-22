//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.arch armv8-a
.equ LOAD_ADDRESS, 0x8000
.equ CODE_SIZE, (END-END_HEADER) // everything beyond the HEADER is code
.equ PRINT_BUFFER_SIZE, 4096 // 4KB buffer for printing (must be large enough to hold all output)
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;HEADER;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

//.org LOAD_ADDRESS
ELF_HEADER:
	.byte 0x7F,'E','L','F' // magic number to indicate ELF file
	.byte 0x02 // 0x1 for 32-bit, 0x2 for 64-bit
	.byte 0x01 // 0x1 for little endian, 0x2 for big endian
	.byte 0x01 // 0x1 for current version of ELF
	.byte 0x00 // 0x9 for FreeBSD, 0x3 for Linux (doesn't seem to matter)
	.byte 0x00 // ABI version (ignored?)
	.fill 7, 1, 0x00 // 7 padding bytes
	.short 0x0002 // executable file
	.short 0x00B7 // ARMv8a
	.word 0x00000001 // version 1
	.quad LOAD_ADDRESS+(START-ELF_HEADER) // entry point for our program
	.quad 0x0000000000000040 // 0x40 offset from ELF_HEADER to PROGRAM_HEADER
	.quad 0x0000000000000000 // section header offset (we don't have this)
	.word 0x00000000 // unused flags
	.short 0x0040 // 64-byte size of ELF_HEADER
	.short 0x0038 // 56-byte size of each program header entry
	.short 0x0001 // number of program header entries (we have one)
	.short 0x0000 // size of each section header entry (none)
	.short 0x0000 // number of section header entries (none)
	.short 0x0000 // index in section header table for section names (waste)
PROGRAM_HEADER:
	.word 0x00000001 // 0x1 for loadable program segment
	.word 0x00000007 // read/write/execute flags
	.quad 0x0000000000000078 // offset of code start in file image (0x40+0x38)
	.quad LOAD_ADDRESS+0x78 // virtual address of segment in memory
	.quad 0x0000000000000000 // physical address of segment in memory (ignored?)
	.quad CODE_SIZE // size (bytes) of segment in file image
	.quad CODE_SIZE + PRINT_BUFFER_SIZE // size (bytes) of segment in memory
	.quad 0x0000000000000000 // alignment (doesn't matter, only 1 segment)
END_HEADER:

//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INCLUDES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

//.EQU VERBOSE_LOGS, 1

.INCLUDE "SYS/LINUX/SYSCALLS.S"
.INCLUDE "SYS/exit.s"

.INCLUDE "IO/print_chars.s"

.INCLUDE "IO/print_float_array.s"

.INCLUDE "IO/mem_copy.s"
.INCLUDE "math/matrix/matrix_insert_row.s"
.INCLUDE "math/matrix/matrix_extract_row.s"
.INCLUDE "math/matrix/matrix_extract_column.s"
.INCLUDE "math/matrix/matrix_insert_column.s"
.INCLUDE "math/matrix/matrix_transpose.s"


//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INSTRUCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:

	// print "\nInitial Matrix=\n"
	mov x0, #1
	adr x1, .grammar0
	mov x2,.grammar1-.grammar0
	bl print_chars

	// print initial matrix
	mov x0, #1
	adr x1, MATRIX
	mov x2, #4
	mov x3, #3
	mov x4, #0
	adr x5, print_float
	mov x6, #5
	bl print_array_float

	// print "\nInitial Row Vector=\n"
	mov x0, #1
	adr x1, .grammar1
	mov x2,.grammar2-.grammar1
	bl print_chars

	// print initial row vector
	mov x0, #1
	adr x1, VECTOR_3
	mov x2, #1
	mov x3, #3
	mov x4, #0
	adr x5, print_float
	mov x6, #5
	bl print_array_float

	// print "\nInitial Column Vector=\n"
	mov x0, #1
	adr x1, .grammar2
	mov x2,.grammar3-.grammar2
	bl print_chars

	// print initial column vector
	mov x0, #1
	adr x1, VECTOR_4
	mov x2, #4
	mov x3, #1
	mov x4, #0
	adr x5, print_float
	mov x6, #5
	bl print_array_float

	// print "\nMatrix with Row 2 Inserted=\n"
	mov x0, #1
	adr x1, .grammar3
	mov x2,.grammar4-.grammar3
	bl print_chars

	// insert row into 3rd row of matrix
	adr x0, MATRIX
	adr x1, VECTOR_3
	mov x2, #3
	mov x3, #2
	bl matrix_insert_row

	// print matrix
	mov x0, #1
	adr x1, MATRIX
	mov x2, #4
	mov x3, #3
	mov x4, #0
	adr x5, print_float
	mov x6, #5
	bl print_array_float

	// print "\nMatrix with Column 1 Inserted=\n"
	mov x0, #1
	adr x1, .grammar4
	mov x2,.grammar5-.grammar4
	bl print_chars

	// insert column into 2nd column of matrix
	adr x0, MATRIX
	adr x1, VECTOR_4
	mov x2, #4
	mov x3, #3
	mov x4, #1
	bl matrix_insert_column

	// print matrix
	mov x0, #1
	adr x1, MATRIX
	mov x2, #4
	mov x3, #3
	mov x4, #0
	adr x5, print_float
	mov x6, #5
	bl print_array_float

	// print "\nMatrix Transposed=\n"
	mov x0, #1
	adr x1, .grammar5
	mov x2,.grammar6-.grammar5
	bl print_chars

	// transpose matrix
	adr x0, MATRIX_TRANSPOSED
	adr x1, MATRIX
	mov x2, #4
	mov x3, #3
	bl matrix_transpose

	// print transposed matrix
	mov x0, #1
	adr x1, MATRIX_TRANSPOSED
	mov x2, #3
	mov x3, #4
	mov x4, #0
	adr x5, print_float
	mov x6, #5
	bl print_array_float

	// print "\nRow 0 Vector Extracted=\n"
	mov x0, #1
	adr x1, .grammar6
	mov x2,.grammar7-.grammar6
	bl print_chars

	// extract 1st row to vector
	adr x0, VECTOR_4
	adr x1, MATRIX_TRANSPOSED
	mov x2, #4
	mov x3, #0
	bl matrix_extract_row

	// print extracted row vector
	mov x0, #1
	adr x1, VECTOR_4
	mov x2, #1
	mov x3, #4
	mov x4, #0
	adr x5, print_float
	mov x6, #5
	bl print_array_float

	// print "\nColumn 0 Vector Extracted=\n"
	mov x0, #1
	adr x1, .grammar7
	mov x2,MATRIX-.grammar7
	bl print_chars

	// extract 1st column to vector
	adr x0, VECTOR_4
	adr x1, MATRIX_TRANSPOSED
	mov x2, #3
	mov x3, #4
	mov x4, #0
	bl matrix_extract_column

	// print extracted column vector
	mov x0, #1
	adr x1, VECTOR_4
	mov x2, #3
	mov x3, #1
	mov x4, #0
	adr x5, print_float
	mov x6, #5
	bl print_array_float

	bl print_buffer_flush
	mov x0, #0 // exit code 0
	_exit

MATRIX:
	.rept 12
	.double 0.0
	.endr

MATRIX_TRANSPOSED:
	.rept 12
	.double 0.0
	.endr

VECTOR_3:
	.rept 3
	.double 777.77
	.endr

VECTOR_4:
	.rept 4
	.double 666.66
	.endr

.grammar0:
	.ascii "\nInitial Matrix=\n"
.grammar1:
	.ascii "\nInitial Row Vector=\n"
.grammar2:
	.ascii "\nInitial Column Vector=\n"
.grammar3:
	.ascii "\nMatrix with Row 2 Inserted=\n"
.grammar4:
	.ascii "\nMatrix with Column 1 Inserted=\n"
.grammar5:
	.ascii "\nMatrix Transposed=\n"
.grammar6:
	.ascii "\nRow 0 Vector Extracted=\n"
.grammar7:
	.ascii "\nColumn 0 Vector Extracted=\n"

END:

PRINT_BUFFER:
