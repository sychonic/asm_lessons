format PE console

entry start

include 'win32a.inc'

section '.data' data readable writeable

        strsize db 'Enter array size :', 0
        wrongsize db 'Wrong array size : %d', 0
        arrayout db 'Straight output is :', 10, 13, 0
        arrayrev db 'Reverse output is :', 10, 13, 0
        enterelem db '[%d]?', 0

        spaceStr db '%d ', 0
        param db '%d', 0

        vec_size dd 0
        i dd ?
        first rd 100
        last dd ?

section '.code' code readable executable

start:
        push strsize
        call [printf]
        add esp, 4

        push vec_size
        push param
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jle wrongFinish

        call enterVector
        call outVec
        call revVec
        call finish

wrongFinish:
        push [vec_size]
        push wrongsize
        call [printf]
        jmp finish

enterVector:
        mov ebx, first
        mov ecx, 0

enterLoop:
        cmp ecx, [vec_size]
        je endInput

        mov [i], ecx
        push ecx
        push enterelem
        call [printf]
        add esp, 8


        push ebx
        push param
        call [scanf]
        add esp, 8

        add ebx, 4
        mov ecx, [i]
        inc ecx
        jmp enterLoop

endInput:
        mov [last], ebx
        xor ebx, ebx
        xor ecx, ecx
        ret

outVec:
        mov ebx, first

        push arrayout
        call [printf]
        add esp, 4
outElem:
        cmp ebx, [last]
        je endOut

        push dword [ebx]
        push spaceStr
        call [printf]
        add esp, 8

        add ebx, 4
        jmp outElem
endOut:
        xor ebx, ebx
        ret

revVec:
        mov ebx, [last]

        push arrayrev
        call [printf]
        add esp, 4
revElem:

        cmp ebx, first
        je endRev

        sub ebx, 4
        push dword [ebx]
        push spaceStr
        call [printf]
        add esp, 8
        jmp revElem
endRev:
        xor ebx, ebx
        ret


finish:
        call [getch]
        push 0
        call [ExitProcess]

section  '.idata' import data readable

        library kernel, 'kernel32.dll', \
                msvcrt, 'msvcrt.dll'

        import kernel, \
               ExitProcess, 'ExitProcess'

        import msvcrt, \
               printf, 'printf', \
               scanf, 'scanf', \
               getch, '_getch'
