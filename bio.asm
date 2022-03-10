%ifdef debug
org 100h
jmp start
%endif

%include "utils.asm"


bio: db 0xd, 0xa, "Ткаченко Владислав Львович, группа ИУ5-42Б, вариант 15"
bio_length: equ $-bio


print_bio:
    call get_rows_count
    push word 0
    push ax
    call set_cursor_position
    mov cx, bio_length
.loop:
    mov si, bio_length
    sub si, cx
    mov ah, 0eh
    mov al, [bio + si]
    int 10h
    loop .loop
    ret


%ifdef debug
start:
call print_bio
int 20h
%endif

