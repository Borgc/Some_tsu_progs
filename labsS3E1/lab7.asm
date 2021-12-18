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

    arr:        dd 2, 2, 2, 2, 2, 3
    farr:       dd 0, 0, 0, 0, 0, 0
    len         dd 6
    
SECTION .bss  
    a       resb 32
    c       resb 32
SECTION .text
global _start
    _start:
        


        mov ecx, [len]
        mov esi, 0
        set_flags:
        mov edi, dword [arr + 4*esi] ;get num
        mov eax, dword [farr + 4*edi - 4];check here is 1 or 0
        cmp eax, 0
        je set_flag
        back:
        inc esi
        loop set_flags
        
        mov ecx, [len]
        mov esi, 1
        print_ones:
            mov edi, dword [farr + 4*esi - 4]
            cmp edi, 1
            jne .skip

            mov eax, esi
            push eax
            push ecx

            push dword a
            push dword esi
            call int_to_string
            add esp, 8

            push dword 32
            push dword a
            call print
            add esp, 8

            pop ecx
            pop esi
            .skip:
            inc esi
            loop print_ones

        end:
        mov eax, 1              ; just end this program
        mov ebx, 0
        int 80h

        set_flag:
            mov [farr + 4*edi - 4], dword 1
            jmp back

        output_int_arr:
            mov esi, 0
            mov ecx, [len]
            .cycle:
            mov edi, dword [arr + 4*esi] ;get num
            push ecx
            push esi

            push dword a
            push dword edi
            call int_to_string
            add esp, 8

            push dword 32
            push dword a
            call print
            add esp, 8

            pop esi
            inc esi
            pop ecx
            loop .cycle

            
        int_to_string: ;int_to_string(num, msg_adr)
            .msg_adr    equ 12
            .num        equ 8
            
            push ebp
            mov ebp, esp
            
            mov eax, [ebp + .num]
            mov esi, [ebp + .msg_adr] ; get address of output msg

            xor ecx, ecx
            .division_int:
            mov edx, 0          ; zero edx
            mov ebx, 10         ; 10 in ebx
            div ebx             ; in eax we have our number
            add edx, '0'        ; add edx to get symbol
            push edx            ; push edx
            inc ecx             ; count our symbols for next popper
            test eax, eax              ; while eax none zero
            jne .division_int

           

            .popper:
                pop edx             ; save edx
                mov [esi], edx      ; move [esi](our number address) in edx
                inc esi             ; inc esi for next symbol
                loop .popper         ; loopimsya

            mov ebp, esp
            mov eax, esi
            pop ebp
        ret

        
        string_to_int: ; string_to_int(msg_adr)
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