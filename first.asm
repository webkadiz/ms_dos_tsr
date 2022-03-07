org 100h

section .data

bt: db 't'
saveEsInt16: dw 0
saveBxInt16: dw 0
int16: dw 0, 0
message: db 'hello', 0dh, 0ah, '$'
f3: db 'f3 pressed', 0dh, 0ah, '$'

section .text

jmp start

handleInt16:
    pushf
    call far [int16]
    cmp al, 0
    jne end16
    cmp ah, 61
    je handleF3
end16:
    mov ah, 0x9
    mov dx, message
    int 0x21 
    iret

start:
    call storeInt16
    call setInt16

    mov ah, 0x0
    int 0x16

    call restoreInt16
    call exit

storeInt16:
; получаем адрес прерывания 16h
    mov ah, 0x35
    mov al, 0x16
    int 21h
; сохраняем адрес оригинального прерывания
    mov [int16], bx
    mov [int16 + 2], es
    ret

setInt16:
    mov ah, 0x25
    mov al, 0x16
    mov dx, handleInt16
    int 0x21 
    ret

restoreInt16:
    mov ah, 0x25
    mov al, 0x16
; сохраняем ds
    mov cx, ds
    mov es, cx 
; база адреса прерывания
    mov cx, es:[int16 + 2]
    mov ds, cx 
; смещение адреса прерывания
    mov dx, es:[int16] 
; возвращаем оригинальный адрес прерывания 16h
    int 0x21
; возвращаем ds
    mov cx, es
    mov ds, cx 
    ret

handleF3:
    mov ah, 0x9
    mov dx, f3
    int 0x21 
    jmp end16

exit:
; завершаем программу
    int 0x20 

section .bss

c: db 100 dup (?)

