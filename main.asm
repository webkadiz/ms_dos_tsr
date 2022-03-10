org 100h
start:
jmp init


%include "utils.asm"
%include "bio.asm"
%include "italic.asm"


test_message: db 'test', 0dh, 0ah, '$'
log_file_handle: dw 0
log_file_name: db 'log', 0
log_data: times 10 db 0
italic_enables: dw 0


gen_int_catcher 9h
gen_int_catcher 2fh


handle_int2fh:
    cmp ah, 0c2h
    jne .else
.then:
    mov ah, 0
    iret
.else:
    jmp far [cs:int2fh]


handle_int9h:
    push ds
    push cs
    pop ds
    pusha

    in al, 60h

    cmp al, 0beh
    push .endif
    je handle_F4
    pop dx
    cmp al, 0bfh
    push .endif
    je handle_F5
    pop dx
    cmp al, 0c1h
    push .endif
    je handle_F7
    pop dx

.endif:
    popa
    pop ds
    jmp far [cs:int9h]


handle_F4:
    call print_bio
    ret


handle_F5:
    cmp word [italic_enables], 0
    jne .else
.then:
    inc word [italic_enables]
    call enable_italic_M
    jmp .endif
.else:
    dec word [italic_enables]
    call disable_italic_M
.endif:
    ret


handle_F7:

init:
    mov ah, 0c2h
    int 2fh
    cmp ah, 0
    je tsr_loaded

    call store_int2fh
    call set_int2fh
    call store_int9h
    call set_int9h

    push init
    push start
    call make_resident

tsr_loaded:
exit:
    int 20h
