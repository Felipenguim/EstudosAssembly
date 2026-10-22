.global _start

// Testes apenas para string_equals

.extern print_string
.extern print_newline
.extern string_equals
.extern exit

.data
str1:     .asciz "ola"
str2:     .asciz "ola"
str3:     .asciz "mundo"
str4:     .asciz "ola mundo"

msg_equal:      .asciz "IGUAL
"
msg_not_equal:  .asciz "DIFERENTE
"

msg_failed:    .asciz "FALHOU
"

.text

_start:
    // Teste 1: strings iguais
    adr x0, str1
    adr x1, str2
    bl string_equals
    cmp x0, #1
    b.ne t1_fail
    adr x0, msg_equal
    bl print_string
    b test2

t1_fail:
    adr x0, msg_failed
    bl print_string

// ------------------------------
// Teste 2: strings diferentes
// ------------------------------

test2:
    adr x0, str1
    adr x1, str3
    bl string_equals
    cmp x0, #1
    b.eq t2_fail
    adr x0, msg_not_equal
    bl print_string
    b test3

t2_fail:
    adr x0, msg_failed
    bl print_string

// ------------------------------
// Teste 3: strings iguais até certo ponto
// Ex: "ola" vs "ola mundo"
// Deve dar DIFERENTE
// ------------------------------

test3:
    adr x0, str1
    adr x1, str4
    bl string_equals
    cmp x0, #1
    b.eq t3_fail
    adr x0, msg_not_equal
    bl print_string
    b test_copy1

t3_fail:
    adr x0, msg_failed
    bl print_string

fim:
    mov x0, #0
    bl exit

// ------------------------------
// Testes para string_copy
// ------------------------------

// Buffer para testes
.data
buffer1: .space 32
buffer2: .space 5
buffer3: .space 32

empty_str:   .asciz ""

copy_ok:      .asciz "COPIA OK: 
"
copy_fail:    .asciz "COPIA FALHOU
"

.text

test_copy1:
    // Teste 4: Copia simples (deve funcionar)
    adr x0, str1        // origem "ola"
    adr x1, buffer1     // destino buffer grande
    mov x2, #32         // tamanho do buffer
    bl string_copy
    cmp x0, #0
    b.eq tc1_fail

    adr x0, copy_ok
    bl print_string
    adr x0, buffer1
    bl print_string
    bl print_newline
    b test_copy2

tc1_fail:
    adr x0, copy_fail
    bl print_string

// ------------------------------
// Teste 5: buffer pequeno (deve falhar)
// ------------------------------

test_copy2:
    adr x0, str4        // "ola mundo" (10 chars)
    adr x1, buffer2     // buffer pequeno: 5 bytes
    mov x2, #5          // tamanho insuficiente
    bl string_copy
    cmp x0, #0
    b.ne tc2_fail       // se não falhar → erro

    adr x0, copy_fail
    bl print_string
    b test_copy3

tc2_fail:
    adr x0, msg_failed
    bl print_string

// ------------------------------
// Teste 6: copia string vazia
// ------------------------------

test_copy3:
    adr x0, empty_str       // origem ""
    adr x1, buffer3
    mov x2, #32
    bl string_copy
    cmp x0, #0
    b.eq tc3_fail

    adr x0, copy_ok
    bl print_string
    adr x0, buffer3
    bl print_string
    bl print_newline
    b fim

tc3_fail:
    adr x0, msg_failed
    bl print_string

