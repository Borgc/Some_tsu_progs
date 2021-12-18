SECTION .data
    userMsg1    db 'Please enter a number a: '
    lenUserMsg1 equ $-userMsg1
    
    userMsg2    db 'Please enter a number b: '
    lenUserMsg2 equ $-userMsg2
    
    dispMsg     db 'a^b = '
    lenDispMsg  equ $-dispMsg
    
    errout      db "usage: ./a_power <NUM> <POW>"
    lenerr      equ $-errout
    
    overf       db "sorry it is too big number for me"
    lenoverf    equ $-overf

    empty       db 0xa

    n           dq 5

    arr:        dd 1, 3, 2, 10, 4, 5
    len         dd 6
    
SECTION .bss  
    ;matrix  resd 25
    min_i   resq 1
    max_i   resq 1
    c       resb 32
SECTION .text
global _start
    _start:
        
        mov ebx, 10 ; min
        mov edx, 1 ; max
        mov eax, 0 ; acc
        mov ecx, [len]
        mov edi, 0 ; cur
        mov esi, 0 ; iterator
        
        max_min:
        mov edi, dword [arr + 4*esi]
        cmp ebx, edi
        jg set_min
        cmp edx, edi
        jl set_max
        back:
        inc esi
        loop max_min


        mov eax, [min_i]
        mov ebx, [max_i]
        cmp eax, ebx
        jg swap
        back1:
        mov ebx, [min_i]    
        
        ;mov edx, [max_i] * 4
        mov ecx, [max_i]
        sub ecx, ebx
        cmp ecx, 1
        je print_0
        add ebx, ebx; mul 4
        add ebx, ebx

        mov eax, 0
        dec ecx
        count:
            add eax, [arr + ebx + ecx*4]
        loop count




        output:

        mov ecx, 0
        division_int:
            mov edx, 0          ; zero edx
            mov ebx, 10         ; 10 in ebx
            div ebx             ; in eax we have our number
            add edx, '0'        ; add edx to get symbol
            push edx            ; push edx
            inc ecx             ; count our symbols for next popper
        test eax, eax              ; while eax none zero
        jne division_int

        mov esi, c              ; get address of output msg

        popper:
            pop edx             ; save edx
            mov [esi], edx      ; move [esi](our number address) in edx
            inc esi             ; inc esi for next symbol
            loop popper         ; loopimsya

        mov ebp, esp
        mov eax, [ebp + 8]

        norm:
        push dword 12
        push dword c
        call print
        add esp, 8

        end:
        mov eax, 1              ; just end this program
        mov ebx, 0
        int 80h

        set_min:
            mov ebx, edi
            mov [min_i], esi
            jmp back
        set_max:
            mov edx, edi
            mov [max_i], esi
            jmp back
        swap:
            mov [min_i], ebx 
            mov [max_i], eax
            jmp back1
        print_0:
            mov eax, 0
            jmp output

            

        
        string_to_int:
            .shift equ 8

            push ebp
            mov ebp, esp

            xor eax, eax
            mov ecx, 10
            xor ebx, ebx

            mov esi, [ebp + .shift]
            mov bl, [esi]
            cmp bl, '-'
            je .skip
            .back:
            mov bl, [esi]
            test bl, bl
            jz .exit
            cmp bl, 0x30
            jl wrong
            cmp bl, 0x39
            jg wrong
            sub bl, '0'
            mul ecx
            jo overflow
            add eax, ebx
            .skip:
            inc esi
            jmp .back
            .exit:
            pop ebp
        ret

        wrong:
            push dword lenerr
            push dword errout
            call print
            add esp, 8
        jmp end

        print:                  ;print(msg_adr, length)
        .length     equ 12
        .msg_adr    equ 8

        push ebp
        mov ebp, esp

        mov eax, 4
        mov ebx, 1
        mov ecx, [ebp + .msg_adr]        ;edi - your message
        mov edx, [ebp + .length]         ;edx - length
        int 80h

        mov eax, 4
        mov ebx, 1
        mov ecx, empty
        mov edx, 1
        int 80h  
            int 80h   
        int 80h  
        pop ebp 
    ret

        string_len:                 ; string_len()
        .shift equ 8

        push ebp
        mov ebp, esp

        xor eax, eax 
        mov ebx, [ebp + .shift]
        .again:   
            inc eax             
            mov cl, [ebx] 
            inc ebx
            test cl, cl
            jnz .again
        dec eax     
        pop ebp            
    ret

        overflow:
            push dword lenoverf
            push dword overf
            call print
            add esp, 8
            jmp end