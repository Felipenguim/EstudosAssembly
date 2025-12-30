//dicionário em arm64

.section .rodata
.include "colon.inc"
.include "words.inc"

.section .data

last_entry:
    .quad __last_entry_sym

err_msg:
  .asciz "Word not found"





.section .text

.global _start
.extern read_word
.extern success_exit
.extern find_word
.extern print_newline
.extern print_string
.extern print_string_err
.extern string_length

_start:
  //ler um buffer do usuário de no máximo 255 bytes, usar o find_word, se achar devolver o value daquela key, printando
  //se não achar devolver um erro, que é diferente de uma print normal 

  //lendo entrada
  sub sp, sp, #256
  mov x0, sp
  mov x1, #256
  bl read_word //endereço saindo em x0
  cmp x0, '0'
  b.eq .fail //não conseguiu ler a frase
  

  //caso de certo, ponteiro da string em x0 

  adr x1, last_entry   // x1 = &last_entry (endereço do rótulo)
  ldr x1, [x1]         // x1 = last_entry (valor do rótulo, ou seja, ponteiro para ultimo nó)


  //tenho os argumentos em x0 e x1
  bl find_word
  add sp, sp, #256
  cmp x0, #0
  b.eq .fail

  //else: x0 com endereço do node, devo printar value da key e sair

  //nó + 0 -> next; nó + 8 -> key; nó + 8 + len(key) + 1 (\0) -> value
  mov x10, x0 //guardando em x10 o endereço do nó
  add x0, x0, #8 //endereço da key

  bl string_length //saída da len(key) em x0
  add x0, x0, #9
  add x0, x10, x0 //colocando o ponteiro para value em x0
  
  bl print_string
  bl print_newline
  bl success_exit


  .fail:
    adr x0, err_msg
    bl print_string_err
    bl print_newline

    bl success_exit
