.IFNDEF HTTP_POST_BUILD
.EQU HTTP_POST_BUILD,1

.INCLUDE "IO/mem_copy.s"
.INCLUDE "IO/strlen.s"
.INCLUDE "IO/int_to_chars.s"
.INCLUDE "net/ip_to_chars.s"

///////////////////////////////////////////////////////////////////////////////

// size_t {x0} http_post_build(char* {out}, uint {ip}, ushort {port}, char* {path}, char* {body}, size_t {body_len})
// Builds a complete HTTP/1.1 POST request into {out}, ready to be sent
//
//   POST {path} HTTP/1.1\r\n
//   Host: {ip}:{port}\r\n
//   Content-Type: text/plain\r\n
//   Content-Length: {body_len}\r\n
//   Connection: close\r\n
//   \r\n
//   {body}
//
// "Connection: close" makes the server close the socket after answering,
// so the response can be read with tcp_recv_all.
// {out} must have room for ~110 bytes + strlen(path) + body_len.
// @param out x0 — destination buffer for the request
// @param ip x1 — server IPv4 address (host order, ex: 0x7F000001)
// @param port x2 — server port (host order, ex: 8000)
// @param path x3 — null-terminated path (ex: "/")
// @param body x4 — pointer to the body bytes
// @param body_len x5 — number of bytes in body
// @return x0 — total length of the request written into out
http_post_build:
    stp x29, x30, [sp, #-16]!
    stp x1, x2, [sp, #-16]!
    stp x3, x4, [sp, #-16]!
    stp x5, x6, [sp, #-16]!
    stp x9, x10, [sp, #-16]!
    stp x11, x12, [sp, #-16]!
    mov x29, sp

    mov x6, x0  // início de out (para calcular o tamanho no fim)
    mov x9, x1  // ip
    mov x10, x2 // port
    mov x11, x3 // path
    mov x12, x4 // body  (x5 = body_len fica onde está)

    // "POST "
    adr x1, http_post_s_method
    mov x2, #HTTP_POST_S_METHOD_LEN
    bl mem_copy // x0 avança para o próximo byte livre

    // {path}
    mov x3, x0
    mov x0, x11
    bl strlen   // x0 = strlen(path)
    mov x2, x0
    mov x0, x3
    mov x1, x11
    bl mem_copy

    // " HTTP/1.1\r\nHost: "
    adr x1, http_post_s_host
    mov x2, #HTTP_POST_S_HOST_LEN
    bl mem_copy

    // {ip}
    mov x1, x9
    bl ip_to_chars

    // ":"
    mov w1, #58 // ASCII ':'
    strb w1, [x0], #1

    // {port}
    mov x1, x10
    bl int_to_chars

    // "\r\nContent-Type: text/plain\r\nContent-Length: "
    adr x1, http_post_s_headers
    mov x2, #HTTP_POST_S_HEADERS_LEN
    bl mem_copy

    // {body_len}
    mov x1, x5
    bl int_to_chars

    // "\r\nConnection: close\r\n\r\n"
    adr x1, http_post_s_end
    mov x2, #HTTP_POST_S_END_LEN
    bl mem_copy

    // {body}
    mov x1, x12
    mov x2, x5
    bl mem_copy

    sub x0, x0, x6 // tamanho total = fim - início

    mov sp, x29
    ldp x11, x12, [sp], #16
    ldp x9, x10, [sp], #16
    ldp x5, x6, [sp], #16
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    ldp x29, x30, [sp], #16
    ret

//pedaços fixos da request (os variáveis são inseridos entre eles)
http_post_s_method:
    .ascii "POST "
.equ HTTP_POST_S_METHOD_LEN, . - http_post_s_method

http_post_s_host:
    .ascii " HTTP/1.1\r\n"
    .ascii "Host: "
.equ HTTP_POST_S_HOST_LEN, . - http_post_s_host

http_post_s_headers:
    .ascii "\r\n"
    .ascii "Content-Type: text/plain\r\n"
    .ascii "Content-Length: "
.equ HTTP_POST_S_HEADERS_LEN, . - http_post_s_headers

http_post_s_end:
    .ascii "\r\n"
    .ascii "Connection: close\r\n"
    .ascii "\r\n"
.equ HTTP_POST_S_END_LEN, . - http_post_s_end

.balign 4 // volta a alinhar o código depois das strings

.ENDIF
