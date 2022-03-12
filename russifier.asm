; }SM">Z -> ЪЫЬЭЮЯ
; 125 83 77 34 62 90 -> 154 155 156 157 158 159
americaKeycodes: db 125, 83, 77, 34, 62, 90, 0
rusKeycodesBase: equ 154


russify_char:
    push si
    push dx
    cmp word [russifier_enabled], 0
    je .kb_layout_loop_end
    mov si, -1
.kb_layout_loop_start:
    inc si
    cmp byte [americaKeycodes + si], 0
    je .kb_layout_loop_end
    cmp [americaKeycodes + si], al
    jne .kb_layout_loop_start
    mov al, rusKeycodesBase
    mov dx, si
    add al, dl
.kb_layout_loop_end:
    pop dx
    pop si
    ret
