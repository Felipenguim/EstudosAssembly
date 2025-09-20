section .data
    msg db 'Hello, Assembly!', 0Ah  ; String para imprimir
    len equ $ - msg                 ; Comprimento da string

section .text
    global main

main:
    mov eax, 4          ; syscall: write
    mov ebx, 1          ; saída: stdout
    mov ecx, msg        ; endereço da string
    mov edx, len        ; comprimento da string
              

    mov eax, 1          ; syscall: exit
    xor ebx, ebx        ; código de saída: 0
    ret