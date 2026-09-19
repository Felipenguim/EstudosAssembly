.IFNDEF SOCKADDR_IN_CONSTRUCT
.EQU SOCKADDR_IN_CONSTRUCT, 1


///////////////////////////////////////////////////////////////////////////////

// void {x0} sockaddr_in_construct(*struct sockaddr_in {x0}, short sin_family {x1}, short sin_port {x2}, int sin_addr {x3} )
// Constructing the sockaddr_in struct to use in a connect syscall and start a tcp connection with a server 
// It's mandatory that buffer has 16 bytes with the last 8 filled with zeros 
// @param x0 — pointer to struct
// @param x1 — sin_family #2 //AF_INET
// @param x2 —  sin_port 2 bytes //porta de destino (BIG ENDIAN)
// @param x3 —  sin_addr 4 bytes //ip de destino (BIG ENDIAN)
// @return void, but struct pointed by x0 with the necessary bytes 
sockaddr_in_construct:
    stp x29, x30, [sp, #-16]!
    
    mov x29, sp 

    //transform to big_endian
    rev16 w2, w2
    rev w3, w3 //struct pede big endian
	strh w1, [x0]
	strh w2, [x0, #2]
	str w3, [x0, #4]

  
    mov sp, x29 
    ldp x29, x30, [sp], #16
    ret

.ENDIF


