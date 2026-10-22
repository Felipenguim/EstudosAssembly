.IFNDEF DELETE
.EQU DELETE,1

///////////////////////////////////////////////////////////////////////////////

// int _delete_file(int dirfd, char* path, int flags)
// Deletes the file at {path} relative to {dirfd}.
// Use AT_FDCWD (-100) in {dirfd} to resolve relative to current directory.
// {flags}: 0 for files, AT_REMOVEDIR (0x200) for directories.
// @param dirfd X0 — directory file descriptor (-100 for current working directory)
// @param path X1 — pointer to null-terminated string
// @param flags X2 — 0 for files, AT_REMOVEDIR (0x200) for directories
// @return X0 — 0 on success, negative errno on failure
.MACRO _delete_file

    cmp x2, #0x200
    b.eq .del

    mov x2, #0

.del:
	mov x8, #35
	SVC #0

.ENDM

.ENDIF

