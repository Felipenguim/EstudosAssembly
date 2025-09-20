

; section .data
;     msg db 'Hello, world!', 10, 0


section .text
    global print
    global print_num
    global input
    global int_to_string
    global string_to_int
    global int_to_string_rdi

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


print_num:  ;fiz uma chamada que limpa a sujeira de strings e printa o só números, se a sujeira da memória é um número aí F
    
    ;mov rdi, msg tem que tirar por que ele já assume o argumento vindo por rdi
    call print_str_num
    jmp exit_success_num

str_len_num:
    push rbp
    mov rbp, rsp

    mov rax, 0
    .str_len_loop_num:
        cmp [rdi], byte 0
        je .str_len_end_num
        cmp [rdi], byte 48 ;se for menor que zero
        jl .str_len_end_num
        cmp [rdi], byte 57 ;se for maior que 9
        jg .str_len_end_num
        inc rdi
        inc rax
        jmp .str_len_loop_num

    .str_len_end_num:
        mov rsp, rbp
        pop rbp
        ret

    
print_str_num:
    push rbp
    mov rbp, rsp
    
    push rdi
    call str_len_num
    pop rsi

    mov rdx, rax ; tamanho da string
    mov rax, 1 ; syscall write
    mov rdi, 1 ; stdout
    syscall


    mov rsp, rbp 
    pop rbp
    ret

exit_success_num:
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

    
    mov r8, rax
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
    dec rsi   
    

    mov byte [rsi], dl
    cmp rax, 0
    jnz .prox_digit ;se não for zero faz o loop
    ret ;string retorna em rsi         



    ;ver se essa função não deixa algum registrador fudido



; IN (rax,rdi) OUT (rdi) MOD (rax,rbx,rdx)
int_to_string_rdi:
    mov  rbx, 10
.prox_digit_rdi:
    xor  edx, edx
    div  rbx
    add  dl, '0'
    dec  rdi
    mov  [rdi], dl
    test rax, rax
    jnz  .prox_digit_rdi
    ret
    