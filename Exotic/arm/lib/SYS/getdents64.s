.IFNDEF GETDENTS64
.EQU GETDENTS64,1

///////////////////////////////////////////////////////////////////////////////

// ssize_t _getdents64(int fd, struct linux_dirent64 *dirp, unsigned int count)
// Reads directory entries from an open directory file descriptor into a buffer.
// The kernel fills the buffer with a sequence of variable-length linux_dirent64
// structs packed contiguously. Use d_reclen to advance between entries.
// struct linux_dirent64 (variable size, packed contiguously in buffer):
//   offset  size  field
//   0x00    8     d_ino     — inode number
//   0x08    8     d_off     — offset to next entry (use d_reclen instead)
//   0x10    2     d_reclen  — total size in bytes of THIS entry (use to advance)
//   0x12    1     d_type    — entry type: 4=DT_DIR, 8=DT_REG, 0=DT_UNKNOWN
//   0x13    var   d_name    — null-terminated filename string
//
// d_reclen includes all fields plus d_name plus any alignment padding.
// Never compute entry size manually — always use d_reclen to reach the next entry.
//
// @param x0 — file descriptor of an already-opened directory
// @param path X1 — pointer to the struct where the kernel will write down
// @param flags X2 — x1 buffer size
// @return x0 — number of bytes written into buffer (0 = end of directory, negative = error)
.MACRO _getdents64

	mov x8, #61
	SVC #0

.ENDM

.ENDIF
