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
.EQU SYMBOL_BYTES, 4

.INCLUDE "SYS/LINUX/SYSCALLS.S"
.INCLUDE "SYS/exit.s"
.INCLUDE "SYS/OPEN.S"
.INCLUDE "SYS/WRITE.S"
.INCLUDE "SYS/sleep.s"
.INCLUDE "SYS/getdents64.s"
.INCLUDE "SYS/lseek.s"
.INCLUDE "IO/read_chars.s"
.INCLUDE "IO/print_chars.s"
.INCLUDE "IO/print_string.s"
.INCLUDE "IO/parse_int.s"
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
	mov x21, x0 //salvando endereço do pid 


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
	mov x9, x0//guardar o fd de proc/pid/maps

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
		adr x13, base_address_string+2
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
			// adr x1, base_address_string
			// mov x2, x12
			// bl print_chars
			// bl print_buffer_flush
			// b .done_cheat

		//fazer a função get base address com as coisas acima 



		//Econtrando o offset da variável que eu quero 


		// abrindo o proc/{pid}/exe
		adr x8, exe_name_path
		adr x9, proc_directory_with_slash
		mov x10, #0
		.loop_str_proc_for_exe:
			ldrb w11, [x9], #1   // lê byte de x9, depois x9 += 1
			strb w11, [x8], #1   // escreve byte em x8, depois x8 += 1
			add x10, x10, #1
			cmp x10, #6
			b.ne .loop_str_proc_for_exe

		adr x8, exe_name_path+6
		mov x9, x21 //endereço da string do pid
		mov x10, #0
		.loop_pid_str_for_exe:
			ldrb w11, [x9], #1   // lê byte de x9, depois x9 += 1
			cmp x11, #0 //ve se ta escrevendo um monte de padding ou não 
			b.eq .end_loop_pid_str_for_exe
				strb w11, [x8], #1   // escreve byte em x8, depois x8 += 1
				add x10, x10, #1
				b .loop_pid_str_for_exe
			.end_loop_pid_str_for_exe:
		
		adr x8, exe_name_path+6 
		add x8, x8, x10
		adr x9, exe_file
		mov x10, #0
		.loop_exe_file:
			ldrb w11, [x9], #1
			strb w11, [x8], #1
			add x10, x10, #1
			cmp x10, #4 //
			b.ne .loop_exe_file

	//read no proc/{pid}/exe 
	mov x0, #-100
	adr x1, exe_name_path
	mov x2, #0x0 // O_RDONLY (0) 
	mov x3, #0
	_open

	mov x15, x0 //fd in x15

	cmp x0, #0
	b.le .error

	
	//guardar um monte de bytes em um buffer
	//fd in x0
	adr x1, exe_file_content
	mov x2, #4096
	_read //len de bytes lidos em x0
	cmp x0, #0
	b.le .error

	
	ldr x3, [x1, 0x28] //pegando o e_shoff 
	//x3 tem o offset até o section header table
	ldrh w4, [x1, 0x3A] //e_shentsize (tamnho de cada seção)
	ldrh w5, [x1, 0x3C] //e_shnum (numero de seções)

	//fazer o lseek depois um novo read 
	mov x0, x15
	mov x1, x3
	mov x2, #0
	_lseek
	//offset in x0
	cmp x0, #0
	b.le .error
	// mov x1, x0
	// mov x0, #1
	// bl print_int_d
	// bl print_buffer_flush
	// b .done_cheat


	mov x0, x15
	adr x1, exe_file_content
	mov x2, #4096
	_read
	cmp x0, #0
	b.le .error

