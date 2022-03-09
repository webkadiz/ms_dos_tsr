%ifdef debug
org 100h
%endif

%include "utils.asm"

section .data

bio: db "���祭�� �����᫠� �좮���, ��5-42�, ��ਠ�� 15", 0xd, 0xa
bioLength: equ $-bio

section .text

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
call printBio
int 20h
%endif
