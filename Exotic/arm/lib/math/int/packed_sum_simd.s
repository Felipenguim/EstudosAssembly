.ifndef PACKED_SUM_SIMD
.set PACKED_SUM_SIMD, 1
//Funções simples que não lidam com edge cases
//Só aceita numero par de elementos, e o resultado é armazenado em d0 (parte baixa de v0)
//Retorno será sempre em 64 bits


//partição dos registers simd (v0-v15):
//B = Byte      = 8 bits -> v0.16B  →  16 lanes de 8 bits   = 128 bits
//H = Halfword  = 16 bits -> v0.8H   →   8 lanes de 16 bits  = 128 bits
//S = Single    = 32 bits (word) -> v0.4S    →   4 lanes de 32 bits = 128 bits
//D = Doubleword = 64 bits -> v0.2D    →   2 lanes de 64 bits = 128 bits

.macro packed_sum_i64_neon

//ver se da pra fazer packed_sum_ix_neon com todos no msm arquivo

    //long x0 packed_sum (long x0 (len), long* x1 (arr))
    //computes the sum of a array of lenght {x0} starting at {x1}
    mov x4, x0
    mov x0, #0
    movi v0.2d, #0 
    cmp x4, 2 //minimo 2
    b.lt 2f
    


1:
    ld1 {v2.2d}, [x1], #16 //load post incremented (x1 + 16) de 2 quads  

    //possíveis somas
    //add v0.2d, v1.2d, v2.2d    -> v0[0]=v1[0]+v2[0], v0[1]=v1[1]+v2[1]
    //addp v0.2d, v1.2d, v2.2d   -> v0[0]=v1[0]+v1[1], v0[1]=v2[0]+v2[1]
    //addp d0, v0.2d             -> d0 = v0[0] + v0[1]

    add v0.2d, v2.2d, v0.2d
    subs x4, x4, #2
    b.ne 1b

2:
    addp d0, v0.2d           // reduz: d0 = v0[0] + v0[1]
    fmov x0, d0              // move para escalar
    .endm


.macro packed_sum_i32_neon_no_overflow

//ver se da pra fazer packed_sum_ix_neon com todos no msm arquivo

    //long x0 packed_sum (long x0 (len), long* x1 (arr))
    //computes the sum of a array of lenght {x0} starting at {x1}
    mov x4, x0
    mov x0, #0
    movi v0.2d, #0 
    cmp x4, 4 //minimo 4
    b.lt 2f
    


1:
    ld1 {v2.4s}, [x1], #16 //load post incremented (x1 + 16) de 2 quads  
    saddw  v0.2d, v0.2d, v2.2s   // acumula lanes 0,1
    saddw2 v0.2d, v0.2d, v2.4s   // acumula lanes 2,3
    subs x4, x4, #4
    b.ne 1b

2:
    addp d0, v0.2d           // reduz: d0 = v0[0] + v0[1]
    fmov x0, d0              // move para escalar
    .endm

.macro packed_sum_i32_neon
//versão com risco de overflow, mas mais rápida
    mov x4, x0
    mov x0, #0
    movi v0.4s, #0 
    cmp x4, 4 //minimo 4
    b.lt 2f
1:
    ld1 {v2.4s}, [x1], #16 //load post incremented (x1 + 16) de 2 quads  
    add v0.4s, v2.4s, v0.4s
    subs x4, x4, #4
    b.ne 1b
2:
    saddlp v0.2d, v0.4s   // widening pairwise: 4×32 → 2×64
    addp d0, v0.2d       // reduz: d0 = v0[0] + v0[1]
    fmov x0, d0
    .endm

.macro packed_sum_i16_neon

    mov x4, x0
    mov x0, #0
    movi v0.8h, #0 
    cmp x4, 8 //minimo 8
    b.lt 2f
    


1:
    ld1 {v2.2d}, [x1], #16 //load post incremented (x1 + 16) de 2 quads  
    add v0.8h, v2.8h, v0.8h
    subs x4, x4, #8
    b.ne 1b

2:
    saddlp v0.4s, v0.8h     // 8×16 → 4×32
    saddlp v0.2d, v0.4s     // 4×32 → 2×64
    addp d0, v0.2d           // 2×64 → 1×64
    fmov x0, d0              // move para escalar
    .endm

.macro packed_sum_i16_neon_no_overflow
    mov x4, x0
    movi v0.4s, #0
    cmp x4, #8
    b.lt 2f
1:
    ld1 {v2.8h}, [x1], #16
    saddw  v0.4s, v0.4s, v2.4h
    saddw2 v0.4s, v0.4s, v2.8h
    subs x4, x4, #8
    b.ne 1b
2:
    saddlp v0.2d, v0.4s
    addp d0, v0.2d
    fmov x0, d0
.endm

.macro packed_sum_i8_neon

    mov x4, x0
    mov x0, #0
    movi v0.16b, #0 
    cmp x4, 16 //minimo 16
    b.lt 2f
    


1:
    ld1 {v2.2d}, [x1], #16 //load post incremented (x1 + 16) de 2 quads  
    add v0.16b, v2.16b, v0.16b
    subs x4, x4, #16
    b.ne 1b

2:  
    saddlp v0.8h,  v0.16b   // 16×8  → 8×16
    saddlp v0.4s,  v0.8h    //  8×16 → 4×32
    saddlp v0.2d,  v0.4s    //  4×32 → 2×64
    addp d0, v0.2d           // reduz: d0 = v0[0] + v0[1]
    fmov x0, d0              // move para escalar
    .endm

.macro packed_sum_i8_neon_no_overflow
    mov x4, x0
    movi v0.4s, #0
    cmp x4, #16
    b.lt 2f

1:
    ld1 {v2.16b}, [x1], #16
    saddlp v2.8h, v2.16b
    saddw  v0.4s, v0.4s, v2.4h
    saddw2 v0.4s, v0.4s, v2.8h
    subs x4, x4, #16
    b.ne 1b
2:
    saddlp v0.2d, v0.4s
    addp d0, v0.2d
    fmov x0, d0
    .endm


.endif