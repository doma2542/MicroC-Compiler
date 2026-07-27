section .data
    filename    db "input.txt", 0
    mode        db "r", 0

    fmt_min     db "Smallest word: %s Length: %d", 10, 0
    fmt_max     db "Largest word: %s Length: %d", 10, 0

    delimiters  db " ", 10, 9, 0   ; space, newline, tab

section .bss
    file        resd 1
    buffer      resb 1024

    curr_word   resb 128      ; FIXED NAME
    min_word    resb 128
    max_word    resb 128

    min_len     resd 1
    max_len     resd 1

section .text
    global main

    extern fopen
    extern fgets
    extern fclose
    extern printf
    extern strlen
    extern strtok

main:
    push ebp
    mov ebp, esp

    ; file = fopen("input.txt", "r")
    push mode
    push filename
    call fopen
    add esp, 8
    mov [file], eax
    test eax, eax
    jz end_program

    mov dword [min_len], 0x7FFFFFFF
    mov dword [max_len], 0

read_loop:
    ; fgets(buffer, 1024, file)
    push dword [file]
    push 1024
    push buffer
    call fgets
    add esp, 12
    test eax, eax
    jz close_file

    ; token = strtok(buffer, delimiters)
    push delimiters
    push buffer
    call strtok
    add esp, 8
    mov esi, eax

token_loop:
    test esi, esi
    jz read_loop

    ; len = strlen(token)
    push esi
    call strlen
    add esp, 4
    mov ecx, eax
    ; ecx : length of the current word

    ; esi : address of the current word 
    
    ; check min
    mov eax, [min_len]
    cmp ecx, eax
    jge check_max
    mov [min_len], ecx
    mov edi, min_word
    mov edx, ecx
    rep movsb
    mov byte [edi], 0

check_max:
    mov eax, [max_len]
    cmp ecx, eax
    jle next_token
    mov [max_len], ecx
    mov edi, max_word
    mov edx, ecx
    rep movsb
    mov byte [edi], 0

next_token:
    ; strtok(NULL, delimiters)
    push delimiters
    push 0
    call strtok
    add esp, 8
    mov esi, eax
    jmp token_loop

close_file:
    push dword [file]
    call fclose
    add esp, 4

    ; print smallest
    push dword [min_len]
    push min_word
    push fmt_min
    call printf
    add esp, 12

    ; print largest
    push dword [max_len]
    push max_word
    push fmt_max
    call printf
    add esp, 12

end_program:
    mov esp, ebp
    pop ebp
    xor eax, eax
    ret
