.IFNDEF PRINT
.EQU PRINT,1

///////////////////////////////////////////////////////////////////////////////

// ssize_t _print(int fd, const void* buf, size_t len)
// Writes {len} bytes from {buf} to the file descriptor {fd}.
// Use fd=1 for stdout, fd=2 for stderr.
// Returns number of bytes written in X0 on success, negative errno on failure.
// @param fd X0 — file descriptor (1=stdout, 2=stderr)
// @param buf X1 — pointer to data buffer
// @param len X2 — number of bytes to write
// @return X0 — number of bytes written on success, negative errno on failure
.MACRO _print

	mov x8, #64
	SVC #0

.ENDM

.ENDIF
