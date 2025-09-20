#!/bin/bash

# Monta funcs.asm com informações de depuração
nasm -g -f elf64 funcs.asm -o funcs.o

# Monta tabuada.asm com informações de depuração
nasm -g -f elf64 tabuada.asm -o tabuada.o

# Linka os arquivos objeto e cria o executável
gcc -no-pie -o tabuada tabuada.o funcs.o -g

# Executa o programa
./tabuada