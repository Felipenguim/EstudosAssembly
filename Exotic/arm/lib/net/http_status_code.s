.IFNDEF HTTP_STATUS_CODE
.EQU HTTP_STATUS_CODE,1

///////////////////////////////////////////////////////////////////////////////

// int {x0} http_status_code(char* {resp})
// Parses the status line of an HTTP response ("HTTP/1.0 200 OK\r\n...")
// and returns the numeric status code (200, 400, 404, ...).
// @param resp x0 — pointer to the beginning of the http response
// @return x0 — status code, or -1 if resp does not start with "HTTP/"
http_status_code:
    stp x1, x2, [sp, #-16]!
    stp x3, x4, [sp, #-16]!

    mov x1, x0 // ponteiro para percorrer a resposta

    // confere o prefixo "HTTP/"
    adr x2, http_status_code_prefix
    mov x3, #5
.http_status_code_prefix_loop:
    ldrb w4, [x2], #1
    ldrb w0, [x1], #1
    cmp w0, w4
    b.ne .http_status_code_invalid
    subs x3, x3, #1
    b.ne .http_status_code_prefix_loop

    // pula a versão até o primeiro espaço ("HTTP/1.0 ")
.http_status_code_skip_version:
    ldrb w0, [x1], #1
    cbz w0, .http_status_code_invalid // acabou a string antes do espaço
    cmp w0, #32 // ASCII ' '
    b.ne .http_status_code_skip_version

    // lê os dígitos do código
    mov x0, #0
    mov x3, #10
.http_status_code_digits:
    ldrb w2, [x1], #1
    sub w2, w2, #48 // ASCII '0'
    cmp w2, #9
    b.hi .http_status_code_done // não é dígito (espaço, \r, ...) -> fim
    madd x0, x0, x3, x2 // x0 = x0 * 10 + dígito
    b .http_status_code_digits

.http_status_code_invalid:
    mov x0, #-1

.http_status_code_done:
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    ret

http_status_code_prefix:
    .ascii "HTTP/"
.balign 4 // volta a alinhar o código depois da string

.ENDIF
