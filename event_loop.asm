%ifndef event_count
%define event_count 20
%endif

; size 8 bytes
struc event_loop_item
    .callback: resw 1
    .timeout: resw 1
    .prev: resw 1
    .next: resw 1
endstruc

event_loop_list_size: equ event_loop_item_size * event_count
event_loop_head: dw 0
event_loop_tail: dw 0
alloc_ptr: dw 0
dealloc_ptr: dw 0


section .bss


alloc_list: resb event_count * sword
event_loop_list: resb 200 


section .text


; fill alloc_list by event loop item addresses
init_event_loop:
    mov cx, event_count
.loop:
    mov si, event_count
    sub si, cx

    ; dx - event loop item address
    mov dx, event_loop_list
    mov ax, si
    mov bl, event_loop_item_size
    mul bl
    add dx, ax

    ; di - event loop item index in alloc_list
    mov ax, si
    mov bl, sword
    mul bl
    mov di, ax

    mov [alloc_list+di], dx
    loop .loop

    ret


; bx - item address
_alloc_event_loop_item:
    mov si, alloc_list
    add si, [alloc_ptr]

    cmp [si], word 0
    je .out_of_space

    mov bx, [si]
    mov [si], word 0

    add [alloc_ptr], word sword

    cmp [alloc_ptr], word event_count * sword
    jge .tozero
    jmp .end
.tozero:
    mov [alloc_ptr], word 0
    jmp .end
.out_of_space:
    mov bx, 0
.end:
    ret


; bx - item address
_dealloc_event_loop_item:
    mov si, alloc_list
    add si, [dealloc_ptr]
    mov [si], bx

    add [dealloc_ptr], word sword

    cmp [dealloc_ptr], word event_count * sword
    jge .tozero
    jmp .end
.tozero:
    mov [dealloc_ptr], word 0
.end:
    ret


; ax callback - first parameter
; dx timeout  - second parameter
create_event_loop_item:
    call _alloc_event_loop_item
    cmp bx, 0
    je .out_of_space
    mov [bx+event_loop_item.callback], ax
    mov [bx+event_loop_item.timeout], dx
.out_of_space:
    ret


; bx item address - first parameter
push_back_event_loop_item:
    cmp bx, 0
    je .not_item
    cmp [event_loop_tail], word 0
    je .empty_list

; prev to current tail
    mov ax, [event_loop_tail]
    mov [bx+event_loop_item.prev], ax
; next to null
    mov [bx+event_loop_item.next], word 0
; tail to new node
    mov [event_loop_tail], bx
    jmp .end
.empty_list:
; prev and next to null
    mov [bx+event_loop_item.prev], word 0
    mov [bx+event_loop_item.next], word 0
; head and tail to new node
    mov [event_loop_head], bx
    mov [event_loop_tail], bx
.end:
.not_item:
    ret


; bx - item address
delete_event_loop_item:
    pusha
    cmp bx, 0
    je .not_item
    cmp [event_loop_head], bx
    je .delete_head
    cmp [event_loop_tail], bx
    je .delete_tail

    mov si, [bx+event_loop_item.prev]
    mov di, [bx+event_loop_item.next]
    mov [si+event_loop_item.next], di
    mov [di+event_loop_item.prev], si
    jmp .end
.delete_head:
    mov di, [bx+event_loop_item.next]
    mov [event_loop_head], di
    jmp .end
.delete_tail:
    mov si, [bx+event_loop_item.prev]
    mov [event_loop_tail], si
    jmp .end
.end:
    call _dealloc_event_loop_item
.not_item:
    popa
    ret
