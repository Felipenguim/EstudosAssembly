//dicionário em arm64

//linked list exemplo
//.data

//p1:
 //   .quad p2
   // .quad 100

//p2:
  //  .quad p3
   // .quad 200

//p3:
  //  .quad 0
   // .quad 300

//O que o ex quer
//struct Entry {
//    Entry* next;      // ponteiro para a próxima entrada
  //  char*  key;       // string terminada em 0
//    char*  value;     // string terminada em 0
//}


.section .data
last_entry:
    .quad 0



.include "colon.inc"
.include "words.inc"


.section .text

.global _start

_start:
  adr x1, last_entry   // x1 = &last_entry (endereço do rótulo)
  ldr x1, [x1]         // x1 = last_entry (valor do rótulo, ou seja, ponteiro para ultimo nó)


  //ler um buffer do usuário de no máximo 255 bytes, usar o find_word, se achar devolver o value daquela key, printando
  //se não achar devolver um erro, que é diferente de uma print normal 