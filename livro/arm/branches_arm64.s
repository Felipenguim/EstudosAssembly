# =============================================
# ARM64 - Comparações e Jumps (Branchs)
# =============================================

# Comparação base:
cmp x0, x1       // compara x0 - x1
# depois disso, usa-se:
# b.<cond> label


# ---------------------------------------------
# Igualdade
# ---------------------------------------------
# x86: je label      -> jump if equal
b.eq label          // equal
# x86: jne label     -> jump if not equal
b.ne label          // not equal


# ---------------------------------------------
# Comparações com sinal (signed)
# ---------------------------------------------
# x86: jl label      -> jump if less (signed)
b.lt label          // x0 < x1 (signed)
# x86: jle label     -> jump if less or equal (signed)
b.le label          // x0 <= x1 (signed)
# x86: jg label      -> jump if greater (signed)
b.gt label          // x0 > x1 (signed)
# x86: jge label     -> jump if greater or equal (signed)
b.ge label          // x0 >= x1 (signed)


# ---------------------------------------------
# Comparações sem sinal (unsigned)
# ---------------------------------------------
# x86: jb label      -> jump if below (unsigned)
b.lo label          // unsigned less than
# x86: jbe label     -> jump if below or equal (unsigned)
b.ls label          // unsigned <=
# x86: ja label      -> jump if above (unsigned)
b.hi label          // unsigned >
# x86: jae label     -> jump if above or equal (unsigned)
b.hs label          // unsigned >=


# ---------------------------------------------
# Outros úteis
# ---------------------------------------------
# b label       -> incondicional (x86: jmp)
# cbz x0, label -> branch if x0 == 0
# cbnz x0, label -> branch if x0 != 0
# tbnz x0, #bit, label -> branch if bit set
# tbz  x0, #bit, label -> branch if bit clear


# =============================================
# Exemplo prático: if (x0 < 42) then x1 = 1 else x1 = 0
# =============================================

    mov  x0, #30
    cmp  x0, #42
    b.lt yes
    mov  x1, #0
    b    done
yes:
    mov  x1, #1
done:

# =============================================
# Exemplo: signed vs unsigned
# =============================================

    mov  x0, #-1
    mov  x1, #2
    cmp  x0, x1
    b.gt signed_greater      // usa comparação com sinal
    b.hi unsigned_greater    // usa comparação sem sinal
