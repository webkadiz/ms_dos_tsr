org 100h
jmp start

%define event_count 2

%include 'tests/test_env.asm'
%include 'utils.asm'
%include 'event_loop.asm'

callback:
    mov ax, 2

callback2:
    mov ax, 3

start:
    call init_event_loop

    mov ax, callback
    mov dx, 1000
    call create_event_loop_item
    call push_back_event_loop_item

    mov ax, callback2
    mov dx, 2000
    call create_event_loop_item
    call push_back_event_loop_item

    mov ax, callback
    mov dx, 3000
    call create_event_loop_item
    call push_back_event_loop_item

    init

    cmp [alloc_list], word 0
    test
    cmp [alloc_list+2], word 0
    test

    cmp [event_loop_list], word callback
    test
    cmp [event_loop_list+2], word 1000
    test
    cmp [event_loop_list+4], word 0
    test
    cmp [event_loop_list+6], word 0
    test

    cmp [event_loop_list+8], word callback2
    test
    cmp [event_loop_list+10], word 2000
    test
    cmp [event_loop_list+12], word event_loop_list
    test
    cmp [event_loop_list+14], word 0
    test

    cmp [event_loop_head], word event_loop_list
    test
    cmp [event_loop_tail], word event_loop_list+8
    test

    pass
    fail
end:
    ret
