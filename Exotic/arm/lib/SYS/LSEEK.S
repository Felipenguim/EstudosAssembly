.IFNDEF LSEEK
.EQU LSEEK,1

///////////////////////////////////////////////////////////////////////////////


// ssize_t _lseek(int fd, int offset, int whence)
// change the cursosr from fd, saying where the kernel has to read.
// SEEK_SET = 0 → offset é absoluto, contado desde o início do arquivo (é isso que você quer aqui)
// SEEK_CUR = 1 → offset é relativo à posição atual do cursor
// SEEK_END = 2 → offset é relativo ao fim do arquivo
// @param fd x0 — file descriptor of an already-opened directory
// @param ofset X1 — offset
// @param whence X2 — the whey the offset has to be deal with
// @return x0 — offset value if succeed
.MACRO _lseek

	mov x8, #62
	SVC #0

.ENDM

.ENDIF
