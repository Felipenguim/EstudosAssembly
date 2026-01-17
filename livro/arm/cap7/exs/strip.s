
.section .data
redct_ambos:
    .asciz "strip em ambos"

redct_direita:
    .asciz "strip à direira"

redct_esquerda:
    .asciz "strip à esquerda"

sem_reduct:
    .asciz "strip em nada"

err_msg:
  .asciz "Error reading string from user"


.section .text
.global _start

.extern read_word
.extern print_string
.extern print_newline
.extern success_exit
.extern print_string_err
.extern print_char


_start:
    //lendo entrada 
    sub sp, sp, #256
    mov x0, sp
    mov x1, #256
    bl read_word 

    cmp x0, '0'
    b.eq .fail 

    //endereço da String em x0 
    mov x3, #0 //tamanho de onde está


    A:      //estado que recebe a string
        //vai ler o primeiro byte e ver se é espaço
        
        ldrb w4, [x0, x3] //store byte em x0 + x3
        cmp w4, #0x00
        b.eq str_null
        add x3, x3, #1

        
        cmp w4, #0x20    // ' '
        //se for espaço
        b.eq B

        //se n for espaço
        b C

        str_null:
            adr x0, sem_reduct
            bl print_string
            bl print_newline
            add sp, sp, #256
            bl success_exit


    B: // estado fica intercalando com e sem espaço até o fim '\0'
        
        ldrb w4, [x0, x3] //store byte em x0 + x3
        add x3, x3, #1   

        cmp w4, #0x20 
        //espaço 
        b.eq E

        cmp w4, #0x00 
        b.ne D 

        //se nulo //nulo nesse caso = (string sendo um unico espaço)
        
        adr x0, redct_ambos
        bl print_string
        bl print_newline
        add sp, sp, #256
        bl success_exit


    D: //Inicio com espaço e agora sem 
    
        ldrb w4, [x0, x3] //store byte em x0 + x3
        
        add x3, x3, #1
        


        cmp w4, #0x20
        //se acha um espaço
        b.eq E

        //ve se acha nulo
        cmp w4, #0x00 
        b.ne D // se não achar segue nesse estado

        //se acabar
        
        
        adr x0, redct_esquerda
        bl print_string
        bl print_newline
        add sp, sp, #256
        bl success_exit

    
    
    E: //Inicio com espaço e agora com
        ldrb w4, [x0, x3] //store byte em x0 + x3
        add x3, x3, #1  

        cmp w4, #0x20
        b.eq E

        cmp w4, #0x00 
        b.ne D 

        adr x0, redct_ambos
        bl print_string
        bl print_newline
        add sp, sp, #256
        bl success_exit

    C:
        ldrb w4, [x0, x3] //store byte em x0 + x3
        add x3, x3, #1 

        cmp w4, #0x20
        //espaço 
        b.eq G

        b F

    F: //Inicio sem espaço e agora sem 
        ldrb w4, [x0, x3] //store byte em x0 + x3
        add x3, x3, #1 
        
        cmp w4, #0x20
        b.eq G

        cmp w4, #0 
        b.ne F

        adr x0, sem_reduct
        bl print_string
        bl print_newline
        add sp, sp, #256
        bl success_exit
        
    G: //Inicio com espaço e agora com
        ldrb w4, [x0, x3] //store byte em x0 + x3
        add x3, x3, #1 

        //se acha um espaço
        cmp w4, #0x20
        b.eq G

        cmp w4, #0x00 
        b.ne F

        adr x0, redct_direita
        bl print_string
        bl print_newline
        add sp, sp, #256
        bl success_exit

.fail:
    adr x0, err_msg
    bl print_string_err
    bl print_newline
    add sp, sp, #256
    bl success_exit

