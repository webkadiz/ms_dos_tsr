org 100h
start:
jmp init


%include "utils.asm"
%include "bio.asm"
%include "italic.asm"
%include "russifier.asm"


test_message: db 'test', 0dh, 0ah, '$'
log_file_handle: dw 0
log_file_name: db 'log', 0
log_data: times 10 db 0
italic_enabled: dw 0
russifier_enabled: dw 0


gen_int_catcher 9h
gen_int_catcher 2fh
gen_int_catcher 16h


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
    cmp al, 0c0h
    push .endif
    je handle_F6
    pop dx
    cmp al, 0c1h
    push .endif
    je handle_F7
    pop dx
.endif:
    popa
    pop ds
    jmp far [cs:int9h]


handle_int16h:
    cmp ah, 01h
    je .process
    cmp ah, 00h
    je .process
    cmp ah, 10h
    je .process
    cmp ah, 11h
    je .process
    jmp .skip
.process:
    push ds
    push cs
    pop ds

    pushf
    call far [cs:int16h]

    cmp al, 0
    je .process_end

    call russify_char

.process_end:
    pop ds
    iret
.skip:
    jmp far [cs:int16h]


handle_F4:
    call print_bio
    ret


handle_F5:
    cmp word [italic_enabled], 0
    jne .else
.then:
    inc word [italic_enabled]
    call enable_italic_M
    jmp .endif
.else:
    dec word [italic_enabled]
    call disable_italic_M
.endif:
    ret


handle_F6:
    cmp word [russifier_enabled], 0
    jne .else
.then:
    inc word [russifier_enabled]
    jmp .endif
.else:
    dec word [russifier_enabled]
.endif:
    ret


handle_F7:
    ret

init:
    mov ah, 0c2h
    int 2fh
    cmp ah, 0
    je tsr_loaded

    call store_int2fh
    call set_int2fh
    call store_int9h
    call set_int9h
    call store_int16h
    call set_int16h

    push init
    push start
    call make_resident

tsr_loaded:
exit:
    int 20h
