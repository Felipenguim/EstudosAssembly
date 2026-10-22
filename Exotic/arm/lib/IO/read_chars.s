.IFNDEF READ
.EQU READ, 1

///////////////////////////////////////////////////////////////////////////////

// ssize_t _read(int fd, void* buf, size_t count)
// Reads up to {count} bytes from file descriptor {fd} into {buf}.
// Returns number of bytes read in X0 on success.
// Returns 0 on end of file.
// Returns negative errno on failure.
// @param fd    X0 — file descriptor
// @param buf   X1 — pointer to destination buffer
// @param count X2 — maximum number of bytes to read
// @return      X0 — bytes read on success, 0 on EOF, negative errno on failure
.MACRO _read

    mov x8, #63
    SVC #0

.ENDM

.ENDIF
