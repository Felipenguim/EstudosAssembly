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
.INCLUDE "SYS/close.s"

.INCLUDE "IO/print_chars.s"
.INCLUDE "IO/print_int_d.s"
.INCLUDE "IO/print_buffer_flush.s"

.INCLUDE "net/tcp_connect.s"
.INCLUDE "net/tcp_send_all.s"
.INCLUDE "net/tcp_recv_all.s"
.INCLUDE "net/http_post_build.s"
.INCLUDE "net/http_status_code.s"

//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INSTRUCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.equ SERVER_PORT, 8000
.equ SERVER_IP, 0x7F000001 // 127.0.0.1
.equ RESP_BUFFER_SIZE, 1024

START:

	//abrindo a conexão TCP com o servidor
	mov x0, #SERVER_PORT
	movz w1, #(SERVER_IP & 0xFFFF)
	movk w1, #(SERVER_IP >> 16), lsl #16
	bl tcp_connect //retorna x0 com o fd do socket, x0<0 se erro
	cmp x0, #0
	b.lt .connect_err
	mov x19, x0 //guardando o fd

	//montando a request HTTP no buffer
	adr x0, req_buffer
	movz w1, #(SERVER_IP & 0xFFFF)
	movk w1, #(SERVER_IP >> 16), lsl #16
	mov x2, #SERVER_PORT
	adr x3, path
	adr x4, body
	mov x5, #BODY_LEN
	bl http_post_build //retorna x0 com o tamanho da request
	mov x20, x0

	//enviando a request
	mov x0, x19 //fd 
	adr x1, req_buffer //que foi montado
	mov x2, x20 //len req buffer
	bl tcp_send_all
	cmp x0, #0
	b.lt .send_err

	//recebendo a resposta até o servidor fechar a conexão
	mov x0, x19
	adr x1, resp_buffer
	mov x2, #RESP_BUFFER_SIZE
	bl tcp_recv_all
	cmp x0, #0
	b.lt .recv_err
	mov x21, x0 //tamanho da resposta

	mov x0, x19
	_close

	//mostrando a resposta crua
	mov x0, #1
	adr x1, resp_buffer
	mov x2, x21
	bl print_chars

	//extraindo o status code e decidindo o que fazer
	adr x0, resp_buffer
	bl http_status_code
	mov x22, x0

	mov x0, #1
	adr x1, status_string
	mov x2, #STATUS_STRING_LEN
	bl print_chars
	mov x1, x22
	bl print_int_d
	mov x0, #1
	adr x1, newline
	mov x2, #1
	bl print_chars

	cmp x22, #200
	b.ne .status_not_ok

	mov x0, #1
	adr x1, ok_string
	mov x2, #OK_STRING_LEN
	bl print_chars
	b .end

.status_not_ok:
	mov x0, #1
	adr x1, not_ok_string
	mov x2, #NOT_OK_STRING_LEN
	bl print_chars

.end:
	bl print_buffer_flush
	mov x0, #0 // exit code 0
	_exit

.connect_err:
	mov x0, #1
	adr x1, err_connect_string
	mov x2, #ERR_CONNECT_STRING_LEN
	bl print_chars
	b .err_exit

.send_err:
	mov x0, #1
	adr x1, err_send_string
	mov x2, #ERR_SEND_STRING_LEN
	bl print_chars
	b .err_exit

.recv_err:
	mov x0, #1
	adr x1, err_recv_string
	mov x2, #ERR_RECV_STRING_LEN
	bl print_chars

.err_exit:
	bl print_buffer_flush
	mov x0, #1 // exit code 1
	_exit



path:
	.asciz "/"

body:
	.ascii "pang"
.equ BODY_LEN, . - body

status_string:
	.ascii "Status code: "
.equ STATUS_STRING_LEN, . - status_string

ok_string:
	.ascii "Servidor respondeu OK (200)\n"
.equ OK_STRING_LEN, . - ok_string

not_ok_string:
	.ascii "Servidor recusou a requisicao\n"
.equ NOT_OK_STRING_LEN, . - not_ok_string

newline:
	.ascii "\n"

err_connect_string:
	.ascii "Error in connect\n"
.equ ERR_CONNECT_STRING_LEN, . - err_connect_string

err_send_string:
	.ascii "Error in send\n"
.equ ERR_SEND_STRING_LEN, . - err_send_string

err_recv_string:
	.ascii "Error in recv\n"
.equ ERR_RECV_STRING_LEN, . - err_recv_string

.balign 8
req_buffer:
	.zero 512
resp_buffer:
	.zero RESP_BUFFER_SIZE

END:


PRINT_BUFFER:
