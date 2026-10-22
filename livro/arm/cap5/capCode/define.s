//.equ cat_count, 42
.set cat_count, 42

.extern success_exit
.extern print_uint
.global _start

.text
_start:
    mov x0, cat_count

    bl print_uint
    bl success_exit