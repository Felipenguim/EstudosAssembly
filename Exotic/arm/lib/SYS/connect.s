.IFNDEF CONNECT
.EQU CONNECT,1

///////////////////////////////////////////////////////////////////////////////


// int _connect(int sockfd, const struct sockaddr_in *addr, socklen_t addrlen)
// connects the socket referred to by the
// file descriptor sockfd to the address specified by addr.  The
// addrlen argument specifies the size of addr.
// @param sockfd x0 — fd of socket
// @param *addr X1 — pointer to the sctruct of sockaddr_in
// @param addrlen X2 — len of addr
// @return x0 — 0 if ok, <0 if error
.MACRO _connect

	mov x8, #203
	SVC #0

.ENDM

.ENDIF
