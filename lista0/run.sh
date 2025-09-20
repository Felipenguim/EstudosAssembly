#!/bin/bash

# Monta o arquivo funcs.asm
nasm -f elf64 funcs.asm -o funcs.o

# Monta o arquivo soma.asm
nasm -f elf64 soma.asm -o soma.o

# Linka os arquivos objeto e cria o executável
gcc -no-pie -o soma soma.o funcs.o

# Executa o programa
./soma