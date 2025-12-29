.data


.section .text

.extern string_equals
.global find_word

//aceita 2 argumentos
// em x0 ponteiro para uma string de key terminzada com nulo (asciz)
// em x1 ponteiro para o último nó do dicionário. Se tivermos um pontierio para a última palavara definida, poderemos segir os links consecutivos e listar todas as palavras
find_word:

    //A func percorrerá todo o dic com um laço, comparando uma dada chave com cada chave do dic.
    //Se o registro não for encontrado, a func retorna 0, se houver devolve o endereço do registro
    //ret em x0

    mov x11, x0 //guardando o endereço da string
    mov x10, x1 //guardando para sempre endereço do head da lista
    
    

    .next_entry:
        
        cmp x1, #0
        b.eq .not_found
        mov x9, x1 //guardando o endereço da palavra atual
        add x1, x9, #8  //carregando o endereço da key em x0, que está em x9 + 8 (pós o ponteiro para a proxima coisa)
        mov x0, x11
    
        //x0 ponteiro para key buscada
        //x1 ponteiro para key existente 
        bl string_equals //retorna em x0 1 se for igual, 0 se for diferente
        cmp x0, #1
        b.eq .found_key

        ldr x1, [x9] //pegando o next
        cmp x0, #0
        b.eq .next_entry
       
    .not_found:
        mov x0, #0
        ret

    .found_key:
        mov x0, x9
        ret