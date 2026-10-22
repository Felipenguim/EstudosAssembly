.ifndef EXIT
.set EXIT, 1

///////////////////////////////////////////////////////////////////////////////

// void _exit(int code)
// Terminates the process with the given exit code.
// Note: exit code is only 8 bits (0–255).
// @param code X0 — exit code (0–255)
// @return never — does not return
.macro _exit
    mov x8, #93
    svc #0
.endm

.endif
