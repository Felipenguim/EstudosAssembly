.IFNDEF DELETE
.EQU DELETE,1

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

.MACRO _delete_file
// int _delete_file(int dirfd, char* path, int flags = 0);
//   Deletes the file at {path} relative to {dirfd}.
//   Use AT_FDCWD (-100) in {dirfd} to resolve relative to current directory.
//   {flags}: 0 for files, AT_REMOVEDIR (0x200) for directories.
//   Returns 0 on success, negative errno on failure.
//
//   X0 = dirfd
//   X1 = path
//   X2 = flags

    cmp x2, #0x200
    b.eq .del
    
    mov x2, #0

.del:
	mov x8, #35
	SVC #0

	
.ENDM

.ENDIF

