org 100h

start:

%include "utils.asm"

jmp init

message: db 'hello', 0dh, 0ah, '$'
f3: db 'f3 pressed', 0dh, 0ah, '$'
end: db 'end', '$'
filehandle: dw 0
filename: db 'log', 0
logData: times 10 db 0
cseg: dw 0

genIntCatcher 9h

handleInt9h:
    mov cx, cs
    mov ds, cx
    mov cx, 0040h
    mov es, cx

    mov ah, 3dh
    mov al, 1
    mov dx, filename
    int 21h

    mov [filehandle], ax
    mov ah, 40h
    mov bx, [filehandle] 
    mov cx, 10
    mov dx, es:001eh
    int 21h

    mov ah, 3eh
    mov bx, [filehandle]
    int 21h

    mov ah, 0x9
    mov dx, message
    int 0x21 
    ; in al, 60h
    ; out 60h, al
    jmp far [int9h]
    pushf
    iret
    mov ah, 0
    int 16h
    cmp al, 0
    jne end16
    cmp ah, 61
    je handleF3
end16:
    mov ah, 0x9
    mov dx, end
    int 0x21 
    iret

size equ init-start
init:
    cli
    mov [cseg], ds
    mov ax, size
    call storeInt9h
    call setInt9h


    mov [logData], ds
    mov [logData + 2], word message

    mov ah, 40h
    mov bx, [filehandle] 
    mov cx, 10
    mov dx, logData
    int 21h

    mov ah, 3eh
    mov bx, [filehandle]
    int 21h

    mov ah, 1
    int 16h
    mov ah, 0
    int 16h
    mov ah, 0
    int 16h

    mov al, 60
    out 61h, al
    out 61h, al

    ; call restoreInt9h
    mov ah, 31h
    mov al, 0
    mov dx, (init-start+256+15) >> 4
    sti
    int 21h

    call exit

handleF3:
    mov ah, 0x9
    mov dx, f3
    int 0x21 
    jmp end16

exit:
; завершаем программу
    int 0x20 
