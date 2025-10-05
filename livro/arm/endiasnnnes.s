.data
demo1: 
    .quad 0x1122334455667788

demo2:
    .byte 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88



.text
.global _start
.extern print_hex
.extern print_newline

_start:

    adr x0, demo1
    ldr x1, [x0]

    bl print_hex
    bl print_newline

    adr x0, demo2
    ldr x1, [x0]
    bl print_hex
    bl print_newline

    mov x0, #0
    mov x8, #93
    svc #0