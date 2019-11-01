section .data
    out1        db "Enter your message: "           ; wow I write read comments
    lenout1     equ $-out1
    out2        db "Enter your key: "
    lenout2     equ $-out2
    errout      db "Wrong input"
    lenerr      equ $-errout
    empty       db 0xa

section .bss
    msg resb 256
    key resd 1
    len1 resb 32
    len2 resb 32

section .text
global _start
    _start:
    mov ebp, esp

    mov ebx, [esp]
    cmp ebx, 2
    jne wrong

    push ebp
    mov edi, out1
    mov ebp, lenout1
    call print
    pop ebp

    mov eax, 3
    mov ebx, 0
    mov ecx, msg
    mov edx, 256
    int 80h

    mov [len1], eax

    
    mov ebx, [ebp+8]
    mov [key], ebx
    call string_len

    ; substr(msg, msg_len, key, key_len)
    push dword eax
    push dword [key]
    push dword [len1]
    push dword msg
    call _substr
    add esp, 16
    
    mov edi, msg
    mov ebp, [len1]
    call print

    end:
        mov eax, 1
        mov ebx, 0
        int 80h

    wrong:
        mov edi, errout
        mov ebp, lenerr
        call print
        jmp end

    _substr:                            ; substr(msg, msg_len, key, key_len)
        .msg        equ  8
        .msg_len    equ  12
        .key        equ  16     
        .key_len    equ  20
        
        push ebp
        mov ebp, esp


        mov ecx, [ebp + .msg_len]
        .cycle:
            mov edi, [ebp + .msg_len]       ; length
            mov esi, [ebp + .key_len]       ; esi - делитель
            sub edi, ecx                    ; вычитаем, чтобы идти по строке        
            mov eax, edi                    ; eax - делимое
            mov edx, 0       
            div esi                         ; деление

            mov eax, [ebp + .key]
            mov bl,[eax + edx]              ; забираем символ из ключа
            sub bl, 'a'                     ; получаем код символа
            
            mov eax, [ebp + .msg]
            mov dl, [eax + edi]      ; забираем символ из исходного сообщения
            sub dl, 'a'                     ; получаем код символа

            cmp dl, 0
            jl .skip
            cmp dl, 25
            jg .skip

            add bl, dl                      ; складываем коды
            movzx ax, bl                      ; пихаем сумму в ах чтобы разделить с остатком на 26
            mov bh, 26                      ; 26
            div bh                          ; division
            
            add ah, 'a'                     ; прибавляем 'a' чтобы получить символ
            mov [msg + edi], ah             ; а теперь возвращаем в исходную строчку закодированный символ
            
            .skip:
            loop .cycle
        pop ebp
    ret


    print:
        mov eax, 4
        mov ebx, 1
        mov ecx, edi        ;edi - your message
        mov edx, ebp        ;edx - length
        int 80h

        mov eax, 4
        mov ebx, 1
        mov ecx, empty
        mov edx, 1
        int 80h   
    ret

    string_len:
        xor eax, eax 
        again:   
            inc eax             ; need to zero ecx
            mov cl, [ebx]       ; in ebx address from stack address
            inc ebx
            test cl, cl
            jnz again
        dec eax                 
    ret



