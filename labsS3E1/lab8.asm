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

    matrix:     dd 1, 2, 3, 4, 5
                dd 6, 7, 8, 9, 10
                dd 11, 12, 13, 14, 15
                dd 16, 17, 18, 19, 20
                dd 21, 22, 23, 24, 25
    
SECTION .bss  
    ;matrix  resd 25
    len_a   resb 32
    len_b   resb 32
    c       resb 32
SECTION .text
global _start
    _start:
         
        ;mov ecx, 25
        ;fill:
        ;mov [matrix + 4*ecx], dword 1
        ;loop fill
        

        mov ebx, 0 ; string index
        mov esi, 0 ; column index
        mov edi, 0; dh - border
        mov ebp, 0; dl - middle matrix flag 
        mov eax, 0  ; accum
        mov ecx, [n]
        count:
        add eax, dword [matrix + ebx + 4*esi]
        add ebx, 5*4
        loop count
        
        cmp ebp, 0
        jnz growing
        inc esi
        inc edi
        ;mov esi, edi

        mov ecx, edi
        mov ebx, 0
        lp:
        add ebx, 5*4
        loop lp

        mov ecx, [n]
        sub ecx, edi
        sub ecx, edi
        cmp ecx, 1
        
        jle set_flag
        jmp count





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

        set_flag:
            mov ebp, 1
            jmp count
        growing:
            mov ebx, 0
            inc esi
            dec edi
            cmp edi, 0
            jle zero_edi
            mov ecx, edi
            

        lp1: 
            add ebx, 5*4
            loop lp1
        zero_edi:
            mov ecx, [n]
            sub ecx, edi
            sub ecx, edi
            cmp edi, -1
            je output
        jmp count
            

        
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