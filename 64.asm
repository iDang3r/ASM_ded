; /usr/local/bin/nasm -f elf64 64.asm && ld -macosx_version_min 10.7.0 -lSystem -o 64 64.o && ./64

global start

section .text

start:

    mov rdx, -12345d

    call print

next:

    mov     rax, 0x2000004 ; write
    mov     rdi, 1 ; stdout
    mov     rsi, msg
    mov     rdx, msg.len
    syscall

    mov     rax, 0x2000001 ; exit
    mov     rdi, 0
    syscall

scan:

    mov     rax, 0x2000003
    mov     rdi, 2
    mov     rsi, data
    mov     rdx, 9
    syscall

    mov rsi, data
    ; xor rdx, rdx
    xor rax, rax

    mov r9, 10d

    mov al, [rsi]
    cmp al, '-'
    jne to_int_loop

    inc rsi
    push rax

to_int_loop:

    lodsb
    cmp al, 10
    je end_of_int

    push rax
    mov rax, rdx
    mul r9d
    mov rdx, rax
    pop rax

    sub al, '0'
    add rdx, rax

    jmp to_int_loop

end_of_int:

    pop rax
    push rax
    cmp al, '-'
    jne positive

    pop rax

    mov rax, rdx
    ; xor rdx, rdx
    mov r9d, -100d
    mul r9d
    mov rdx, rax

    jmp negative

positive:
    ; push rax

    mov rax, rdx
    ; xor rdx, rdx
    mov r9d, 100d
    mul r9d
    mov rdx, rax
negative:
    ; -> OUT -> rdx
    ret

print: ; -> IN -> rdx

    mov rax, rdx

    mov r9, 1
    shl r9, 31d
    and r9, rax

    cmp r9, 0
    je no_sign
    push rax

    mov al, '-'
    mov rdi, data
    stosb

    call print_symbol

    pop rax
    not eax
    inc eax

no_sign:

    mov r8, rax
    xor r9, r9
    xor rbx, rbx

    mov r13, 10d

rev_loop:

    xor rdx, rdx
    mov rax, r8
    div r13d

    shl r9, 4
    add r9d, edx

    mov r8, rax
    inc rbx

    cmp r8, 0
    ja rev_loop

print_loop:
    mov rax, r9
    and rax, 1111b
    add rax, '0'

    mov rdi, data
    stosb

    call print_symbol

    shr r9, 4d
    dec rbx

    cmp rbx, 2
    jne without_dot

    mov al, '.'
    mov rdi, data
    stosb

    call print_symbol

without_dot:
    cmp rbx, 0
    jne print_loop

    mov al, 10
    mov rdi, data
    stosb

    call print_symbol

    ret

str_len:
    push rsi
    xor rdx, rdx

loop_len:
    lodsb
    cmp al, 0
    je found
    inc rdx
    jmp loop_len

found:
    pop rsi
    ret

print_symbol:

    push rsi

    mov rax, 0x2000004
    mov rdi, 1 ; stdout

    mov rsi, data
    mov rdx, 1
    syscall

    pop rsi

    ret


section .data

data:   times 10 db 0
msg:    db      "Hello, world!", 10
.len:   equ     $ - msg
msg2:   db      "qwertyuiopasd", 10
.len:   equ     $ - msg2
