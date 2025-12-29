.macro colon key, name
    .align 3
\name:
    .quad last_entry
    last_entry = \name
    .asciz \key
.endm
