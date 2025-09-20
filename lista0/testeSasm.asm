
print:
    
    ;mov rdi, msg tem que tirar por que ele já assume o argumento vindo por rdi
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
    xor rdi, rdi              ; mesma coisa que mov rdi, 0
    mov rax, 0
    ret


input:
    push rbp
    mov rbp, rsp
    sub rsp, 8 ;alocando 4 bytes para o char, o valor de uma int
    mov rdi, 0 ;stdin
    lea rsi, [rsp] ;seta para o espaço 
    mov rdx, 8
    mov rax, 0 ;sys_read
    syscall

    ; mov rbx, [rsi]
    ;mov rax, 0
    mov rsp, rbp
    pop rbp 
    ret

string_to_int:
    mov rax, 0

.next_digit:
    mov dl, byte [rsi] ;o rsi tem a string do input do usuário, vou precisar pegar caracter por caracter dessa string
    inc rsi

    cmp dl, 48 ;se for menor que zero
    jl .fim
    cmp dl, 57 ;se for maior que 9
    jg .fim

    sub dl, 48 ;receberá o valor verdadeiro, fora da tabela asc
    imul rax, 10
    add rax, rdx  ; tem que usar o rdx pra ter registradores de mesmo tamanho, lembrando que dl é uma parte de rdx

    jmp .next_digit



.fim:
    mov rdx, 0
    ret



int_to_string: ;antes de chamar tem que carregar o rax
    ; na divisão você tem menos controle dos registradores, eles já são setados
    ; o o numero dividido e o resultado virão e ficarão respectivamente em rax, o divisor será rbx e o resto irá para rdx

    mov rbx, 10
   

.prox_digit:
    mov rdx, 0
    div rbx
    add dl, '0' ; mesma coisa que somar 48 pela tabela asc
    dec rsi   ; ver se não vai dar problema nele, se pa vou ter que zerar sla
    mov [rsi], dl
    cmp rax, 0
    jnz .prox_digit ;se não for zero faz o loop
    ret ;string retorna em rsi         

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
        
        push rbp
        mov rbp, rsp
        mov rbx, rsi
        sub rsp, 8 ;alocando 4 bytes para o char, o valor de uma int
        mov rdi, 0 ;stdin
        lea rsi, [rsp] ;seta para o espaço 
        mov rdx, 2
        mov rax, 0 ;sys_read
        syscall
        
        
        ;mov rax, 0
        mov rsp, rbp
        pop rbp
        
        
        sub rsp, 8
        mov rax, 0
        
        
      
.next_digit:
    mov dl, byte [rsi] ;o rsi tem a string do input do usuário, vou precisar pegar caracter por caracter dessa string
    inc rsi
                
    cmp dl, 48 ;se for menor que zero
    jl .fim
    cmp dl, 57 ;se for maior que 9
    jg .fim

    sub dl, 48 ;receberá o valor verdadeiro, fora da tabela asc
    imul rax, 10
    add rax, rdx  ; tem que usar o rdx pra ter registradores de mesmo tamanho, lembrando que dl é uma parte de rdx

    jmp .next_digit

.fim:
    

    mov [a], rax ; pega o input e passa para a
    mov rsi, rbx
    mov rdi, v2
    call print
        push rbp
        mov rbp, rsp
        sub rsp, 8 ;alocando 4 bytes para o char, o valor de uma int
        mov rdi, 0 ;stdin
        lea rsi, [rsp] ;seta para o espaço 
        mov rdx, 2
        mov rax, 0 ;sys_read
        syscall
        
        mov rbx, rsi
        ;mov rax, 0
        mov rsp, rbp
        pop rbp 
        
       
    mov rax, 0

.next_digit2:
    mov dl, byte [rsi] ;o rsi tem a string do input do usuário, vou precisar pegar caracter por caracter dessa string
    inc rsi

    cmp dl, 48 ;se for menor que zero
    jl .fim2
    cmp dl, 57 ;se for maior que 9
    jg .fim2

    sub dl, 48 ;receberá o valor verdadeiro, fora da tabela asc
    imul rax, 10
    add rax, rdx  ; tem que usar o rdx pra ter registradores de mesmo tamanho, lembrando que dl é uma parte de rdx

    jmp .next_digit2
     ; pega o input e passa para b

  .fim2:  
    mov [b], rax
    mov rax, 0
    mov rax, [a]   
    add rax, [b]    ; soma
    
    mov rbx, 10
   

.prox_digit:
    mov rdx, 0
    div rbx
    add dl, '0' ; mesma coisa que somar 48 pela tabela asc
    dec rsi   ; ver se não vai dar problema nele, se pa vou ter que zerar sla
    mov [rsi], dl
    cmp rax, 0
    jnz .prox_digit ;se não for zero faz o loop
    

    ; mov rdi, rbx
    ; call print
    mov dl, byte [rsi]
    inc rsi
    mov dh, byte [rsi]
    mov [soma], rdx
    mov rdi, v3
    call print

    
    mov rdi, soma
    call print
    
    mov rdi, v4
    call print
    pop rbp 
    mov rdi, rax
    mov rax, 60
    mov rdi, 0
    syscall 