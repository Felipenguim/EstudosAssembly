.IFNDEF WRITE
.EQU WRITE,1

///////////////////////////////////////////////////////////////////////////////

// ssize_t _write(int fd, void* buf, size_t count)
// Writes {count} bytes from {buf} to the file descriptor {fd}.
// @param fd X0 — file descriptor to write to
// @param buf X1 — pointer to buffer containing data to write
// @param count X2 — number of bytes to write
// @return X0 — number of bytes written on success, negative errno on failure
.MACRO _write

	mov x8, #64
	SVC #0

.ENDM

.ENDIF
