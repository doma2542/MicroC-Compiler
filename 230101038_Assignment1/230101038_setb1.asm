section .data
    msg_n   db "Enter number of vertices: ",0
    msg_m   db "Enter adjacency matrix:",10,0
    yes     db "Cycle present",10,0
    no      db "No cycle",10,0
    fmt     db "%d",0

section .bss
    n       resd 1
    adj     resd 100
    visited resd 10
    parent  resd 10
    stack   resd 10
    top     resd 1
    cycle   resd 1

section .text
    global main
    extern printf, scanf

main:
    ; input n
    push msg_n
    call printf
    add esp,4

    push n
    push fmt
    call scanf
    add esp,8

    ; input matrix
    push msg_m
    call printf
    add esp,4

    mov esi,0
read_i:
    mov edi,0
read_j:
    mov eax,esi
    imul eax,[n]
    add eax,edi
    shl eax,2
    lea ebx,[adj+eax]
    push ebx
    push fmt
    call scanf
    add esp,8
    inc edi
    cmp edi,[n]
    jl read_j
    inc esi
    cmp esi,[n]
    jl read_i

    ; init
    mov ecx,0
init:
    mov dword [visited+ecx*4],0
    mov dword [parent+ecx*4],-1
    inc ecx
    cmp ecx,[n]
    jl init

    mov dword [top],1 ;top stores number of vertices in stack
    mov dword [stack],0 ; stack array
    mov dword [visited],1
    mov dword [cycle],0

dfs:
    cmp dword [top],0
    je finish

    dec dword [top]
    mov ecx,[top]
    mov eax,[stack+ecx*4]   ; u

    mov ebx,0               ; v = 0 // start with v=0 and go till n
adj_loop:
    mov edx,eax
    imul edx,[n]
    add edx,ebx
    shl edx,2 ; ex stores req index*4 in array
    mov edx,[adj+edx]

    cmp edx,1
    jne next_v

    cmp dword [visited+ebx*4],0 
    jne check_parent

    mov dword [visited+ebx*4],1
    mov [parent+ebx*4],eax

    mov edx,[top]
    mov [stack+edx*4],ebx
    inc dword [top]
    jmp next_v

check_parent:
    cmp ebx,[parent+eax*4]
    je next_v
    mov dword [cycle],1
    jmp finish

next_v:
    inc ebx
    cmp ebx,[n]
    jl adj_loop
    jmp dfs

finish:
    cmp dword [cycle],1
    je print_yes
    push no
    call printf
    add esp,4
    jmp exit

print_yes:
    push yes
    call printf
    add esp,4

exit:
    mov eax,0
    ret
