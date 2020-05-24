global start
%macro printf 1-*
    %rep %0                                        ; prologue
        %rotate -1
        xor r8, r8
        mov r8, %1
        push r8
    %endrep

    call printing

    %rep %0                                        ; epilogue
        pop r8
    %endrep
%endmacro

section .text

start:
        ; вызов printf с аргументной строкой pr_arg и аргументами string, 3802, 100, '!', 127
        printf pr_arg, string, 3802, 100, '!', 127

        call end_start

printing:

        push rbp
        mov rbp, rsp

        add rbp, 16d ;  пропускаем rbp и адрес возврата в стеке
        mov rsi, [rbp] ; в rsi адрес аргументной строки

next_symbol:
        
        xor rax, rax

        mov al, [rsi] ; получаем символ из аргументной строки
        inc rsi ; переходим к следующему сиволу

        cmp al, 0 ; встречен конец аргументной строки
        je end_printing

        cmp al, '%' ; обычный символ
        jne default_symbol

        mov al, [rsi] ; получаем символ из аргументной строки
        inc rsi ; переходим к следующему сиволу

        cmp al, '%'
        je default_symbol ; встречена конструкция '%%'

        add rbp, 8d ; получаем аргумент для команды %

        sub al, 'a'
        shl rax, 3;  * 8
        mov rbx, jump_table
        add rax, rbx; rdi = jmp_t + (al - 'a') * 8

        jmp [rax]

        ; cmp al, 'd'
        ; je _decimal
        ;
        ; cmp al, 'b'
        ; je _binary
        ;
        ; cmp al, 'o'
        ; je _octal
        ;
        ; cmp al, 'x'
        ; je _hexadecimal
        ;
        ; cmp al, 'с'
        ; je _char
        ;
        ; cmp al, 's'
        ; je _string
        ;
        ; jmp next_symbol

_decimal:

        mov rax, [rbp]

        mov r9, 1
        shl r9, 31d
        and r9, rax

        cmp r9, 0
        je no_sign
        push rax

        mov al, '-'
        mov rdi, buff
        stosb

        call print_symbol

        pop rax
        not rax
        inc rax

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
        add r9, rdx

        mov r8, rax
        inc rbx

        cmp r8, r13
        jae rev_loop

        shl r9, 4
        add r9, r8
        inc rbx

print_loop:
        mov rax, r9
        and rax, 1111b
        add rax, '0'

        mov rdi, buff
        stosb

        call print_symbol

        shr r9, 4d
        dec rbx
        cmp rbx, 0
        jne print_loop

        jmp next_symbol


_binary:
        mov rax, [rbp]
        mov cl, 1
        mov r8, 1b

        push rsi
        call special_proc
        pop rsi

        jmp next_symbol

_octal:

        mov rax, [rbp]
        mov cl, 3
        mov r8, 111b

        push rsi
        call special_proc
        pop rsi

        jmp next_symbol

_hexadecimal:

        mov rax, [rbp]
        mov cl, 4
        mov r8, 1111b

        push rsi
        call special_proc
        pop rsi

        jmp next_symbol

_char:

        mov rax, [rbp]
        mov rdi, buff
        stosb

        call print_symbol

        jmp next_symbol

_string:

        push rsi

        mov rsi, [rbp]
        call print_string

        pop rsi

        jmp next_symbol

default_symbol:

        mov rdi, buff
        stosb

        call print_symbol

        jmp next_symbol

; rax <- number
; cl <- power of 2 (1, 3, 4)
; r8 <- bits (1b, 111b, 1111b)

special_proc:

        xor r13, r13
        xor rbx, rbx

spec_rev_loop:

        mov r9, rax
        and r9, r8

        shl r13, cl
        add r13, r9

        shr rax, cl

        inc rbx

        cmp rax, 0
        jne spec_rev_loop

spec_pr_loop:

        mov r9, r13
        and r9, r8

        mov rsi, table
        add rsi, r9

        ; push r13
        ; push r8
        push rcx
        ; push rbx

        lodsb

        mov rdi, buff
        stosb
        call print_symbol

        ; pop rbx
        pop rcx
        ; pop r8
        ; pop r13

        shr r13, cl
        dec rbx

        cmp rbx, 0
        jne spec_pr_loop

        ret

end_printing:
        pop rbp

        ret


; печатает символ из buff

print_symbol:

        push rsi

        mov rax, 0x2000004
        mov rdi, 1 ; stdout

        mov rsi, buff
        mov rdx, 1
        syscall

        pop rsi

        ret

; rsi >> pointer to string

print_string:

        mov rax, 0x2000004
        mov rdi, 1

        push rax
        call str_len
        pop rax

        syscall

        ret

; rsi >> pointer to string
; rdx << size of string

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

end_start:

        mov rax, 0x2000001
        mov rdi, 0
        syscall ; завершаем программу и выходим

        ret

section .data

pr_arg: db "I %s %x %d%%%c%b", 10, 0
string: db "love", 0
symbol: db '?'

buff:   db 'A'

table:  db '0123456789ABCDEF'

jump_table:
        dq next_symbol,
        dq _binary,
        dq _char,
        dq _decimal,
        times 10 dq next_symbol,
        dq _octal,
        times 3 dq next_symbol,
        dq _string,
        times 4 dq next_symbol,
        dq _hexadecimal,
        times 4 dq next_symbol
