.IFNDEF READ
.EQU READ,1

///////////////////////////////////////////////////////////////////////////////

// ssize_t _read(int fd, void* buf, size_t count)
// Reads up to {count} bytes from the file descriptor {fd} into {buf}.
// @param fd X0 — file descriptor to read from
// @param buf X1 — pointer to buffer where data will be stored
// @param count X2 — max number of bytes to read
// @return X0 — number of bytes read on success (0 = EOF), negative errno on failure
.MACRO _read

	mov x8, #63
	SVC #0

.ENDM

.ENDIF
