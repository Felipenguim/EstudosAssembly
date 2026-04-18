//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.arch armv8-a
.equ LOAD_ADDRESS, 0x8000
.equ CODE_SIZE, (END-END_HEADER) // everything beyond the HEADER is code
.equ PRINT_BUFFER_SIZE, 4096 // 4KB buffer for printing (must be large enough to hold all output)
.equ READ_BUFFER_SIZE, 4096 // 4KB buffer for reading (must be large enough to hold all input)
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
	.quad CODE_SIZE + PRINT_BUFFER_SIZE + READ_BUFFER_SIZE// size (bytes) of segment in memory
	.quad 0x0000000000000000 // alignment (doesn't matter, only 1 segment)
END_HEADER:

//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INCLUDES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

//.EQU VERBOSE_LOGS, 1

.INCLUDE "SYS/LINUX/SYSCALLS.S"
.INCLUDE "SYS/exit.s"

.INCLUDE "IO/print_chars.s"
.INCLUDE "IO/print_string.s"
.INCLUDE "IO/read_chars.s"
.INCLUDE "SYS/OPEN.S" 
.INCLUDE "SYS/close.s"

 
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INSTRUCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:

	//SP aponta para o primeiro argumento (argc), SP+8 aponta para o segundo argumento (argv[0], o nome do programa), SP+16 aponta para o terceiro argumento (argv[1], o caminho do arquivo a ser modificado)
	//argc é o número de argumentos, 
	// Verificar se argc == 2 (programa + 1 argumento)
    ldr X1, [SP, 0]       // carrega argc
    cmp X1, 2
    B.ne .fail
    

	mov x0, #-100
	LDR x1, [SP, 16]
	mov x2, #00 //O_RDONLY
	mov x3, #0 //mode (not used for O_RDONLY)
	_open
	cmp x0, #0
	b.lt .fail       // fd negativo = erro
	mov x19, x0 // save fd for later
	
	//fd in x0
	adr x1, READ_BUFFER
	mov x2, #READ_BUFFER_SIZE
	_read

	mov x2, x0 // number of bytes read
	mov x0, #1 // file descriptor 1 is stdout
	adr x1, READ_BUFFER
	bl print_chars

	bl print_buffer_flush //flush any remaining output in the buffer

	mov x0, #1
	adr x1, POKEBALL
	mov x2, #POKEBALL_SIZE
	bl print_chars

	bl print_buffer_flush 

	mov x0, x19 // fd
	_close
	cmp x0, #0
	b.eq .leave       // fd negativo = erro

.fail:    // exit with code 1 to indicate failure
    mov x0, #1
    b .leave
.leave:
	_exit
	

// Constantes de cor (só para legibilidade, não geram código)
.equ ESC, 0x1B

POKEBALL:
    // Linha 1 — topo vermelho
    .ascii "          \033[31m▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\033[0m\n"
    // Linha 2
    .ascii "       \033[31m▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\033[0m\n"
    // Linha 3
    .ascii "     \033[31m▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\033[0m\n"
    // Linha 4
    .ascii "    \033[31m▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\033[0m\n"
    // Linha 5
    .ascii "   \033[31m▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\033[0m\n"
    // Linha 6
    .ascii "  \033[31m▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\033[0m\n"
    // Linha 7 — divisória vermelha sólida
    .ascii "  \033[31m█████████████████████████████████\033[0m\n"
    // Linha 8 — faixa superior do botão
    .ascii "  \033[37m▀▀▀▀▀▀▀▀▀▀▀▀▀▀\033[1;37m▄▄▄▄▄\033[37m▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀\033[0m\n"
    // Linha 9 — borda do botão (vazia)
    .ascii "  \033[37m█████████████\033[1;37m█\033[37m     \033[1;37m█\033[37m█████████████\033[0m\n"
    // Linha 10 — botão com ● no centro
    .ascii "  \033[37m█████████████\033[1;37m█\033[37m  \033[1;30m●\033[37m  \033[1;37m█\033[37m█████████████\033[0m\n"
    // Linha 11 — borda do botão (vazia, espelho da 9)
    .ascii "  \033[37m█████████████\033[1;37m█\033[37m     \033[1;37m█\033[37m█████████████\033[0m\n"
    // Linha 12 — faixa inferior do botão
    .ascii "  \033[37m▄▄▄▄▄▄▄▄▄▄▄▄▄▄\033[1;37m▀▀▀▀▀\033[37m▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄\033[0m\n"
    // Linha 13 — divisória branca sólida
    .ascii "  \033[37m█████████████████████████████████\033[0m\n"
    // Linha 14
    .ascii "   \033[37m▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀\033[0m\n"
    // Linha 15
    .ascii "    \033[37m▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀\033[0m\n"
    // Linha 16
    .ascii "     \033[37m▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀\033[0m\n"
    // Linha 17
    .ascii "       \033[37m▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀\033[0m\n"
    // Linha 18 — base
    .ascii "          \033[37m▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀\033[0m\n"
    .ascii "\n"
POKEBALL_END:

// Tamanho calculado em tempo de montagem — zero custo em runtime
.equ POKEBALL_SIZE, POKEBALL_END - POKEBALL


END:

PRINT_BUFFER:

READ_BUFFER: 
