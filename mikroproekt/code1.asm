format PE console

entry start

include 'win32a.inc'

section '.data' data readable writable

        entNum db 'Enter number n :', 0
        outNum db 'Greatest woodal number less or equals is :', 0
        incorr db 'Incorrect obtained value...', 0
        paramu db '%u', 0

        great dd ?
        num dd 0
        twos dd 2
        i dd 1

section '.code' code readable executable

start:
        push entNum
        call [printf]
        add esp, 4

        push num
        push paramu
        call [scanf]
        add esp, 8

        cmp eax, 1
        jne IncorrectInput

        mov ecx, [num]
        call woodal

        push outNum
        call [printf]
        add esp, 4

        push [great]
        push paramu
        call [printf]
        add esp, 8

finish:
        call [getch]
        push 0
        call [ExitProcess]


woodal:
        mov [i], 1
        mov [twos], 2
        mov eax, [twos]
        mul [i]    ; вычисление числа вудала, результат в регистре eax
        dec eax
cycle:

        cmp eax, ecx
        ja wfinish

        mov [great], eax
        mov eax, 2

        mul [twos]
        mov [twos], eax

        inc [i]
        mov eax, [twos]
        mul [i]
        cmp edx, 0   ; если edx не 0, то результат умножения уже не беззнаковое двойное слово - точно больше введенного
        jne wfinish
        dec eax
        jmp cycle

wfinish:
        xor eax, eax
        xor edx, edx
        ret 0

IncorrectInput:
        push incorr
        call [printf]
        jmp finish

section '.idata' import data readable

        library kernel, 'kernel32.dll', \
                msvcrt, 'msvcrt.dll'

        import kernel, \
               ExitProcess, 'ExitProcess'

        import msvcrt, \
               printf, 'printf', \
               scanf, 'scanf', \
               getch, '_getch'