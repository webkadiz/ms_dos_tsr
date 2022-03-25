org 100h
jmp start

%include 'tests/test_env.asm'
%include 'utils.asm'

num: times 10 db 0

start:
    push num
    push 256
    call suint_to_str

    init

    cmp byte [num], 50
    test
    cmp byte [num+1], 53
    test
    cmp byte [num+2], 54
    test

    pass
    fail
end:
    ret
