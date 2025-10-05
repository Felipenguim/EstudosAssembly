# ==============================================
# ARM64 Addressing Cheat Sheet
# ==============================================

# Base + Immediate offset
ldr x0, [x1, #16]        // = [rbx + 16]

# Base + Register offset
ldr x0, [x1, x2]         // = [rbx + rcx]

# Base + Scaled Register offset
ldr x0, [x1, x2, LSL #2] // = [rbx + rcx*4]
ldr x0, [x1, x2, LSL #3] // = [rbx + rcx*8]

# Just scaled register (no base)
ldr x0, [xzr, x2, LSL #4] // = [rcx*16]

# Load Effective Address (no memory access)
add x0, x1, #8           // = &rbx + 8
add x0, x1, x2           // = rbx + rcx
add x0, x1, x1, LSL #2   // = rbx + rbx*4  (== rbx*5)

# Store examples
str x3, [x0, #8]         // mem[base+8] = x3
str x3, [x0, x1, LSL #3] // mem[base + index*8] = x3

# Post-indexed and pre-indexed (com modificador do SP)
ldr x0, [sp, #16]!       // pré-indexado (sp = sp + 16 antes)
ldr x0, [sp], #16        // pós-indexado (sp = sp + 16 depois)
