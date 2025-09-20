; um simples código de tabuada, o usuário vai inputar um valor vou imprimir o valor vezes 1, x2 ... x10
; Posso dificultar usando um "print com f string" printando tipo x vezes valor do contador = ... aí seria tipo uma f string incluindo m2 valores
; Fazer em loop pq se eu fizer com as strings setadas vai ser um gasto de memória desnecessário
; Ver se é possível fazer uma string com placeholder na mão, sem printf, se não achar fazer do jeito robo msm, printa a string, printa o valor e printa o final da string

;Se assim ficar muito complicado eu vou pro aproach de setar as strings antes 


extern input 
extern print 

extern string_to_int

extern int_to_string

extern int_to_string_rdi


section .data
    v1 db "Escolha um numero para ver a tabuada dele: ", 10, 0
    v2 db " vezes ", 0 
    v3 db " eh: ", 0
    v4 db " ", 10, 0
    contador dq 1

section .bss
    variavel1 resb 32
    

section .text
    global main

main:

    push rbp 
    mov rbp, rsp 


    mov rdi, v1
    call print
    call input
    call string_to_int
    mov [variavel1], rax
    
     ;a varíavel em formatado de string ficara em rdx
    

    
taubado_loop:
    mov rax, [variavel1]
    mov rdi, variavel1 + 31
    call int_to_string_rdi
    call print ; printa a variavel
    mov rdi, v2
    call print 
    mov rax, [contador]
    mov rdi, variavel1 + 31
    call int_to_string_rdi
    call print ;rdi vai estar com o valor do contador 
    mov rdi, v3
    call print
    mov rax, [variavel1]
    mov rdx, [contador] 
    imul rax, rdx
    mov rdi, variavel1 + 31
    call int_to_string_rdi
    call print
    mov rdi, v4
    call print
    
    inc qword [contador]
    cmp qword [contador], 11
    je .acabou 
    jmp taubado_loop
    
    
.acabou:
    mov rsp, rbp
    pop rbp 


    mov rax, 60
    mov rdi, 0
    syscall