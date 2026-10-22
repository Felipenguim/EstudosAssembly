.ifndef PACKED_SUM
.set PACKED_SUM, 1

.macro  _packed_sum
    //long x0 packed_sum (long x0 (len), long* x1 (arr))
    //computes the sum of a array of lenght {x0} starting at {x1}

    mov x4, x0
    mov x0, #0
    cmp x4, 1
    b.lt 2f

1:
    ldr x3, [x1], #8 //load post incremented (x2 + 8)
    add x0, x0, x3
    subs x4, x4, #1         // len--
    //subs to update the flags
    b.ne 1b

2:
    .endm


.endif
