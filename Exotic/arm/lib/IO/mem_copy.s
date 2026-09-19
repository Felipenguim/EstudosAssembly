.IFNDEF MEM_COPY
.EQU MEM_COPY,1

///////////////////////////////////////////////////////////////////////////////

// char* {x0} mem_copy(char* {dst}, char* {src}, size_t {len})
// Copies {len} bytes from {src} to {dst}. The two regions must not overlap.
// Returns the address right after the last byte written, so consecutive
// calls can be chained to append pieces into the same buffer.
// @param dst x0 — destination buffer
// @param src x1 — source buffer
// @param len x2 — number of bytes to copy
// @return x0 — dst + len (pointer to the next free byte in dst)
mem_copy:
    stp x1, x2, [sp, #-16]!
    str x3, [sp, #-16]!

    add x2, x1, x2 // x2 aponta para um byte depois do fim de src

.mem_copy_loop:
    cmp x1, x2
    b.hs .mem_copy_done
    ldrb w3, [x1], #1 // load byte from src and post-increment pointer
    strb w3, [x0], #1 // store byte in dst and post-increment pointer
    b .mem_copy_loop

.mem_copy_done:
    ldr x3, [sp], #16
    ldp x1, x2, [sp], #16
    ret

.ENDIF
