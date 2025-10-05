# ARM64 (GNU Assembler) - Literais Numéricos

# Decimal (padrão)
mov x0, #200        // decimal 200
mov x0, #0200       // decimal 200 (prefixo zero não muda nada)
mov x0, #200        // GAS não usa sufixo 'd' ou 'q'

# Hexadecimal
mov x0, #0xC8       // hexadecimal 0xC8 = 200 decimal
mov x0, #0xc8       // também hexadecimal (case-insensitive)
mov x0, #0Xc8       // ainda hexadecimal
# (o prefixo '$' pode funcionar em alguns montadores, mas evite)

# Octal
mov x0, #0310       // octal 0310 = 200 decimal
mov x0, #0o310      // octal explícito (forma moderna e legível)

# Binário
mov x0, #0b11001000     // binário 11001000 = 200 decimal
mov x0, #0b1100_1000    // binário com underscore (melhor legibilidade)

# Observações:
# - GAS não aceita sufixos como h, d, o, b (diferente do NASM)
# - Use prefixos: 0x (hex), 0b (bin), 0o ou 0 (octal), nenhum (decimal)
# - '_' é aceito como separador de dígitos
