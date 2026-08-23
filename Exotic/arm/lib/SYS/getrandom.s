.ifndef GETRANDOM
.set GETRANDOM, 1

///////////////////////////////////////////////////////////////////////////////

// int _getrandom(int* {x0}, int {x1}, int {x2})
// Terminates the process with the given exit code.
// @param buffer x0 — 16-byte-aligned scratch buffer for getrandom
// @param buflen x1 - lenght of buffer
// @param flags x2
// @return x0 — number or negative number in fail
.macro _getrandom
    mov x8, #278              // __NR_getrandom
    svc #0
.ENDM

.ENDIF
