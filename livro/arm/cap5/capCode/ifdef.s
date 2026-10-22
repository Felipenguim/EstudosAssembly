//%define flag

//%ifdef flag
//hellostring: db "Hello", 0
//%endif

.ifdef flag
hellostring:
    .asciz "Hello"
.endif