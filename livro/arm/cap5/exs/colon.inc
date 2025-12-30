.set __last_entry_sym, 0

.macro colon key:req, name:req
    .align 3
\name:
    .quad __last_entry_sym
    .asciz "\key"
    .set __last_entry_sym, \name
.endm