// 	Próximo passo: — Iterar as entradas procurando sh_type == 2 (SHT_SYMTAB)
	// Quando achar, guardar três campos dessa entrada:

	// sh_offset (offset 0x18) — onde a .symtab começa no arquivo
	// sh_size (offset 0x20) — tamanho total da .symtab em bytes
	// sh_link (offset 0x28) — índice da seção .strtab associada 
	
	mov x12, x5 //numero de seções
	//x4 tem o tamanho de cada seção
	//x1 tem o endereço do conteúdo 
	mov x13, x1
	.loop_sh_type:
		ldr w10, [x13, 0x04]
		cmp w10, #2
		b.eq .find_right_section_header
		sub x12, x12, #1
		cmp x12, #0
		b.eq .error
		add x13, x13, x4 //vai para a próxima seção 
		b .loop_sh_type

	.find_right_section_header:
		//x1 com o endereço original, x13 com o endereço da seção 
		ldr x3, [x13, 0x18] //sh_offset pegando onde.symtab começa no arquivo (8 bytes)
		ldr x6, [x13, 0x20] //sh_size -> tamanho da .symtab (8 bytes)
		ldr w5, [x13, 0x28] //sh_link da seção .strtab associada  (4 bytes)

	//acessando sh_link 
	mul x5, x5, x4 //multiplicando pelo tamanho da seção 
	add x16, x1, x5 //section header de strtab
	ldr x7, [x16, 0x18] //sh_offset pegando onde .strtab começa no arquivo
	ldr x8, [x16, 0x20] //sh_size -> tamanho da .strtab

	//lendo e guardando os dados de .strtab
	mov x0, x15
	mov x1, x7
	mov x2, #0
	_lseek
	//offset in x0
	cmp x0, #0
	b.le .error

	mov x0, x15
	adr x1, strtab_content
	mov x2, #2048
	_read
	cmp x0, #0
	b.le .error



	//novo lseek + read para pegar o offset para a .symtab
	mov x0, x15
	mov x1, x3
	mov x2, #0
	_lseek
	//offset in x0
	cmp x0, #0
	b.le .error

	mov x0, x15
	adr x1, symtab_content
	mov x2, #4096
	_read
	cmp x0, #0
	b.le .error
	

	//ler cada Elf64_sym até achar o next (x6 tem o tamanho total)
	adr x24, symtab_content
	mov x11, #0
	.loop_st_name_elf64_sym:
		ldr w9, [x24, x11]
		//w9 com o indice em strtab que tem o nome
		adr x22, strtab_content
		add x22, x22, x9 //endereço da string 
		mov x23, x22

		//comparar com o next
		adr x1, sym_I_want_to_modify
		.loop_try_name_sym:
			ldrb w7, [x23], #1
			ldrb w8, [x1], #1
			cmp x8, #0
			b.eq .compare_name_with_0
			cmp x7, x8
			b.eq .loop_try_name_sym
			b .not_the_same_sym

			.compare_name_with_0:
				cmp x7, #0
				b.eq .sym_I_want_to_modify_finded

		.not_the_same_sym:
			add x24, x24, #24 
			sub x6, x6, #24
			cmp x6, #0
			b.le .error
			b .loop_st_name_elf64_sym


	
	.sym_I_want_to_modify_finded:
	//x22 com o endereço da string do nome 
	//x24 com o endereço na symtab do simbolo 


	ldr x7, [x24, 0x08] //pegando st_value (ele é o endereço relativo da variavel a partir do base address)

	adr x0, base_address_string
	bl parse_int
	//base address em inteiro no x0
	add x0, x0, x7 //base address + st_value
	mov x25, x0 



	//criar funções wrapper pros processos acima


	
	//proximos passos
	// 1. abrir /proc/<pid>/mem 
	// 2. lseek(fd, endereço_final, SEEK_SET)  ← o endereço em x0
	// 3. read(fd, buffer, 4)  ← lê 4 bytes (sizeof int)
	// 4. o buffer agora contém o valor atual de `next`
	//abrindo /proc/{pid}/maps
	adr x8, mem_name_path
	adr x9, proc_directory_with_slash
	mov x10, #0
	.loop_str_proc_for_mem:
		ldrb w11, [x9], #1   // lê byte de x9, depois x9 += 1
		strb w11, [x8], #1   // escreve byte em x8, depois x8 += 1
		add x10, x10, #1
		cmp x10, #6
		b.ne .loop_str_proc_for_mem

	adr x8, mem_name_path+6
	mov x9, x21 //endereço da string do pid
	mov x10, #0
	.loop_pid_str_for_mem:
		ldrb w11, [x9], #1   // lê byte de x9, depois x9 += 1
		cmp x11, #0 //ve se ta escrevendo um monte de padding ou não 
		b.eq .end_loop_pid_str_for_mem
			strb w11, [x8], #1   // escreve byte em x8, depois x8 += 1
			add x10, x10, #1
			b .loop_pid_str_for_mem
		.end_loop_pid_str_for_mem:
	
	adr x8, mem_name_path+6 
	add x8, x8, x10
	adr x9, mem_file
	mov x10, #0
	.loop_mem_file:
		ldrb w11, [x9], #1
		strb w11, [x8], #1
		add x10, x10, #1
		cmp x10, #4
		b.ne .loop_mem_file


	mov x0, #-100
	adr x1, mem_name_path
	mov x2, #0x2 // O_RDWR  
	mov x3, #0
	_open
	mov x9, x0//guardar o fd de proc 

	
	.loop_new_value:
		mov x0, x9 //fd
		mov x1, x25 //offset
		mov x2, #0
		_lseek
		//offset in x0
		cmp x0, #0
		b.le .error

		//escrita
		mov x0, x9 //fd
		adr x1, new_value
		mov x2, SYMBOL_BYTES
		_write

		mov x0, x9 //fd
		mov x1, x25 //offset
		mov x2, #0
		_lseek


		mov x0, x9 //fd
		adr x1, value_symbol
		mov x2, SYMBOL_BYTES
		_read

		mov x0, #1
		ldr w1, [x1] //carregando o que está em value_symbol 
		bl print_int_d
		bl print_buffer_flush

		adr x0, sleep_time
		mov x1, #0
		_sleep
	
		b .loop_new_value
		
	// mov x0, #1
	// ldr w1, [x1] //carregando o que está em value_symbol 
	// bl print_int_d
	// bl print_buffer_flush
	// b .done_cheat

	
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

