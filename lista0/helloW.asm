;com printf e 32 bits
; extern _printf

; section .data
;     msg db 'Hello, world!', 10, 0


; section .text
;     global _main

; _main:
;     push ebp
;     mov ebp, esp
;     push msg ;passa o argumento
;     call _printf
;     mov esp, ebp
;     pop ebp
;     mov eax, 0
;     ret


; 64 bits, dá merda no printf 
; extern _printf

; section .data
;     msg db 'Hello, world!', 10, 0


; section .text
;     global _main

; _main:
;     push rbp
;     mov rbp, rsp
;     mov rdi, msg ;passa o argumento
;     push rdi ;passa o argumento
;     call _printf
;     mov rsp, rbp
;     pop rbp
;     mov rax, 0
;     ret




 ;64 bits sem prinft
section .data
    msg db 'Hello, world!', 10, 0


section .text
    global main

main:
    
    mov rdi, msg
    call print_str
    jmp exit_success

str_len:
    push rbp
    mov rbp, rsp

    mov rax, 0
    .str_len_loop:
        cmp [rdi], byte 0
        je .str_len_end
        inc rdi
        inc rax
        jmp .str_len_loop

    .str_len_end:
        mov rsp, rbp
        pop rbp
        ret

    
print_str:
    push rbp
    mov rbp, rsp
    
    push rdi
    call str_len
    pop rsi

    mov rdx, rax ; tamanho da string
    mov rax, 1 ; syscall write
    mov rdi, 1 ; stdout
    syscall


    mov rsp, rbp 
    pop rbp
    ret

exit_success:
    xor rdi, rdi ; mesma coisa que mov rdi, 0
    mov rax, 60 
    syscall