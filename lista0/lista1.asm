section .data
valueA DD 2
valueB DD 5

section .bss
valueC RESD 1

section .text
global main

main: 
    mov ebp, esp
    mov ecx, [valueB]
    mov edx, [valueA]
    push ecx
    push edx
    pop eax
    pop ebx
    mov [valueC], eax
    mov [valueA], ebx
    mov ecx, [valueC]
    mov [valueB], ecx
    
    mov eax, 0
    ret