mem_name_path:
	.zero 32

mem_file:
	.ascii "/mem"

new_value:
	.word 0 //zero é a linha reta,

space:
	.asciz " "

maps_file_content:
	.zero 4096

exe_file:
	.ascii "/exe"

exe_name_path:
	.zero 32

exe_file_content:
	.zero 4096

symtab_content:
	.zero 4096

strtab_content:
	.zero 2048

possible_wanted_name:
	.zero 32


base_address_string:
    .ascii "0x"
    .zero 16

sym_I_want_to_modify:
	.asciz "next"

value_symbol:
	.zero SYMBOL_BYTES

sleep_time:
	.quad 2 // tv_sec
	.quad 0// tv_nsec 
 


END:


PRINT_BUFFER:


READ_BUFFER:


//elfheader
// typedef struct {
//     unsigned char e_ident[16];  // offset 0x00 — magic number + metadados
//     Elf64_Half    e_type;       // offset 0x10 (2 bytes)
//     Elf64_Half    e_machine;    // offset 0x12 (2 bytes)
//     Elf64_Word    e_version;    // offset 0x14 (4 bytes)
//     Elf64_Addr    e_entry;      // offset 0x18 (8 bytes)
//     Elf64_Off     e_phoff;      // offset 0x20 (8 bytes)
//     Elf64_Off     e_shoff;      // offset 0x28 (8 bytes)  ← preciso
//     Elf64_Word    e_flags;      // offset 0x30 (4 bytes)
//     Elf64_Half    e_ehsize;     // offset 0x34 (2 bytes)
//     Elf64_Half    e_phentsize;  // offset 0x36 (2 bytes)
//     Elf64_Half    e_phnum;      // offset 0x38 (2 bytes)
//     Elf64_Half    e_shentsize;  // offset 0x3A (2 bytes)  ← preciso
//     Elf64_Half    e_shnum;      // offset 0x3C (2 bytes)  ← preciso
//     Elf64_Half    e_shstrndx;   // offset 0x3E (2 bytes)
// } Elf64_Ehdr;                   // total: 0x40 = 64 bytes
// 0x7f 0x45 0x4c 0x46 0x2 0x1 0x1 0x0
// 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0
// 0x3 0x0 0x3e 0x0 0x1 0x0 0x0 0x0
// 0xa0 0x14 0x0 0x0 0x0 0x0 0x0 0x0
// 0x40 0x0 0x0 0x0 0x0 0x0 0x0 0x0
// 0xe0 0x53 0x1 0x0 0x0 0x0 0x0 0x0
// 0x0 0x0 0x0 0x0 0x40 0x0 0x38 0x0
// 0xd 0x0 0x40 0x0 0x26 0x0 0x25 0x0
// offset  bytes                          campo
// 0x00    7f 45 4c 46                    e_ident[0..4)   = magic "\x7fELF"
// 0x04    02                             e_ident[4]      = EI_CLASS = 2 (64-bit)
// 0x05    01                             e_ident[5]      = EI_DATA = 1 (little-endian)
// 0x06    01                             e_ident[6]      = EI_VERSION = 1
// 0x07    00                             e_ident[7]      = EI_OSABI = 0
// 0x08-0x0F  00 00 00 00 00 00 00 00     e_ident[8..16)  = padding
// 0x10    03 00                          e_type    = 0x0003 = ET_DYN  ← PIE 
// 0x12    3e 00                          e_machine = 0x003e = 62 (EM_X86_64)
// 0x14    01 00 00 00                    e_version = 1
// 0x18    a0 14 00 00 00 00 00 00        e_entry   = 0x14a0
// 0x20    40 00 00 00 00 00 00 00        e_phoff   = 0x40
// 0x28    e0 53 01 00 00 00 00 00        e_shoff   = 0x153e0
// 0x30    00 00 00 00                    e_flags   = 0
// 0x34    40 00                          e_ehsize  = 0x40 = 64
// 0x36    38 00                          e_phentsize = 0x38 = 56
// 0x38    0d 00                          e_phnum   = 13
// 0x3a    40 00                          e_shentsize = 0x40 = 64
// 0x3c    26 00                          e_shnum   = 38
// 0x3e    25 00                          e_shstrndx  = 37

