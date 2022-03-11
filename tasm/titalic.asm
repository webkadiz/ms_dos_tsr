rus_M_code equ 140

regular_M:
db 00000000b 
db 00000000b 
db 00000000b 
db 11100111b 
db 11111111b 
db 11011011b 
db 11000011b 
db 11000011b 
db 11000011b 
db 11000011b 
db 11000011b 
db 11000011b 
db 11000011b 
db 00000000b 
db 00000000b 
db 00000000b 

italic_M:
db 00000000b
db 00000000b
db 00000000b
db 00100010b
db 01100110b
db 01111110b
db 01101010b
db 01100011b
db 01000010b
db 01000110b
db 11000110b
db 11000110b
db 10000100b
db 00000000b
db 00000000b
db 00000000b


enable_italic_M:
    push bp
    push ds
    pop es
    mov bp, word ptr italic_M
    mov ax, 1100h
    mov bh, 16
    mov bl, 0
    mov cx, 1
    mov dx, rus_M_code
    int 10h
    pop bp
    ret


disable_italic_M:
    push bp
    push ds
    pop es
    mov bp, word ptr regular_M
    mov ax, 1100h
    mov bh, 16
    mov bl, 0
    mov cx, 1
    mov dx, rus_M_code
    int 10h
    pop bp
    ret
