#!/bin/bash

# Monta funcs.asm com informações de depuração
nasm -g -f elf64 funcs.asm -o funcs.o

# Monta comparacao.asm com informações de depuração
nasm -g -f elf64 comparacao.asm -o comparacao.o

# Linka os arquivos objeto e cria o executável
gcc -no-pie -o comparacao comparacao.o funcs.o -g

# Executa o programa
./comparacao