//e_shoff → endereço (offset no arquivo) onde a Section Header Table começa
//e_shentsize → tamanho em bytes de cada entrada da Section Header Table 
//e_shnum → quantas entradas (seções) existem na Section Header Table




//section header: (é o header com as informações da section (exemplo .text))

// typedef struct {
//     Elf64_Word  sh_name;       // offset 0x00 (4 bytes) — índice na .shstrtab
//     Elf64_Word  sh_type;       // offset 0x04 (4 bytes) — tipo da seção
//     Elf64_Xword sh_flags;      // offset 0x08 (8 bytes)
//     Elf64_Addr  sh_addr;       // offset 0x10 (8 bytes)
//     Elf64_Off   sh_offset;     // offset 0x18 (8 bytes)  ← offset da seção no arquivo
//     Elf64_Xword sh_size;       // offset 0x20 (8 bytes)  ← tamanho da seção em bytes
//     Elf64_Word  sh_link;       // offset 0x28 (4 bytes)  ← índice de outra seção relacionada
//     Elf64_Word  sh_info;       // offset 0x2C (4 bytes)
//     Elf64_Xword sh_addralign;  // offset 0x30 (8 bytes)
//     Elf64_Xword sh_entsize;    // offset 0x38 (8 bytes)  ← se entradas têm tamanho fixo, qual é
// } Elf64_Shdr;                  // total: 0x40 = 64 bytes
// 0x1b 0x0 0x0 0x0 0x1 0x0 0x0 0x0
// 0x2 0x0 0x0 0x0 0x0 0x0 0x0 0x0
// 0x18 0x3 0x0 0x0 0x0 0x0 0x0 0x0
// 0x18 0x3 0x0 0x0 0x0 0x0 0x0 0x0
// 0x1c 0x0 0x0 0x0 0x0 0x0 0x0 0x0
// 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0
// 0x1 0x0 0x0 0x0 0x0 0x0 0x0 0x0
// 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0


//.symtab item struct:
// typedef struct {
//     Elf64_Word  st_name;   // 0x00, 4 bytes — índice na .strtab onde começa o nome
//     uint8_t     st_info;   // 0x04, 1 byte  — tipo e binding do símbolo
//     uint8_t     st_other;  // 0x05, 1 byte  — visibilidade (geralmente 0)
//     Elf64_Half  st_shndx;  // 0x06, 2 bytes — índice da seção onde o símbolo vive
//     Elf64_Addr  st_value;  // 0x08, 8 bytes — offset/endereço
//     Elf64_Xword st_size;   // 0x10, 8 bytes — tamanho em bytes do símbolo
// } Elf64_Sym;               // total: 24 bytes (0x18)
// 0x9 0x0 0x0 0x0 0x1 0x0 0x4 0x0
// 0x8c 0x3 0x0 0x0 0x0 0x0 0x0 0x0
// 0x20 0x0 0x0 0x0 0x0 0x0 0x0 0x0


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
//	bl print_chars
// 	bl print_buffer_flush
// 	b .done_cheat

//debug memory:
// mov x0, #1
// adr x1, get_dir_info_buffer
// adr x2, print_int_h
// mov x3, 280
// bl print_memory

// bl print_buffer_flush
