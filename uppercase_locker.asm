rus_upper_keycodes_start: equ 128
rus_upper_keycodes_end: equ 159
rus_edotdot_keycode: equ 240

uppercase_lock:
    cmp word [uppercase_locker_enabled], 0
    je .skip
    cmp al, rus_upper_keycodes_start
    jl .skip
    cmp al, rus_edotdot_keycode
    je .skip
    cmp al, rus_upper_keycodes_end
    jg .skip
    mov al, 0
    mov ah, 1
.skip:
    ret
