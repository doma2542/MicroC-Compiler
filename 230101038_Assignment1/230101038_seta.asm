section .data
    p1 db "Enter first number: ", 0
    p2 db "Enter second number: ", 0
    p3 db "Press 1:Add  2:Sub  3:Mul  4:Div : ", 0
    p4 db "Result = %f", 10, 0

    varf db "%f", 0
    vari   db "%d", 0

section .bss
    a       resd 1      ; float a
    b       resd 1      ; float b
    choice  resd 1      ; int choice
    result  resq 1      ; DOUBLE (8 bytes) 

section .text
    global main
    extern printf
    extern scanf

main:

; Input first number 
    push p1
    call printf
    add esp, 4

    push a
    push varf
    call scanf
    add esp, 8

;  Input second number 
    push p2
    call printf
    add esp, 4

    push b
    push varf
    call scanf
    add esp, 8

; Input choice 
    push p3
    call printf
    add esp, 4

    push choice
    push vari
    call scanf
    add esp, 8

; Load floats into FPU 
    fld dword [a]      ; ST0 = a
    fld dword [b]      ; ST0 = b, ST1 = a

    mov eax, [choice]

    cmp eax, 1
    je ADD

    cmp eax, 2
    je SUB

    cmp eax, 3
    je MUL

    cmp eax, 4
    je DIV

    jmp END

ADD:
    faddp st1, st0     ; a + b
    jmp STORE

SUB:
    fsubp st1, st0     ; a - b
    jmp STORE

MUL:
    fmulp st1, st0     ; a * b
    jmp STORE

DIV:
    fdivp st1, st0     ; a / b
    jmp STORE

STORE:
    fstp qword [result]   ; store DOUBLE

; Print result (DOUBLE for %f)
    sub esp, 8              ; make space for double
    fld qword [result]
    fstp qword [esp]        ; push double argument
    push p4               ; push format string
    call printf
    add esp, 12             ; 8 (double) + 4 (format)

END:
    mov eax, 0              ; return 0
    ret
