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


.INCLUDE "SYS/exit.s"
.INCLUDE "SYS/socket.s"
.INCLUDE "SYS/connect.s"
.INCLUDE "SYS/close.s"
.INCLUDE "SYS/WRITE.s"
.INCLUDE "SYS/sleep.s"
.INCLUDE "SYS/READ.s"

.INCLUDE "IO/print_chars.s"
.INCLUDE "IO/print_float.s"
.INCLUDE "IO/print_memory.s"
.INCLUDE "IO/print_buffer_flush.s"
.INCLUDE "IO/print_int_arrays.s"
.INCLUDE "IO/print_int_h.s"

//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INSTRUCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START:

	//criando um socket 
	//argumentos para TCP/IPv4 de saída
	mov x0, #2 //AF_INET
	//AF_INET significa Address Family: Internet (mais especificamente, IPv4)
	mov x1, #1 //SOCK_STREAM
	//fluxo contínuo e confiável de bytes, orientado a conexão, com garantia de entrega e de ordem.
	mov x2, #0 //protocol escolhido pelo kernel 
	_socket //retorna x0 com um fd se der certo x0<0 se erro
	cmp x0, #0
	b.lt .socket_err

	mov x19, x0 //guardando o fd

	//montando a struct sockaddr_in
	mov x2, #2 //AF_INET
	mov x3, #8000//port
	rev16 w3, w3 ////struct pede big endian
	MOVZ w4, #0x0001          // Limpa o registrador e coloca 0x0001 nos 16 bits mais baixos
	MOVK w4, #0x7F00, LSL #16//ip
	rev w4, w4 //struct pede big endian

	adr x1, sockaddr_in
	strh w2, [x1]
	strh w3, [x1, #2]
	str w4, [x1, #4]
	//não precisa fazer o store dos últimos 8 bytes, eles já vem zero

	//x0 já com o fd da syscall socket
	//x1 já com o adr de sockaddr_in
	mov x2, #16 //len de sockaddr_in
	_connect //x0 == 0 se correto
	cmp x0, #0
	b.lt .connect_err
	
	mov x0, x19
	adr x1, http_string
	mov x2, HTTP_LEN
	_write


	// adr x0, sleep_time
	// mov x1, #0
	// _sleep
	//FAZER UM LOOP ATÉ READ RETORNAR 0 EM x0 
	mov x0, x19
	adr x1, resp_header_buffer
	mov x2, #512
	_read

	mov x0, #1
	adr x1, resp_header_buffer
	mov x2, #512
	bl print_chars

	mov x0, x19
	adr x1, resp_buffer
	mov x2, #512
	_read

	mov x0, #1
	adr x1, resp_buffer
	mov x2, #512
	bl print_chars

	mov x0, x19
	_close
	
	// mov x0, #1
	// adr x1, sockaddr_in
	// adr x2, print_int_h
	// mov x3, 2*8 //16 bytes
	// bl print_memory
	// mov x1, x0
	// mov x0, #1
	// bl print_int_d

	bl print_buffer_flush
	mov x0, #0 // exit code 0
	_exit

.socket_err:
	//fazer prints diferenciados depois 
	_exit
.connect_err:
	mov x0, #1 
	adr x1, err_connect_string 
	mov x2, #18
	bl print_chars

	bl print_buffer_flush
	_exit

sockaddr_in:
	.zero 16

// array:
// 	.rept LEN_ARR
// 	.quad 0
// 	.endr

sleep_time:
	.quad 3 // tv_sec
	.quad 0// tv_nsec 

resp_header_buffer:
	.zero 512
resp_buffer:
	.zero 512

err_connect_string:
	.asciz "Error in connect \n"

http_string:
	.ascii "POST / HTTP/1.1\r\n"
	.ascii "Host: 127.0.0.1:8000\r\n"
	.ascii "Content-Type: text/plain\r\n"
	.ascii "Content-Length: 4\r\n"
	.ascii "\r\n"
body:
	.ascii "pang"

END_http_string:

.equ HTTP_LEN, END - http_string

END:


PRINT_BUFFER:


//STRUCT sockaddr_in
// struct sockaddr_in {
//     sa_family_t    sin_family;   // 2 bytes //no caso AF_INET
//     in_port_t      sin_port;     // 2 bytes //porta de destino (BIG ENDIAN)
//     struct in_addr sin_addr;     // 4 bytes //ip de destino 
//     unsigned char  sin_zero[8];  // 8 bytes
// };

// struct in_addr {
//     uint32_t s_addr;             // 4 bytes — o IP em si
// };
