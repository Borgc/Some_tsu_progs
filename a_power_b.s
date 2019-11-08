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

    a           dq 0
    b           dq 0
    
SECTION .bss  
    len_a   resb 32
    len_b   resb 32
    c       resb 32
SECTION .text
global _start
    _start: 

        mov ebx, [esp]
        cmp ebx, 3
        jne wrong 

        mov ebp, esp
        mov ebx, [ebp + 8]          ; get a address
        call string_len
        mov [len_a], eax            ; get a length
        mov eax, [ebx]             
        

        mov esi, [ebp + 8]          ; in esi a in stack address     
        call string_to_int
        mov [a], eax               ; move number in [a] from eax ¯ \ _ (ツ) _ / ¯
       
        mov esi, [ebp + 12]                                         
        call string_to_int
        mov [b], eax                

        mov eax, [a]
        mov ebx, [b]                ; a lot of jumps
        cmp eax, 1
        je print_1
        test eax, eax
        jz print_0
        test ebx, ebx
        jz print_1
        cmp ebx, 1
        je print_a

        mov ebp, eax
        mov ecx, eax
        mov esi, 1
        mov edi, 1

        _cycle:
            mov edi, 1
            _in_cycle:
                add ebp, ecx            ; ebp - accum
                jc overflow
                inc edi                 ; edi - _in_cycle iterator
                cmp edi, eax            ; esi - _cycle iterator
                jl _in_cycle 

            mov ecx, ebp
            inc esi
            cmp esi, ebx
                jl _cycle               

        mov eax, 4 
        mov ebx, 1
        mov ecx, dispMsg
        mov edx, lenDispMsg
        int 80h

        mov ecx, 0
        mov eax, ebp

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
        mov bl, [eax]
        cmp bl, '-'
        je minus

        norm:
        mov edi, c
        mov ebp, 12
        call print

        end:
        mov eax, 1              ; just end this program
        mov ebx, 0
        int 80h

        minus:
            mov eax, [b]
            xor edx, edx
            mov ecx, 2
            div ecx
            test edx, edx
            jz norm

            mov eax, 4 
            mov ebx, 1
            mov ecx, [ebp + 8]
            mov edx, 1
            int 80h

            mov eax, 4          
            mov ebx, 1
            mov ecx, c
            mov edx, 12
            int 80h

            jmp end

        print_1:
            mov eax, 4 
            mov ebx, 1
            mov ecx, dispMsg
            mov edx, lenDispMsg
            int 80h
            
            mov ecx, 0x31
            push ecx
            mov eax, 4
            mov ebx, 1 
            mov ecx, esp
            mov edx, 1
            int 80h
            pop ecx
        jmp end

        print_0:
            test ebx, ebx
            jz print_1

            mov eax, 4 
            mov ebx, 1
            mov ecx, dispMsg
            mov edx, lenDispMsg
            int 80h

            mov ecx, 0x30
            push ecx
            mov eax, 4
            mov ebx, 1 
            mov ecx, esp
            mov edx, 1
            int 80h
            pop ecx
        jmp end

        print_a:
            mov eax, 4 
            mov ebx, 1
            mov ecx, dispMsg
            mov edx, lenDispMsg
            int 80h

            mov eax, 4 
            mov ebx, 1
            mov ecx, [esp + 8]
            mov edx, [len_a]
            int 80h
        jmp end

        string_to_int:
            xor eax, eax
            mov ecx, 10
            xor ebx, ebx
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
        ret

        wrong:
            mov edi, errout
            mov ebp, lenerr
            call print
        jmp end

        print:
            mov eax, 4
            mov ebx, 1
            mov ecx, edi        ;edi - your message
            mov edx, ebp        ;ebp - length
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
            inc eax             
            mov cl, [ebx]       ; in ebx address from stack address
            inc ebx
            test cl, cl
            jnz again
        dec eax                 
        ret

        overflow:
            mov edi, overf
            mov ebp, lenoverf
            call print
            jmp end
