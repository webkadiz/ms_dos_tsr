assume cs:code

gen_int_catcher macro int_name 

int&int_name: dd 0


store_int&int_name:
; получаем адрес прерывания
    mov ah, 35h
    mov al, int_name
    int 21h
; сохраняем адрес оригинального прерывания
    mov word ptr [int&int_name], bx
    mov word ptr [int&int_name + 2], es
    ret


set_int&int_name:
    mov ah, 25h
    mov al, int_name
    mov dx, offset handle_int&int_name
    int 21h
    ret


restore_int&int_name:
    mov ah, 25h
    mov al, int_name
; сохраняем ds
    mov cx, ds
    mov es, cx 
; база адреса прерывания
    mov cx, word ptr es:[int&int_name + 2]
    mov ds, cx 
; смещение адреса прерывания
    mov dx, word ptr es:[int&int_name] 
; возвращаем оригинальный адрес прерывания
    int 21h
; возвращаем ds
    mov cx, es
    mov ds, cx 
    ret

endm


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
    push word ptr [bp+4]
    call open_file
    push ax
    push word ptr [bp+8]
    push word ptr [bp+6]
    push ax
    call write_file
    call close_file
    pop bp
    ret 6


; [bp-4] first param  - start address
; [bp-6] second param - init address
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
