.486
.model flat, stdcall
option casemap: none
 
include /masm32/include/windows.inc
include /masm32/include/user32.inc
include /masm32/include/kernel32.inc
 
includelib /masm32/lib/user32.lib
includelib /masm32/lib/kernel32.lib
 
include /masm32/macros/macros.asm 
uselib masm32, comctl32, ws2_32 
 
.data
 
msg_title db "Title", 0
A DB 1h
x dd 0,1,2,3,4,5,6,7,8,9,10,11
n dd 12
 
buffer db 128 dup(?)
format db "%d",0
 
.code
start:
mov eax, 0
mov ecx, n
mov ebx, 0
L: add eax, x[ebx]
add ebx, type x
dec ecx
cmp ecx, 0
jne L
 
invoke wsprintf, addr buffer, addr format, eax
invoke MessageBox, 0, addr buffer, addr msg_title, MB_OK
 
invoke ExitProcess, 0
 
end start