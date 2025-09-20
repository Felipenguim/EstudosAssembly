#!/bin/bash

# Monta funcs.asm com informações de depuração
nasm -g -f elf64 funcs.asm -o funcs.o

# Monta contagem.asm com informações de depuração
nasm -g -f elf64 contagem.asm -o contagem.o

# Linka os arquivos objeto e cria o executável
gcc -no-pie -o contagem contagem.o funcs.o -g

# Executa o programa
./contagem