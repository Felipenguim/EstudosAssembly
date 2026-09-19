.IFNDEF TCP_SEND_ALL
.EQU TCP_SEND_ALL,1

.INCLUDE "SYS/WRITE.s"

///////////////////////////////////////////////////////////////////////////////

// long {x0} tcp_send_all(int {fd}, char* {buf}, size_t {len})
// Sends the whole {buf} through the socket {fd}.
// A single write() may send fewer bytes than asked, so this loops until
// every byte was written (or an error happens).
// @param fd x0 — socket fd (from tcp_connect)
// @param buf x1 — pointer to the data to send
// @param len x2 — number of bytes to send
// @return x0 — total bytes sent (== len on success), negative errno on failure
tcp_send_all:
    stp x1, x2, [sp, #-16]!
    stp x3, x4, [sp, #-16]!
    str x8, [sp, #-16]!

    mov x3, x0 // fd
    mov x4, #0 // total enviado

.tcp_send_all_loop:
    cbz x2, .tcp_send_all_done // nada mais para enviar

    mov x0, x3
    _write // x0 = bytes escritos, <0 se erro
    cmp x0, #0
    b.lt .tcp_send_all_err
    b.eq .tcp_send_all_done // 0 bytes escritos: não adianta insistir

    add x1, x1, x0 // avança o ponteiro
    sub x2, x2, x0 // diminui o que falta
    add x4, x4, x0
    b .tcp_send_all_loop

.tcp_send_all_done:
    mov x0, x4 //total enviado em x0 para o retorno

.tcp_send_all_err:
    ldr x8, [sp], #16
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    ret

.ENDIF
