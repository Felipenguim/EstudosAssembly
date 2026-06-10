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

.EQU BUFFER_SIZE_GETDENTS, 4096

.INCLUDE "SYS/LINUX/SYSCALLS.S"
.INCLUDE "SYS/exit.s"
.INCLUDE "SYS/OPEN.S"
.INCLUDE "SYS/getdents64.s"
.INCLUDE "IO/read_chars.s"
.INCLUDE "IO/print_chars.s"
.INCLUDE "IO/print_buffer_flush.s"

.INCLUDE "IO/print_int_b.s"
.INCLUDE "IO/print_int_o.s"
.INCLUDE "IO/print_int_h.s"
.INCLUDE "IO/print_int_d.s"
.INCLUDE "IO/print_memory.s"


//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INSTRUCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:
	
	//abrir a pasta /proc com todos os  
	mov x0, #-100
	adr x1, proc_dir
	mov x2, #0x0 // O_RDONLY (0) 
	mov x3, #0
	_open
	//fd in x0
	mov x9, x0//guardar o fd de proc 

	cmp x0, #0
	b.le .error

	mov x0, x9 
	adr x1, get_dir_info_buffer
	mov x2, BUFFER_SIZE_GETDENTS
	_getdents64
	cmp x0, #0
	b.le .error


	mov x4, x0 //guardando valor máximo de bytes, será usado no loop 

	//fazer um loop que ve certinho o tipo, tem que ser tipo 4, dir, se for, pega o nome, olha se é string de numeros
	//se sim olha dentro para ver se é o tetris
	//se não for 4 pula, sempre pulando com o numero que pega no d_reclen, guardar ele sempre

.loop_buffer_proc:
	//x1 está no endereço inicial do buffer 
	mov x5, x1 //guarda o endereço antes de mudar 
	add x1, x1, #16 //pega o d_reclen
	ldrh w2, [x1] //guarda o d_reclen

	add x1, x1, #2 //type do dir/arquivo
	ldrb w3, [x1]
	cmp x3, #0x4 //dir type
	b.ne .end_interaction //se não for diretório

	sub x6, x2, #19 //total de bytes com o nome (len do nome)
	add x1, x1, #1 //x1 endereço do nome agora

	//fazer jeito de ver se o nome é composto por uma string de numeros 
	


	//se for uma string de números aí sim vamos para a parte de olhar o nome do arquivo 


	//ao terminar essa primeira intereção de achar o pid do tetris gerar uma função separada que vai ser o find_pid


.end_interaction:
	sub x4, x4, x2
	cmp x4, #0
	b.le .no_process_tetris

	add x5, x5, x2
	mov x1, x5 //novo endereço 
	b .loop_buffer_proc

	

	
.done_cheat:
	mov x0, #0
	_exit

.no_process_tetris:
	mov x0, #-67 //código inventado para denotar que não há o tetris
	_exit

.error:
	_exit  // processo saíra com x0 negativo

proc_dir:
	.asciz "/proc"

get_dir_info_buffer:
	.zero BUFFER_SIZE_GETDENTS //4kb



END:


PRINT_BUFFER:


READ_BUFFER:



//  0x8382: 0x1 0x0 0x0 0x0 0x0 0x0 0x0 0x0                                                                                                                
//   0x838a: 0x1 0x0 0x0 0x0 0x0 0x0 0x0 0x0                                                                                                                
//   0x8392: 0x18 0x0 0x4 0x2e 0x0 0x0 0x0 0x0                                                                                                              
//   0x839a: 0x1 0x0 0x0 0x0 0x0 0x0 0x0 0x0                                                                                                                
//   0x83a2: 0x2 0x0 0x0 0x0 0x0 0x0 0x0 0x0                                                                                                                
//   0x83aa: 0x18 0x0 0x4 0x2e 0x2e 0x0 0x0 0x0                                                                                                             
//   0x83b2: 0x9e 0x0 0x0 0xf0 0x0 0x0 0x0 0x0                                                                                                              
//   0x83ba: 0x3 0x0 0x0 0x0 0x0 0x0 0x0 0x0                                                                                                                
//   0x83c2: 0x18 0x0 0x8 0x66 0x62 0x0 0x0 0x0                                                                                                             
//   0x83ca: 0x7 0x0 0x0 0xf0 0x0 0x0 0x0 0x0                                                                                                               
//   0x83d2: 0x4 0x0 0x0 0x0 0x0 0x0 0x0 0x0                                                                                                                
//   0x83da: 0x18 0x0 0x4 0x66 0x73 0x0 0x0 0x0 


//debug
//  mov x1, x2
// 	mov x0, #1
// 	bl print_int_d
// 	bl print_buffer_flush
// 	b .done_cheat

//debug string
//  mov x2, #len
// 	mov x0, #1
// 	bl print_chars
// 	bl print_buffer_flush
// 	b .done_cheat

//debug memory:
// mov x0, #1
// adr x1, get_dir_info_buffer
// adr x2, print_int_h
// mov x3, 280
// bl print_memory

// bl print_buffer_flush
