org 100h
start:
jmp init


%include "utils.asm"
%include "strings866.asm"
%include "bio.asm"
%include "italic.asm"
%include "russifier.asm"
%include "uppercase_locker.asm"
%include "hex_mode.asm"
%include "event_loop.asm"


log_file_handle: dw 0
log_file_name: db 'log', 0
log_data: times 10 db 0
italic_enabled: dw 0
russifier_enabled: dw 0
uppercase_locker_enabled: dw 0
hex_mode_enabled: dw 0


gen_int_catcher 8h
gen_int_catcher 9h
gen_int_catcher 16h
gen_int_catcher 2fh


handle_int2fh:
    cmp ah, 0c2h
    jne .next
    mov ah, 0
    iret
.next:
    cmp ah, 0c3h
    jne .end
    push cs
    pop es
    iret
.end:
    jmp far [cs:int2fh]


handle_int8h:
    push ds
    push cs
    pop ds
    push bx
    ; bx - current event loop item address
    mov bx, [event_loop_head]
.event_loop_start:
    cmp bx, word 0
    je .event_loop_end
    cmp [bx+event_loop_item.timeout], word 0
    jle .call_callback

    sub [bx+event_loop_item.timeout], word 55
    jmp .event_loop_next_iter
.call_callback:
    pusha
    call [bx+event_loop_item.callback]
    popa
    call delete_event_loop_item
    mov bx, [event_loop_head]
    jmp .event_loop_start
.event_loop_next_iter:
    mov bx, [bx+event_loop_item.next]
    jmp .event_loop_start
.event_loop_end:
    pop bx
    pop ds
    jmp far [cs:int8h]


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
    cmp al, 0c2h
    push .endif
    je handle_F8
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
    call uppercase_lock
    call hex_char

.process_end:
    pop ds
    iret
.skip:
    jmp far [cs:int16h]


handle_F4:
    mov ax, print_bio
    mov dx, 7000
    call create_event_loop_item
    call push_back_event_loop_item
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
    cmp word [uppercase_locker_enabled], 0
    jne .else
.then:
    inc word [uppercase_locker_enabled]
    jmp .endif
.else:
    dec word [uppercase_locker_enabled]
.endif:
    ret


handle_F8:
    cmp word [hex_mode_enabled], 0
    jne .else
.then:
    inc word [hex_mode_enabled]
    jmp .endif
.else:
    dec word [hex_mode_enabled]
.endif:
    ret


init:
    call process_help
    ; exit if help is printed
    cmp ax, 0
    je exit

    call get_psp
    ; parameter list not empty
    cmp [es:80h], byte 0
    jne clp_error

    ; check if tsr already loaded
    mov ah, 0c2h
    int 2fh
    cmp ah, 0
    je tsr_unload

    call store_int8h
    call set_int8h
    call store_int9h
    call set_int9h
    call store_int16h
    call set_int16h
    call store_int2fh
    call set_int2fh

    call init_event_loop

    call unload_env
    mov dx, resident_load_msg
    call print_msg
    push init
    push start
    call make_resident
    mov dx, resident_load_msg
    call print_msg

tsr_unload:
    ; get es of tsr program
    mov ah, 0c3h
    int 2fh
    call restore_int8h
    call restore_int9h
    call restore_int16h
    call restore_int2fh
    mov dx, ints_unload_msg
    call print_msg
    mov ah, 49h
    int 21h
    jc tsr_unload_fail
    mov dx, resident_unload_success_msg
    call print_msg
    jmp exit
tsr_unload_fail:
    mov dx, resident_unload_fail_msg
    call print_msg

clp_error:
    mov dx, clp_error_msg
    call print_msg
    jmp exit

exit:
    int 20h
