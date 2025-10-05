.data
codes:
    .ascii "0123456789ABCDEF"
newline:
    .ascii "\n"

.text
.global print_hex
.global print_newline

print_newline:
    mov x0, 1
    adr x1, newline
    mov x2, 1
    mov x8, #64
    svc #0
    ret

print_hex:
    mov x0, x1
    mov x2, 1
    mov x8, #64
    mov x4, 64
.loop:
    str x0, [sp, #-16]!
    sub x4, x4, #4
    asr x0, x0, x4
    and x0, x0, #0xF
    adr x1, codes
    add x1, x1, x0
    mov x0, 1
    svc #0
    ldr x0, [sp], #16
    cmp x4, #0
    b.ne .loop
    ret
