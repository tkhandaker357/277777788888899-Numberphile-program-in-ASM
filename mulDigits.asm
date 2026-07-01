[bits 64]
default rel

; this is a program based on numberphile's video literally titled "277777788888899", where 
; the program takes a string of numbers as a command-line argument and then multiplies all
; the characters (digits) together until there's only 1 digit left, and prints each product
; the number 277777788888899 has significance as it is creates the longest chain of products
; of digits that has been so far discovered

section .data
    newline     db 10
    askUser      db "Enter a number > 0: "

section .bss
    input    resb 2048

section .text
    global _start

_start:
    pop rbx
    cmp rbx, 2
    jl .noInput
    pop rsi
    pop rsi
    .funcCall:
    mov rax, rsi
    call mulUntilOneDigit
    jmp _exit

    .noInput:
        push rbp
        mov rbp, rsp
        sub rsp, 8

        mov byte [rsp], '0'
        
        mov rsi, rsp
        mov r11, 1
        jmp .funcCall

_exit:
    cmp r11, 1
    je .popRbp
    .finishExit:
    mov rax, 60
    mov rdi, 0
    syscall
    .popRbp:
        mov rsp, rbp
        pop rbp
        jmp .finishExit

; input/return in rax
intToStr:
    xor rdi, rdi
    xor r10, r10
    xor r9, r9
    xor r8, r8
    xor rdx, rdx
    xor rbx, rbx

    cmp rax, 0
    jl .isNegative
    jmp .countChars
    
    .isNegative:
        mov rdi, 1
        neg rax
        inc r9

    .countChars:
        push rax
        mov rcx, 10
        .countBytesLoop:
            xor rdx, rdx
            div rcx
            inc r9
            cmp rax, 0
            je .countCharsEnd
            jmp .countBytesLoop
    .countCharsEnd:
    inc r9
    pop rax

    push rcx
    
    mov rcx, 8
    cmp r9, 8
    jl .allocMem
    mov r8, 8
    .allocMem:
        push rax
        mov rax, r9
        mov rdx, 0
        div rcx
        cmp rdx, 0
        jne .addByte
        jmp .allocBytes
        .addByte:
            inc rax
        .allocBytes:
            imul rax, 8
            mov r8, rax
        pop rax
    pop rcx

    .allocateString:
        push rbp
        mov rbp, rsp
        sub rsp, r8
        mov r10, rbp

        mov byte [r10], 0
        dec r10

        .allocStrLoop:
            mov rdx, 0
            div rcx
            add dl, '0'
            mov byte [r10], dl
            cmp rax, 0
            je .allocStrEnd
            dec r10
            jmp .allocStrLoop
        .allocStrEnd:

        cmp rdi, 1
        jne .finished
        dec r10
        mov byte [r10], '-'

    .finished:
        lea rax, [r10]
        mov rdx, r8
        mov rsp, rbp
        pop rbp
        ret


; str in rax
mulDigits:
    xor rbx, rbx
    mov rbx, rax
    xor rax, rax
    xor rcx, rcx
    mov rdx, 1
    .mulDigitsLoop:
        mov al, byte [rbx + rcx]
        cmp al, 0
        je .mulDigitsLoopEnd
        sub al, '0'
        cmp al, 0
        jl .mulDigitsLoopEnd
        cmp al, 9
        jg .mulDigitsLoopEnd
        imul rdx, rax
        inc rcx
        jmp .mulDigitsLoop
        .mulDigitsLoopEnd:

    mov rax, rdx
    ret   

; first num in rax
mulUntilOneDigit:
    xor r9, r9
    .tilLOneDigLoop:
        inc r9
        mov rsi, rax
        mov rax, 1
        mov rdi, 1
        xor rdx, rdx
        .countLenLoop:
            mov r8b, byte [rsi + rdx]
            cmp r8b, '0'
            jl .countLenLoopEnd
            cmp r8b, '9'
            jg .countLenLoopEnd
            inc rdx
            jmp .countLenLoop
            .countLenLoopEnd:
        syscall
        push rsi
        mov rsi, newline
        mov rdx, 1
        mov rdi, 1
        mov rax, 1
        syscall
        pop rsi
        mov rax, rsi
        call mulDigits
        cmp rax, 10
        jl .tilLOneDigLoopEnd
        call intToStr
        jmp .tilLOneDigLoop
        .tilLOneDigLoopEnd:
        
    call intToStr
    mov rsi, rax
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    syscall
    mov rsi, newline
    mov rdx, 1
    mov rdi, 1
    mov rax, 1
    syscall
    
    mov rax, r9
    ret
