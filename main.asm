org 100h
start:
jmp init

%include "utils.asm"
%include "bio.asm"


test_message: db 'test', 0dh, 0ah, '$'
log_file_handle: dw 0
log_file_name: db 'log', 0
log_data: times 10 db 0


gen_int_catcher 9h


handle_int9h:
    push ds
    push cs
    pop ds
    pusha

    in al, 60h

    cmp al, 0beh
    push .end
    je handle_F4
    pop dx
    ; cmp al, 0bfh
    ; je handleF5
    ; cmp al, 0c0h
    ; je handleF6
    ; cmp al, 0c1h
    ; je handleF7

.end:
    popa
    pop ds
    jmp far [cs:int9h]


handle_F4:
    call print_bio
    ret


init:
    call store_int9h
    call set_int9h

    push init
    push start
    call make_resident


exit:
    int 20h
