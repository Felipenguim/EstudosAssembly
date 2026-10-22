.IFNDEF IP_TO_CHARS
.EQU IP_TO_CHARS,1

.INCLUDE "IO/int_to_chars.s"

///////////////////////////////////////////////////////////////////////////////

// char* {x0} ip_to_chars(char* {buf}, uint {ip})
// Writes an IPv4 address in dotted-decimal ASCII ("127.0.0.1") into {buf}
// (no null terminator). {ip} is in host order, the same value that is
// given to sockaddr_in_construct / tcp_connect (0x7F000001 -> "127.0.0.1").
// {buf} must have room for up to 15 chars.
// @param buf x0 — destination buffer
// @param ip x1 — IPv4 address (host order)
// @return x0 — buf + number of chars written (pointer to the next free byte)
ip_to_chars:
    stp x29, x30, [sp, #-16]!
    stp x1, x2, [sp, #-16]!
    stp x3, x4, [sp, #-16]!
    mov x29, sp

    mov x3, x1  // ip
    mov x4, #24 // shift do octeto atual: 24, 16, 8, 0

.ip_to_chars_loop:
    lsr x1, x3, x4
    and x1, x1, #0xFF // octeto atual
    bl int_to_chars   // x0 avança

    cbz x4, .ip_to_chars_done // último octeto não leva '.'
    mov w2, #46 // ASCII '.'
    strb w2, [x0], #1
    sub x4, x4, #8
    b .ip_to_chars_loop

.ip_to_chars_done:
    mov sp, x29
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.ENDIF
