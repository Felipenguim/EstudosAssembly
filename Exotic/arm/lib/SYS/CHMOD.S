.ifndef CHMOD
.EQU CHMOD,1

// TODO: TEST, i don't think this is set up correctly. i think i just copied and pasted unlink.
// needs to be tested

.INCLUDE "SYS/HELPER.S"
.INCLUDE "SYS/LINUX/SYSCALLS.S"

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

.MACRO _chmod
// x1 is the pointer to the filename
	MOV X0, #-100             // AT_FDCWD
    MOV X2, #0755             // mode (mas atenção, isso precisa ser octal)
    MOV X3, #0                // flags
    MOV W8, SYS_CHMOD          // fchmodat
    SVC #0

.ENDM

.endif
