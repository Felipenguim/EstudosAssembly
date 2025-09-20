;pede 2 inputs, soma e printa
;64 bits

extern print
extern input
extern string_to_int
extern int_to_string
extern print_num


section .data
v1 db "escolha um inteiro a: ", 10, 0
v2 db "escolha um inteiro b: ", 10, 0
v3 db "a+b = ", 0
v4 db " ", 10

section .bss
;no x64 vc reserva os bits pela pilha, em vez de resd para 4 bytes, você faz um sub rsp, 4
a resq 1
b resq 1
soma resd 1


section .text
    global main

main:
    mov rbp, rsp; for correct debugging
    
    mov rdi, v1
    call print
    call input
    call string_to_int ;ele pega a string em rsi e retorna o valor em rax
    mov [a], rax ; pega o input e passa para a

    mov rdi, v2
    call print
    call input 
    call string_to_int
    mov [b], rax ; pega o input e passa para b

    
    mov rax, 0 
    mov rax, [a]    
    add rax, [b]    ; soma
    
    call int_to_string

   
    mov rdx, [rsi]
    mov [soma], rdx
    mov rdi, v3
    call print

    
    mov rdi, soma
    call print_num

    mov rdi, v4
    call print
    
    mov rdi, rax
    mov rax, 60
    mov rdi, 0
    syscall
    
    ;Boaaa
    
    
    

    



