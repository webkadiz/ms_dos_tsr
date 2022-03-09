%ifndef utils
%define utils

jmp skipUtils

%macro genIntCatcher 1

int%1: dd 0

storeInt%1:
; получаем адрес прерывания
    mov ah, 35h
    mov al, %1
    int 21h
; сохраняем адрес оригинального прерывания
    mov [int%1], bx
    mov [int%1 + 2], es
    ret

setInt%1:
    mov ah, 25h
    mov al, %1
    mov dx, handleInt%1
    int 21h
    ret

restoreInt%1:
    mov ah, 25h
    mov al, %1
; сохраняем ds
    mov cx, ds
    mov es, cx 
; база адреса прерывания
    mov cx, es:[int%1 + 2]
    mov ds, cx 
; смещение адреса прерывания
    mov dx, es:[int%1] 
; возвращаем оригинальный адрес прерывания
    int 21h
; возвращаем ds
    mov cx, es
    mov ds, cx 
    ret

%endmacro

getRowsCount:
    mov ax, 1130h
    mov bh, 0
    int 10h
    mov al, dl
    ret

getColumnsCount:
    mov ah, 0fh
    int 10h
    mov al, ah
    ret

; row, column
setCursorPosition:
    push bp
    mov bp, sp
    mov ah, 02h
    mov dh, [bp+4]
    mov dl, [bp+6]
    int 10h
    pop bp
    ret

%endif

skipUtils: