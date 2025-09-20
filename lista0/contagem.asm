;fazer uma contagem regressiva de 10 a 0 printando do 10 ao 0

extern print
extern input
extern string_to_int
extern int_to_string
extern print_num
extern int_to_string_rdi


section .data
    timespec:
        tv_sec  dd 1    ; segundos
        tv_nsec dd 0    ; nanosegundos
    contador dq 30
    
    v4 db " ", 10


section .bss
    atual resb 32


section .text
    global main

main:
    push rbp
    mov rbp, rsp 
    
print_loop:
    mov rax, [contador] ; passa o endereço               mov rax, [contagem]  passa o valor para rax
    lea rsi, [atual + 31]        ; Ajusta rsi para o final do buffer
    ;sub rsi, 31 é a mesma coisa que lea rsi, [atual + 20]
    mov byte [rsi], 0
    
    
    call int_to_string
    
    mov rdi, rsi 
    call print
    mov rdi, v4
    call print

    
    mov eax, 35         ; syscall: nanosleep (número 35 em x86-64)
    mov rdi, timespec   ; ponteiro para timespec (1 segundo)
    syscall
    
    dec qword [contador] 
    cmp qword [contador], 0             
    jne print_loop



    mov rsp, rbp
    pop rbp 


    mov rax, 60
    mov rdi, 0
    syscall







;print loop por rdi como o cara passou no stack overflow:
; main:
;     push rbp
;     mov rbp, rsp 
; print_loop:
;     mov rax, [contador]
;     mov rdi, atual +28
;     mov  dword [rdi], 00000A20h ; " ", 10, 0, 0
    
;     call int_to_string_rdi  ; -> RDI (RAX RBX RDX)
;      call print
;      mov eax, 35         ; syscall: nanosleep (número 35 em x86-64)
;     mov rdi, timespec   ; ponteiro para timespec (1 segundo)
;     syscall
    
;     dec qword [contador] 
;     cmp qword [contador], 0             
;     jne print_loop



;     mov rsp, rbp
;     pop rbp 


;     mov rax, 60
;     mov rdi, 0
;     syscall