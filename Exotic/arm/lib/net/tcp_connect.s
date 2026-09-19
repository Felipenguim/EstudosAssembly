.IFNDEF TCP_CONNECT
.EQU TCP_CONNECT,1

.INCLUDE "SYS/socket.s"
.INCLUDE "SYS/connect.s"
.INCLUDE "SYS/close.s"
.INCLUDE "net/sockaddr_in.s"

///////////////////////////////////////////////////////////////////////////////

// int {x0} tcp_connect(ushort {port}, uint {ip})
// Opens a TCP/IPv4 socket and connects it to {ip}:{port}.
// {port} and {ip} are given in host order (ex: 8000 and 0x7F000001 for
// 127.0.0.1:8000); the conversion to big endian is done internally.
// If connect() fails the socket is closed before returning.
// @param port x0 — destination port (host order)
// @param ip x1 — destination IPv4 address (host order)
// @return x0 — socket fd (>= 0) on success, negative errno on failure
tcp_connect:
    stp x29, x30, [sp, #-16]!
    stp x1, x2, [sp, #-16]!
    stp x3, x4, [sp, #-16]!
    stp x5, x6, [sp, #-16]!
    str x8, [sp, #-16]!
    mov x29, sp

    sub sp, sp, #16 // struct sockaddr_in (16 bytes) na stack

    mov x4, x0 // port
    mov x5, x1 // ip

    //criando o socket
    mov x0, #2 //AF_INET (IPv4)
    mov x1, #1 //SOCK_STREAM (TCP)
    mov x2, #0 //protocol escolhido pelo kernel
    _socket    //retorna x0 com um fd se der certo, x0<0 se erro
    cmp x0, #0
    b.lt .tcp_connect_done
    mov x6, x0 // guardando o fd

    //montando a struct sockaddr_in
    stp xzr, xzr, [sp] // zera os 16 bytes (sin_zero precisa ser zero)
    mov x0, sp
    mov x1, #2 //AF_INET
    mov x2, x4 //port
    mov x3, x5 //ip
    bl sockaddr_in_construct

    mov x0, x6 //fd
    mov x1, sp
    mov x2, #16 //len de sockaddr_in
    _connect //x0 == 0 se correto
    cmp x0, #0
    b.ge .tcp_connect_ok

    //connect falhou: fecha o socket e devolve o erro do connect
    mov x4, x0
    mov x0, x6
    _close
    mov x0, x4
    b .tcp_connect_done

.tcp_connect_ok:
    mov x0, x6 // retorna o fd

.tcp_connect_done:
    mov sp, x29
    ldr x8, [sp], #16
    ldp x5, x6, [sp], #16
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.ENDIF
