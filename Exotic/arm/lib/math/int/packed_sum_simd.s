.ifndef PACKED_SUM_SIMD
.set PACKED_SUM_SIMD, 1

.global packed_sum_i64_neon

//ver se da pra fazer packed_sum_ix_neon com todos no msm arquivo
packed_sum_i64_neon:
    //long x0 packed_sum (long x0 (len), long* x1 (arr))
    //computes the sum of a array of lenght {x0} starting at {x1}

   

.loop:
    

.done:
    ret


.endif