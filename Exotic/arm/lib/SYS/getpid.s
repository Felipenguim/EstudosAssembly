.IFNDEF GET_PID
.EQU GET_PID,1

.INCLUDE "IO/read_chars.s"
.INCLUDE "SYS/OPEN.S"

// char* get_pid(int {x0} byte* {x1} char*{x2})
// Searches /proc for a process whose /proc/<pid>/comm matches the name
// pointed to by {x0}, and returns the PID as a string.
//
// @param x0 - max num of bytes in proc dir (you can get it with a getsdent syscall) 
// @param x1 — pointer to a buffer with proc dir information(e.g. "tetris")
// @param x2 — pointer to a null-terminated string with the target process name (e.g. "tetris")
// @return x0 — pointer to a buffer containing the PID as a string (not null-terminated, raw bytes read from /proc/<pid>/comm)
get_pid:
    stp x29, x30, [sp, #-16]!
    //salvar os registradores usados pela função
    stp x2, x3, [sp, #-16]!
    stp x4, x5, [sp, #-16]!
    stp x6, x7, [sp, #-16]!
    stp x8, x9, [sp, #-16]!
    stp x10, x11, [sp, #-16]!
    stp x12, x13, [sp, #-16]!
    stp x14, x15, [sp, #-16]!
    mov x29, sp


    mov x4, x0 //guardando valor máximo de bytes, será usado no loop 
    mov x15, x2
.loop_buffer_proc:
    mov x5, x1 //guarda o endereço antes de mudar 
	add x1, x1, #16 //pega o d_reclen
	ldrh w2, [x1] //guarda o d_reclen

	add x1, x1, #2 //type do dir/arquivo
	ldrb w3, [x1]
	cmp x3, #0x4 //dir type
	mov x14, x2
	b.ne .end_interaction //se não for diretório

	sub x6, x14, #19 //total de bytes com o nome (len do nome)
	add x1, x1, #1 //x1 endereço do nome agora

    //fazer jeito de ver se o nome é composto por uma string de numeros (vai economizar um tempo mas é opcional)
	// 	se byte < 0x30 → não é dígito → não é PID
	// se byte > 0x39 → não é dígito → não é PID
	//vou ver só a primeira letra para facilitar
	ldrb w8, [x1]
	cmp x8, #0x30
	b.lt .end_interaction
	cmp x8, #0x39
	b.gt .end_interaction

	//se for uma string de números aí sim vamos para a parte de olhar o nome do arquivo 
	adr x8, pid_name_path //x8 vai ter o buffer de dir do nome 
	adr x9, proc_dir_with_slash
	mov x10, #0 //len /proc/
	.loop_proc_str:
		ldrb w11, [x9], #1   // lê byte de x9, depois x9 += 1
		strb w11, [x8], #1   // escreve byte em x8, depois x8 += 1
		add x10, x10, #1
		cmp x10, #6
		b.ne .loop_proc_str
	
	adr x8, pid_name_path+6 
	mov x9, x1 //endereço do nome
	//salvar o pid em x12 (vem como string)
	adr x12, pid_number
	mov x10, #0
	.loop_name_pid_str:
		ldrb w11, [x9], #1   // lê byte de x9, depois x9 += 1
		cmp x11, #0 //ve se ta escrevendo um monte de padding ou não 
		b.eq .end_loop_name_pid_str
			strb w11, [x8], #1   // escreve byte em x8, depois x8 += 1
			strb w11, [x12], #1
			add x10, x10, #1
			cmp x10, x6
			b.ne .loop_name_pid_str
		.end_loop_name_pid_str:

	adr x8, pid_name_path+6 
	add x8, x8, x10
	adr x9, comm_dir
	mov x10, #0
	.loop_coom_str:
		ldrb w11, [x9], #1
		strb w11, [x8], #1
		add x10, x10, #1
		cmp x10, #5
		b.ne .loop_coom_str

	//pid_name_path com o path que quero 

	mov x0, #-100
	adr x1, pid_name_path
	mov x2, #0x0 // O_RDONLY (0) 
	mov x3, #0
	_open
	//fd in x0
	adr x1, name_pid
	mov x2, #16
	_read

	
	//comparar se é o nome que eu quero ou não
	//x1 tem o nome atual do pid
	//x0 tem o len do nome com null terminator 
    mov x13, x1 //endereço do nome
    mov x6, x15
	.loop_compare_names:
		ldrb w7, [x13], #1
		ldrb w8, [x6], #1
		cmp x7, x8
		b.ne .not_the_correct_pid
		sub x0, x0, #1
		cmp x0, #0
		b.eq .correct_pid_finded
        b .loop_compare_names


	.correct_pid_finded:
			adr x1, pid_number
            b .pid_finded
			


	//se não é o nome que eu quero, tem que limpar o buffer pid_name_path e ir para outro interação
	.not_the_correct_pid:
		//zerar o buffer para a próxima iteração 
		adr x1, pid_name_path
		stp xzr, xzr, [x1]
		stp xzr, xzr, [x1, #16]

//ao terminar essa primeira intereção de achar o pid do tetris gerar uma função separada que vai ser o find_pid
//a pessoa deve mandar o nome com o pid e aí as coisas vão se resolver lá e o pid será retornado, ver se numero ou string


.end_interaction:
	sub x4, x4, x14
	cmp x4, #0
	b.le .no_process_tetris

	add x5, x5, x14
	mov x1, x5 //novo endereço 
	b .loop_buffer_proc

.no_process_tetris:
	mov x0, #-67 //código inventado para denotar que não há o tetris
	_exit

.pid_finded:
    mov x0, x1 //endereço final para x0 


    //end
    mov sp, x29
    ldp x14, x15, [sp], #16
    ldp x12, x13, [sp], #16
    ldp x10, x11, [sp], #16
    ldp x8, x9, [sp], #16
    ldp x6, x7, [sp], #16 
    ldp x4, x5, [sp], #16
    ldp x2, x3, [sp], #16 
    ldp x29, x30, [sp], #16
    ret

proc_dir:
	.asciz "/proc"

proc_dir_with_slash:
	.asciz "/proc/"

comm_dir:
	.asciz "/comm"

pid_name_path:
    .zero 32

name_pid:
	.zero 16

pid_number:
	.zero 8

.balign 4
.ENDIF
