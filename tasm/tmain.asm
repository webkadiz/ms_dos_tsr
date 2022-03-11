.386
code segment
assume cs:code
org 100h
start:
jmp init


include tutils.asm
include tbio.asm
include titalic.asm


test_message: db 'test', 0dh, 0ah, '$'
log_file_handle: dw 0
log_file_name: db 'log', 0
log_data: db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
italic_enables: dw 0


gen_int_catcher 9h
gen_int_catcher 2fh


handle_int2fh:
    cmp ah, 0c2h
    jne .else_2fh
.then_2fh:
    mov ah, 0
    iret
.else_2fh:
    jmp far [cs:int2fh]


handle_int9h:
    push ds
    push cs
    pop ds
    pusha

    in al, 60h

    cmp al, 0beh
    push word ptr .endif_9h
    je handle_F4
    pop dx
    cmp al, 0bfh
    push word ptr .endif_9h
    je handle_F5
    pop dx
    cmp al, 0c1h
    push word ptr .endif_9h
    je handle_F7
    pop dx

.endif_9h:
    popa
    pop ds
    jmp far [cs:int9h]


handle_F4:
    call print_bio
    ret


handle_F5:
    cmp word ptr [italic_enables], 0
    jne .else_F5
.then_F5:
    inc word ptr [italic_enables]
    call enable_italic_M
    jmp .endif_F5
.else_F5:
    dec word ptr [italic_enables]
    call disable_italic_M
.endif_F5:
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

    push word ptr init
    push word ptr start
    call make_resident

tsr_loaded:
exit:
    int 20h

code ends
end start
