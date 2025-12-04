//sudo sysctl -w kernel.randomize_va_space=0




//endereço real é achar o endereço da variável mais o offset do compilador (que é o local do .bss normalmente que pegamos no pid)

//0000000000010238 B next

//555555564000-555555565000 endereço total do segmento .bss
//next está em 555555564000 + 000000000000238
//next está em 555555564238

// set {int}0x555555564238 = 
