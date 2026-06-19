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

.INCLUDE "SYS/getpid.s"


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


	//x1 já está no lugar
	//x0 já tem o numero de bytes
	adr x2, wanted_name
	bl get_pid
	//x0 com o endereço da string do pid 



	//PROXIMO PASSO DEPOIS DE ACHAR O PID
	//ABRIR O MAPS DELE, ACHAR achar o '-' → separa start do end da linha, guardar o start
	//achar os espaços até o path, ver se o último / do path tem o nome do processo
	//Se tudo se confirmar teremos a base salva 
	//se não tem, próxima linha, o loop volta quando acha \n

	//endereço da string com nome do pid em x0

	//abrindo /proc/{pid}/maps
	adr x8, map_name_path
	adr x9, proc_directory_with_slash
	mov x10, #0
	.loop_str_proc:
		ldrb w11, [x9], #1   // lê byte de x9, depois x9 += 1
		strb w11, [x8], #1   // escreve byte em x8, depois x8 += 1
		add x10, x10, #1
		cmp x10, #6
		b.ne .loop_str_proc

	adr x8, map_name_path+6
	mov x9, x0 //endereço da string do pid
	mov x10, #0
	.loop_pid_str:
		ldrb w11, [x9], #1   // lê byte de x9, depois x9 += 1
		cmp x11, #0 //ve se ta escrevendo um monte de padding ou não 
		b.eq .end_loop_pid_str
			strb w11, [x8], #1   // escreve byte em x8, depois x8 += 1
			add x10, x10, #1
			b .loop_pid_str
		.end_loop_pid_str:
	
	adr x8, map_name_path+6 
	add x8, x8, x10
	adr x9, maps_file
	mov x10, #0
	.loop_maps_file:
		ldrb w11, [x9], #1
		strb w11, [x8], #1
		add x10, x10, #1
		cmp x10, #5
		b.ne .loop_maps_file


	mov x0, #-100
	adr x1, map_name_path
	mov x2, #0x0 // O_RDONLY (0) 
	mov x3, #0
	_open
	mov x9, x0//guardar o fd de proc 

	cmp x0, #0
	b.le .error

	mov x0, x9
	//guardar um monte de bytes em um buffer
	//fd in x0
	adr x1, maps_file_content
	mov x2, #4096
	_read //len de bytes lidos em x0

	cmp x0, #0
	b.le .error


	//se chegou até aqui o processo existe
	//logo não vou fazer nada se passar a len dos bytes lidos
	//endereço já em x1
	mov x14, x1
	mov x10, x2
	.try_to_find_correct_base_address:
		adr x13, base_address_string
		mov x12, #0 //guardará n bytes do base address
		.loop_base_address:
			ldrb w11, [x14], #1
			cmp x11, #'-'
			b.eq .end_loop_base_address
			strb w11, [x13], #1
			add x12, x12, #1
			b .loop_base_address
			.end_loop_base_address:

		//nome da base address em base_address_string
		.loop_for_process:
			ldrb w11, [x14], #1 //x1 + x12 + 1
			cmp w11, #'\n'
			b.eq .end_line_maps
			cmp w11, #'/' //se é barra tem que comparar o nome
			b.eq .try_proccess_name
			b .loop_for_process

		.try_proccess_name:
			adr x4, wanted_name
			adr x6, possible_wanted_name
			mov x5, x14 //está no endereço do primeiro byte pós /
			.loop_after_slash:
				ldrb w11, [x5], #1 //x5 termina logo após o / que encerra o nome ou na linha seguinte se o final for \n
				cmp w11, #'/'
				b.eq .end_loop_after_slash
				cmp w11, #'\n'  //ultimo nome do path termina com \n
				b.eq .end_loop_after_slash
				strb w11, [x6], #1
				b .loop_after_slash


			.end_loop_after_slash: //compara se o nome foi achado
			adr x6, possible_wanted_name
				.loop_end_loop_after_slash:
					ldrb w7, [x4], #1
					cmp w7, #'\n' //chegou ao final e o nome está certo
					b.eq .finded_name_in_maps
					ldrb w8, [x6], #1
					cmp w7, w8 
					b.ne .not_the_correct_name_in_maps
					b .loop_end_loop_after_slash

					.not_the_correct_name_in_maps:
						mov x14, x5 
						sub x10, x14, x1
						cmp x10, #0
						b.le .error //
						cmp w11, #'\n'
						b.eq .end_line_maps
						b .try_proccess_name

		.end_line_maps: //achou a quebra de linha, começa de novo 
			b .try_to_find_correct_base_address
		
		.finded_name_in_maps:
		//nome base_address_string só seguir daqui
			mov x0, #1
			adr x1, base_address_string
			mov x2, x12
			bl print_chars
			bl print_buffer_flush
			b .done_cheat


	//fazer a função get base address

	
.done_cheat:
	mov x0, #0
	_exit

.error:
	_exit  // processo saíra com x0 negativo

.error_not_proccess_in_maps:
	mov x0, #99
	_exit 

wanted_name:
	.asciz "tetris\n"

get_dir_info_buffer:
	.zero BUFFER_SIZE_GETDENTS //4kb

proc_directory_with_slash:
	.ascii "/proc/"

maps_file:
	.ascii "/maps"

map_name_path:
	.zero 32

maps_file_content:
	.zero 4096


possible_wanted_name:
	.zero 64


base_address_string:
	.zero 16



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
// adr x1
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
