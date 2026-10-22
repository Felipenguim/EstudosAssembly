.IFNDEF TCP_RECV_ALL
.EQU TCP_RECV_ALL,1

.INCLUDE "SYS/READ.s"

///////////////////////////////////////////////////////////////////////////////

// long {x0} tcp_recv_all(int {fd}, char* {buf}, size_t {buf_size})
// Reads from the socket {fd} into {buf} until the peer closes the
// connection (read() returns 0) or {buf} is full.
// Meant for request/response protocols where the server closes after
// answering (ex: HTTP with "Connection: close").
// @param fd x0 — socket fd (from tcp_connect)
// @param buf x1 — destination buffer
// @param buf_size x2 — capacity of buf in bytes
// @return x0 — total bytes received, negative errno on failure
tcp_recv_all:
    stp x1, x2, [sp, #-16]!
    stp x3, x4, [sp, #-16]!
    str x8, [sp, #-16]!

    mov x3, x0 // fd
    mov x4, #0 // total recebido

.tcp_recv_all_loop:
    cbz x2, .tcp_recv_all_done // buffer cheio

    mov x0, x3
    _read // x0 = bytes lidos, 0 = EOF, <0 se erro
    cmp x0, #0
    b.lt .tcp_recv_all_err
    b.eq .tcp_recv_all_done // servidor fechou a conexão

    add x1, x1, x0 // avança o ponteiro
    sub x2, x2, x0 // diminui o espaço livre
    add x4, x4, x0
    b .tcp_recv_all_loop

.tcp_recv_all_done:
    mov x0, x4

.tcp_recv_all_err:
    ldr x8, [sp], #16
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    ret

.ENDIF
