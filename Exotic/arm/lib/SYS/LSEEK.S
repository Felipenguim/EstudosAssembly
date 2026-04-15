.IFNDEF LSEEK
.EQU LSEEK,1

.INCLUDE "SYS/HELPER.S"

///////////////////////////////////////////////////////////////////////////////

// off_t __LSEEK()
// Internal helper — seeks using {fd}, {offset}, {whence} from the stack above volatiles.
// Preserves all volatile registers; result returned in X0.
// @return X0 — resulting file offset on success, negative errno on failure
.MACRO __LSEEK

	_PUSH_VOLATILES

	LDP X0,X1,[SP,VOLATILE_LENGTH]
	LDR X2,[SP,VOLATILE_LENGTH+16]

	BL LSEEK

	_POP_VOLATILES

.ENDM

// off_t _LSEEK(fd, offset, whence)
// Repositions the file offset of {fd} to {offset} bytes relative to {whence}.
// Returns the resulting offset from the beginning of the file in X0 on success.
// @param fd X0 — file descriptor
// @param offset X1 — byte offset to seek to
// @param whence X2 — reference point (SEEK_SET=0, SEEK_CUR=1, SEEK_END=2)
// @return X0 — resulting file offset on success, -1 on failure
.MACRO _LSEEK FD, OFFSET, WHENCE

	SUB SP,SP,32
	MOV X20,\FD
	STR X20,[SP,0]
	MOV X20,\OFFSET
	STR X20,[SP,8]
	MOV X20,\WHENCE
	STR X20,[SP,16]

	__LSEEK

	ADD SP,SP,32

.ENDM

.IFDEF VERBOSE_LOGS

.INCLUDE "IO/LOG_TEXT.S"
.INCLUDE "IO/LOG_DECIMAL.S"
.INCLUDE "IO/LOG_HEXADECIMAL.S"

1:	.ASCII "LSEEKING WITH WHENCE="
2:	.ASCII " TO BYTE=0X"
3:	.ASCII " IN FD="
4:	.ASCII ", FAIL.   \n"
5:	.ASCII ", SUCCESS.\n"

.ENDIF

///////////////////////////////////////////////////////////////////////////////

.ALIGN 2

LSEEK:	// LSEEK({W0}, {X1}, {W2});
	// RETURNS OFFSET LOCATION ON SUCCESS OR -1 ON FAIL.
	
.IFDEF VERBOSE_LOGS
	SUB SP,SP,48
	STP X0,X1,[SP,16]
	STP X2,X3,[SP,0]
	STR LR,[SP,32]
	_LOG_TEXT 1b 21
	LDP X2,X3,[SP,0]
	_LOG_DECIMAL X2	
	_LOG_TEXT 2b,11
	LDP X0,X1,[SP,16]
	_LOG_HEXADECIMAL X1
	_LOG_TEXT 3b,7
	LDP X0,X1,[SP,16]
	_LOG_DECIMAL X0
	LDP X0,X1,[SP,16]
	LDP X2,X3,[SP,0]
	LDR LR,[SP,32]
	ADD SP,SP,48

.ENDIF

	MOV W8, SYS_LSEEK 
	SVC 0

.IFDEF VERBOSE_LOGS

	SUB SP,SP,16
	STR X0,[SP,0]
	
	AND X0,X0,0X8000000000000000
	ADD X0,X0,1
	MOV X1,11
	MUL X0,X0,X1
	ADD X0,X0,4b
	_LOG_TEXT X0,11

	LDR X0,[SP,0]
	ADD SP,SP,16
	
.ENDIF

	RET

.ENDIF
