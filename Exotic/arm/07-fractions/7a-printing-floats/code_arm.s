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
.INCLUDE "IO/print_memory.s"
.INCLUDE "IO/print_stack.s"
.INCLUDE "IO/print_buffer_flush.s"

.INCLUDE "IO/print_int_b.s"
.INCLUDE "IO/print_int_o.s"
.INCLUDE "IO/print_int_h.s"
.INCLUDE "IO/print_int_d.s"

//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INSTRUCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:

	

	mov x0, #1
	mov x1, #1 //indexado em 0, se x1 = 1 printa sp+8 e sp+0
	adr x2, print_int_d
	mov x9, #777
	mov x10, #67
	stp x9, x10, [sp, #-16]!
	bl print_stack
	ldp x9, x10, [sp], #16
	

	mov x0, #1
	adr x1, ARRAY
	adr x2, print_int_h
	mov x3, 15*8
	bl print_memory

	bl print_buffer_flush

	mov x0, #0 // exit code 0
	_exit


ARRAY:
    .quad 11845, 2, 3, 4, 58412416532157
	.quad 6, 7, 8, 9, -10
	.quad 11, 12, 11845452, 14, -15



END:


PRINT_BUFFER:
