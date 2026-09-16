.IFNDEF SOCKET
.EQU SOCKET,1

///////////////////////////////////////////////////////////////////////////////


// int _socket(int domain, int type, int protocol)
// creates an endpoint for communication and returns a file descriptor that refers to that endpoint.
// @param domain x0 — argument specifies a communication domain; this selects the protocol family which will be used for communication
// @param type X1 — specifies the communication semantics
// @param protocol X2 — specifies a particular protocol to be used with the socket
// @return x0 — fd
.MACRO _socket

	mov x8, #198
	SVC #0

.ENDM

.ENDIF
