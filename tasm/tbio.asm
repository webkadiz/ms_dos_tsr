bio: db 0dh, 0ah, "���祭�� �����᫠� �좮���, ��㯯� ��5-42�, ��ਠ�� 15"
bio_length: dw 52


print_bio:
    call get_rows_count
    push word 0
    push ax
    call set_cursor_position
    mov cx, word ptr [bio_length]
.loop:
    mov si, word ptr [bio_length]
    sub si, cx
    mov ah, 0eh
    mov al, byte ptr [bio + si]
    int 10h
    loop .loop
    ret
