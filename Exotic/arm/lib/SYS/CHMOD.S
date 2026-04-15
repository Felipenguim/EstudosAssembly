.ifndef CHMOD
.EQU CHMOD,1

// TODO: TEST, i don't think this is set up correctly. i think i just copied and pasted unlink.
// needs to be tested

.INCLUDE "SYS/HELPER.S"
.INCLUDE "SYS/LINUX/SYSCALLS.S"

///////////////////////////////////////////////////////////////////////////////

// int _chmod(char* path)
// Changes the permissions of the file at {path} to 0755 using fchmodat with AT_FDCWD.
// Note: mode is hardcoded to 0755. Currently unverified — may not be set up correctly.
// @param path X1 — pointer to null-terminated filename string
// @return X0 — 0 on success, negative errno on failure
.MACRO _chmod
	MOV X0, #-100             // AT_FDCWD
    MOV X2, #0755             // mode (mas atenção, isso precisa ser octal)
    MOV X3, #0                // flags
    MOV W8, SYS_CHMOD          // fchmodat
    SVC #0

.ENDM

.endif
