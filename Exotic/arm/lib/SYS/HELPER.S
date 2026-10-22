.IFNDEF HELPER
.EQU HELPER,1

///////////////////////////////////////////////////////////////////////////////

.EQU VOLATILE_LENGTH,160

// void _PUSH_VOLATILES()
// Saves LR and all volatile registers (X0–X18) to the stack.
// @return — SP decremented by VOLATILE_LENGTH (160 bytes)
.MACRO _PUSH_VOLATILES
	SUB SP, SP, VOLATILE_LENGTH
	STP LR, X0, [SP,0]
	STP X1, X2, [SP,16]
	STP X3, X4, [SP,32]
	STP X5, X6, [SP,48]
	STP X7, X8, [SP,64]
	STP X9, X10, [SP,80]
	STP X11, X12, [SP,96]
	STP X13, X14, [SP,112]
	STP X15, X16, [SP,128]
	STP X17, X18, [SP,144]
.ENDM

// void _POP_VOLATILES()
// Restores LR and all volatile registers (X0–X18) from the stack.
// @return — SP incremented by VOLATILE_LENGTH (160 bytes)
.MACRO _POP_VOLATILES
	LDP LR, X0, [SP,0]
	LDP X1, X2, [SP,16]
	LDP X3, X4, [SP,32]
	LDP X5, X6, [SP,48]
	LDP X7, X8, [SP,64]
	LDP X9, X10, [SP,80]
	LDP X11, X12, [SP,96]
	LDP X13, X14, [SP,112]
	LDP X15, X16, [SP,128]
	LDP X17, X18, [SP,144]
	ADD SP, SP, VOLATILE_LENGTH
.ENDM

.ENDIF
