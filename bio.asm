%ifdef debug
org 100h
jmp start
%endif

%include "utils.asm"

bio: db "Ткаченко Владислав Львович, группа ИУ5-42Б, вариант 15", 0xd, 0xa
bioLength: equ $-bio

printBio:
    call getRowsCount
    push word 0
    push ax
    call setCursorPosition
    add sp, 4
    mov cx, bioLength
.loop:
    mov si, bioLength
    sub si, cx
    mov ah, 0eh
    mov al, [bio + si]
    int 10h
    loop .loop
    ret

%ifdef debug
start:
call printBio
int 20h
%endif
