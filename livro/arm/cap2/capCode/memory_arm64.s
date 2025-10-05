# =============================================
# ARM64 - Endereços e Acesso à Memória
# =============================================

# x86: mov rsi, codes
# rsi <- endereço da label 'codes'
adr   x1, codes
# (ou, se estiver longe no código:)
# adrp x1, codes
# add  x1, x1, :lo12:codes


# x86: mov rsi, [codes]
# rsi <- conteúdo de memória começando em 'codes'
ldr   x1, codes
# lê 8 bytes (64 bits) no registrador x1
# (use w1 se quiser ler 32 bits, h1 para 16 bits, b1 para 8 bits)


# x86: lea rsi, [codes]
# rsi <- endereço de 'codes'
# (igual a mov rsi, codes no x86)
adr   x1, codes
# ou, se longe:
# adrp x1, codes
# add  x1, x1, :lo12:codes


# x86: mov rsi, [codes + rax]
# rsi <- conteúdo da memória em (codes + rax)
adr   x2, codes
add   x2, x2, x0        // x0 = offset (como rax)
ldr   x1, [x2]


# x86: lea rsi, [codes + rax]
# rsi <- endereço (codes + rax)
adr   x1, codes
add   x1, x1, x0        // x0 = offset (como rax)
# (sem acessar memória)


# =============================================
# Dicas práticas
# =============================================

# adr   -> gera endereço relativo (±1MB)
# adrp  -> pega a base da página (endereços longos)
# add   -> soma offsets
# ldr   -> lê o valor armazenado (load)
# str   -> grava valor (store)

# [reg]           -> acesso direto à memória
# [reg, #8]       -> acesso com deslocamento imediato
# [reg, reg2]     -> acesso com deslocamento em outro registrador

# Exemplo completo:
# x1 = endereço de codes
# x2 = x1 + x0
# x3 = valor em memória em x2
adr   x1, codes
add   x2, x1, x0
ldr   x3, [x2]
