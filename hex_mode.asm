dig_table: db '0123456789abcdef'
number: db 0, 0

hex_char:
    cmp word [hex_mode_enabled], 0
    je .end
    push dx
    push bx
    push ax
    push si
    mov si, 0
    mov ah, 0
.hex_loop:
    cmp al, 0
    je .hex_loop_end

    mov bl, 16
    div bl

    push ax

    mov al, ah
    mov bx, dig_table
    xlat
    mov [number+si], al
    inc si

    pop ax

    mov ah, 0
    jmp .hex_loop
.hex_loop_end:
    mov dl, ' '
    call putch
    mov dl, "'"
    call putch
    mov dl, [number+1]
    call putch
    mov dl, [number]
    call putch
    mov dl, 'h'
    call putch
    mov dl, "'"
    call putch
    mov dl, ' '
    call putch

    pop si
    pop ax
    pop bx
    pop dx
.end:
    ret
