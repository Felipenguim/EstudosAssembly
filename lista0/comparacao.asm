extern print
extern input
extern string_to_int
extern int_to_string
extern print_num
extern int_to_string_rdi



section .data
t1 db "Escolha a variavel 1:", 10, 0
t2 db "Escolha a variavel 2:", 10, 0
t3 db "Escolha a variavel 3:", 10, 0
v1 db "A variavel 1 eh a maior ", 10, 0
v2 db "A variavel 2 eh a maior", 10, 0
v3 db "A variavel 3 eh a maior", 10, 0
v4 db " ", 10



section .bss
variavel1 resb 8
variavel2 resb 8
variavel3 resb 8




section .text
    global main


main:
    push rbp
    mov rbp, rsp

    mov rdi, t1
    call print
    call input
    call string_to_int
    mov [variavel1], rax
    ; pegar o valor aqui e colocar nos valores 

    mov rdi, t2
    call print
    call input
    call string_to_int
    mov [variavel2], rax

    mov rdi, t3
    call print
    call input
    call string_to_int
    mov [variavel3], rax

    ;cmp = compare    
    ;jl jump se o cmp x, y em que x<y. é um jump lower
    ;je faz se for igual
    ;jg faz se x>y
    ;jmp um jump sem condição 
    mov rax, [variavel1]
    mov rbx, [variavel2]
    mov rcx, [variavel3]

    cmp rax, rbx
    jl .test2_var3 ; se var 2 > var 1
    jmp .test_var3 ;se var 1 > var 2

.test2_var3:
    cmp rbx, rcx
    jl .var3_maior  ;se var 3 > var 2 > var 1
    jmp .var2_maior ;se var 2 > var 3 

.test_var3:
    cmp rax, rcx
    jl .var3_maior
    jmp .var1_maior

.var1_maior:
    mov rdi, v1
    call print
    jmp .end

.var3_maior:
    mov rdi, v3
    call print
    jmp .end

.var2_maior:
    mov rdi, v2
    call print
    jmp .end


.end:
    mov rsp, rbp
    pop rbp

    mov rax, 60
    mov rdi, 0
    syscall