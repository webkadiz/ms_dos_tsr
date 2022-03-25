success_msg: db 'success', 13, 10, '$'
fail_msg: db 'fail', 32, '$'
fail_test: db 0, 0, 0, 0

%macro init 0
    mov cx, 1
%endmacro

%macro test 0
    jne failed
    inc cx
%endmacro

%macro pass 0
passed:
    mov dx, success_msg
    mov ah, 9h
    int 21h
    jmp end
%endmacro

%macro fail 0
failed:
    mov dx, fail_msg
    mov ah, 9h
    int 21h

    push fail_test
    push cx
    call suint_to_str

    mov dx, fail_test
    mov ah, 9h
    int 21h

    mov dl, 13
    mov ah, 2h
    int 21h
    mov dl, 10
    mov ah, 2h
    int 21h
%endmacro
