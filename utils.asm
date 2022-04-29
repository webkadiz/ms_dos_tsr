%ifndef utils
%define utils


sword: equ 2

%macro gen_int_catcher 1

int%1: dd 0


store_int%1:
; получаем адрес прерывания
    mov ah, 35h
    mov al, %1
    int 21h
; сохраняем адрес оригинального прерывания
    mov [int%1], bx
    mov [int%1 + 2], es
    ret


set_int%1:
    mov ah, 25h
    mov al, %1
    mov dx, handle_int%1
    int 21h
    ret


restore_int%1:
    mov ah, 25h
    mov al, %1
    push ds
    push cx
; база адреса прерывания
    mov cx, es:[int%1 + 2]
    mov ds, cx 
; смещение адреса прерывания
    mov dx, es:[int%1] 
; возвращаем оригинальный адрес прерывания
    int 21h
    pop cx
    pop ds
    ret

%endmacro


get_rows_count:
    mov ax, 1130h
    mov bh, 0
    int 10h
    mov al, dl
    mov ah, 0
    ret


get_columns_count:
    mov ah, 0fh
    int 10h
    mov al, ah
    mov ah, 0
    ret


; [bp+4] first param  - row number
; [bp+6] second param - column number
set_cursor_position:
    push bp
    mov bp, sp
    mov ah, 02h
    mov dh, [bp+4]
    mov dl, [bp+6]
    int 10h
    pop bp
    ret 4


; [bp+4] first param - address of file name string
open_file:
    push bp
    mov bp, sp
    mov ah, 3dh
    mov al, 2               ; read/write mode
    mov dx, [bp+4]
    int 21h
    pop bp
    ret 2


; [bp+4] first param  - file handle number
; [bp+6] second param - address of data to write
; [bp+8] third param  - count bytes for write
write_file:
    push bp
    mov bp, sp
    mov ah, 40h
    mov bx, [bp+4]
    mov cx, [bp+8]
    mov dx, [bp+6]
    int 21h
    pop bp
    ret 6


; [bp+4] first param - file handle number
close_file:
    push bp
    mov bp, sp
    mov ah, 3eh
    mov bx, [bp+4]
    int 21h
    pop bp
    ret 2


; [bp+4] first param  - address of file name string
; [bp+6] second param - address of data to write
; [bp+8] third param  - count bytes for write
owc_file:
    push bp
    mov bp, sp
    push word [bp+4]
    call open_file
    push ax
    push word [bp+8]
    push word [bp+6]
    push ax
    call write_file
    call close_file
    pop bp
    ret 6


; [bp+4] first param  - start address
; [bp+6] second param - init address
make_resident:
    push bp
    mov bp, sp
    mov dx, [bp+6]
    sub dx, [bp+4]
    add dx, 256
    add dx, 15
    shr dx, 4
    mov ah, 31h
    mov al, 0
    int 21h
    pop bp
    ret 4


; work with integers less then 2560
; [bp+4] first param  - int
; [bp+6] second param - string address
suint_to_str:
    push bp
    mov bp, sp
    pusha
    mov si, [bp+6]

    mov ax, [bp+4]
    mov dl, 10
.loop:
    div dl
    mov [si], ah
    add [si], byte 48
    inc si
    mov ah, 0
    cmp al, 0
    je .endloop
    jmp .loop
.endloop:
    push si
    mov di, [bp+6]

    mov cx, si
    sub cx, [bp+6]
    dec si
    mov ax, cx
    mov bl, 2
    div bl
    mov cl, al
    cmp cl, 0
    je .end
.reverse:
    mov al, [di]
    mov dl, [si]
    mov [si], al
    mov [di], dl
    inc di
    dec si
    loop .reverse
.end:
    pop si
    mov byte [si], '$'
    popa
    pop bp
    ret 4


; dx first param - message
print_msg:
    push ax
    mov ah, 09h
    int 21h
    pop ax
    ret


; es return value - psp address
get_psp:
    push bx
    mov ah, 51h
    int 21h
    mov es, bx
    pop bx
    ret


unload_env:
    call get_psp
    ; [psp:002ch] - address DOS environment
    mov es, [es:002ch]
    mov ah, 49h
    int 21h
    jnc .env_free
    mov dx, env_unload_fail_msg
    call print_msg
    jmp .end
.env_free:
    mov dx, env_unload_success_msg
    call print_msg
.end:
    ret


; ax - return value - 1 means help skiped, 0 means help printed
process_help:
    pusha
    call get_psp
    mov si, 81h
.spaces_skip_start:
    cmp [es:si], byte ' '
    jne .spaces_skip_end
    inc si
    jmp .spaces_skip_start
.spaces_skip_end:
    cmp [es:si], byte '/'
    jne .help_skip
    inc si
    cmp [es:si], byte '?'
    jne .help_skip
    mov dx, help_msg
    call print_msg
    popa
    mov ax, 0
    ret
.help_skip:
    popa
    mov ax, 1
    ret


%endif
