org 100h
start:
jmp init

%include "utils.asm"
%include "bio.asm"


message: db 'hello', 0dh, 0ah, '$'
f3: db 'f3 pressed', 0dh, 0ah, '$'
end: db 'end', '$'
log_file_handle: dw 0
log_file_name: db 'log', 0
log_data: times 10 db 0
scan: db 0


genIntCatcher 9h


handleInt9h:
    push ds
    push cs
    pop ds

    pusha

    in al, 60h

    cmp al, 0beh
    push handleInt9hEnd
    je handleF3
    pop dx
    ; cmp al, 0beh
    ; je handleF4
    ; cmp al, 0bfh
    ; je handleF5
    ; cmp al, 0c0h
    ; je handleF6
    ; cmp al, 0c1h
    ; je handleF7
    ; mov word [log_data], 40h
    ; push 10
    ; push log_data
    ; push log_file_name
    ; call owc_file

handleInt9hEnd:

    popa
    pop ds

    jmp far [cs:int9h]


handleF3:
    ; call restoreInt9h
    call print_bio
    ret


init:
    mov dx, (init-start+256+15) >> 4
    call storeInt9h
    call setInt9h

    push init
    push start
    call make_resident


exit:
; завершаем программу
    int 0x20
