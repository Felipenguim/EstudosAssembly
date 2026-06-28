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

.INCLUDE "IO/parse_int.s"
.INCLUDE "IO/read_chars.s"
.INCLUDE "IO/print_chars.s"
.INCLUDE "IO/print_buffer_flush.s"

//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INSTRUCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
	//saving old termios
	mov x8, #29 //numero da syscal para sys_ioctl
	mov x0, #0//fd stdin  
	mov x1, #0x5401 //tcgets
	adr x2, OLD
	svc #0


	//save "new" termios placeholder 
	mov x8, #29 //numero da syscal para sys_ioctl
	mov x0, #0//fd stdin  
	mov x1, #0x5401 //tcgets
	adr x2, NEW
	svc #0

	//ajustando para o raw mode
	adr x3, NEW 
	ldr w0, [x3]  // carrega c_iflag (offset 0)
	mov x1, #0x5EB //mascará de bits a limpar
	bic  w0, w0, w1       // w0 = w0 AND NOT w1
	// mvn  w1, w1          // w1 = NOT w1   (mvn = "move not")
    // and  w0, w0, w1      // w0 = w0 AND (NOT máscara)
	str w0,[x3]

	ldr w0, [x3, #4]  // carrega (offset 4)
	mov x1, #0x1 //mascará de bits a limpar
	bic  w0, w0, w1       // w0 = w0 AND NOT w1
	str w0,[x3, #4]

	ldr w0, [x3, #8]  // carrega (offset 8)
	mov x1, #0x130 //mascará de bits a limpar
	mov x2, #0x30 //SYS_CS8
	bic  w0, w0, w1       // w0 = w0 AND NOT w1
	orr w0, w0, w2
	str w0,[x3, #8]

	ldr w0, [x3, #12]  // carrega (offset 12)
	mov x1, 0x804B //mascará de bits a limpar
	bic  w0, w0, w1       // w0 = w0 AND NOT w1
	str w0,[x3, #12]
	


	//set terminal to new termios for raw mode 
	mov x8, #29 //numero da syscal para sys_ioctl
	mov x0, #0//fd stdin  
	mov x1, #0x5402 //tcset
	adr x2, NEW
	svc #0

	.loop_keys:
		adr  x9, READ_BUFFER
		str  wzr, [x9]          // zera os 4 bytes (wzr = registrador zero de 32 bits)

		mov  x0, #0             // stdin
		mov  x1, x9             // buffer
		mov  x2, #4             // 4 bytes
		_read

		ldrb w11, [x9]          // primeiro byte

		cmp  w11, #106          // 'j'
		b.eq .j_key
		cmp  w11, #32           // espaço
		b.eq .space_key
		

		ldr w10, [x9]
		movz w1, #0x5b1b        // w1 = 0x00005b1b  (põe a metade baixa, zera o resto)
    	movk w1, #0x0041, lsl #16   // w1 = 0x00415b1b  (põe a metade alta, mantém a baixa)
		cmp w10, w1
		b.eq .up_arrow

		cmp  w11, #27           // ESC
		b.eq .done
		cmp  w11, #113          // 'q'
		b.eq .done

		b    .loop_keys

	.j_key:
		mov x0, #1
		adr x1, msg_j
		mov x2, #15
		bl print_chars
		bl print_buffer_flush
		b .loop_keys
	
	.space_key:
		mov x0, #1
		adr x1, msg_space
		mov x2, #19
		bl print_chars
		bl print_buffer_flush
		b .loop_keys

	.up_arrow:
		mov x0, #1
		adr x1, msg_up
		mov x2, #26
		bl print_chars
		bl print_buffer_flush
		b .loop_keys

	.done:
		mov x8, #29 //numero da syscal para sys_ioctl
		mov x0, #0//fd stdin  
		mov x1, #0x5402 //tcset
		adr x2, OLD
		svc #0 

		bl print_buffer_flush



	mov x0, #0
	_exit


NEW:
	.zero 48
	
OLD:
	.zero 48

READ_BUFFER:
	.zero 4

msg_j:     
	.ascii "you pressed j\r\n"
msg_space: 
	.ascii "you pressed space\r\n"
msg_up:
	.ascii "you pressed the up arrow\r\n"
END:


PRINT_BUFFER:
