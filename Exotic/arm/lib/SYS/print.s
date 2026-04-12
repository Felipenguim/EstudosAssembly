.IFNDEF PRINT
.EQU PRINT,1

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

.MACRO _print
// ssize_t _print(int fd, const void* buf, size_t len);
//
//   Writes {count} bytes from {buf} to the file descriptor {fd}.
//   Use fd=1 for stdout, fd=2 for stderr.
//   Returns number of bytes written in X0 on success, negative errno on failure.
//
//   X0 = fd
//   X1 = buf (string address)
//   X2 = len (number of bytes to write)


	mov x8, #64
	SVC #0

	
.ENDM

.ENDIF
