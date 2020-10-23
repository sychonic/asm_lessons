;������ ���������� ���������� ��� Win32
format PE GUI 4.0
entry start
include 'win32a.inc'
section '.data' data readable writeable
hwnd    dd    0
hInst    dd    0
hdc    dd    0
;lpVersionInformation   OSVERSIONINFO   <?>
wcl    WNDCLASSEX    <?>
wcllen=$-wcl
message MSG    <?>
ps    PAINTSTRUCT    <?>
szClassName    db    '���������� Win32',0
szTitleName    db    '��������� ���������� Win32 �� ����������',0
MesWindow    db    '������! ��, ��� ��� ������� ���������� ���������� �� ����������?'
MesWindowLen    =    $-MesWindow
playFileCreate    db    'create.wav',0
playFilePaint    db    'paint.wav',0
playFileDestroy db    'destroy.wav',0
winmmdllname db 'winmm.dll',0
user32dllname db 'user32.dll',0
namef1 db 'PlaySound',0
HL1 dd 0
addrf1 dd ?
section '.code' code readable executable
 start:
    invoke    GetModuleHandle,0
    mov    [hInst], eax       ; �� �������� �������� ������.
;���������� ����� ������� ��������������� ��������� �����
push winmmdllname;
call [LoadLibrary];
push namef1;
push eax;
call [GetProcAddress];
mov  [addrf1], eax;
WinMain:
    mov    [wcl.cbSize], wcllen      ;������ ��������� � wcl.cbSize
    mov    [wcl.style], CS_HREDRAW+CS_VREDRAW
    mov    [wcl.lpfnWndProc],WindowProc       ;����� ������� ���������
    mov    [wcl.cbClsExtra],0
    mov    [wcl.cbWndExtra],0
    mov    eax,hInst
;���������� ���������� � ���� hInstance ��������� wcl
    mov    [wcl.hInstance],eax
    push  IDI_APPLICATION          ;����������� ������
    push  0;
    call [LoadIcon];
    mov    [wcl.hIcon],eax   ;���������� ������ � ���� hIcon ��������� wcl
    push    IDC_ARROW    ;����������� ������ - �������
    push    0
    call    [LoadCursor]
    mov    [wcl.hCursor],eax ;���������� ������� � ���� hCursor ��������� wcl
;��������� ���� ���� ���� - �����
;������� ����� HGDIOBJ GetStockObject(int fnObject)     ;type of stock object
    push    WHITE_BRUSH
    call    [GetStockObject]
    mov    [wcl.hbrBackground],eax
    mov    dword    ptr wcl.lpszMenuName,0    ;��� �������� ����
    mov    dword ptr wcl.lpszClassName, szClassName  ;��� ������ ����  szClassName
    mov    [wcl.hIconSm],0
;������������ ����� ���� - ������� ����� RegisterClassExA (&wndclass)
    push    wcl;
    call    [RegisterClassEx]
    test    ax,ax    ;��������� �� ����� ����������� ������ ����
    jz    end_cycl_msg    ;�������
;������� ����:
    push    0    ;lpParam
    push    [hInst]   ;hInstance
    push    NULL    ;menu
    push    NULL    ;parent hwnd
    push    CW_USEDEFAULT    ;������ ����
    push    CW_USEDEFAULT    ;������ ����
    push    CW_USEDEFAULT    ;���������� y ������ �������� ���� ����
    push    CW_USEDEFAULT    ;���������� x ������ �������� ����
    push    WS_OVERLAPPEDWINDOW    ;����� ����
    push    szTitleName     ;������ ��������� ����
    push    szClassName     ;��� ������ ����
    push    NULL
    call    [CreateWindowEx]
    mov    [hwnd],eax      ;hwnd - ���������� ����
;�������� ����:
    push    SW_SHOWNORMAL
    push    [hwnd]
    call    [ShowWindow]
;�������������� ���������� ����
    push    [hwnd]
    call    [UpdateWindow]
;��������� ���� ���������:
cycl_msg:
    push    0
    push    0
    push    NULL
    push    message
    call    [GetMessage]
    cmp    ax,0
    je    end_cycl_msg
;���������� ����� � ����������
    push    message
    call    [TranslateMessage]
;�������� ��������� ������� ���������
    push    message
    call    [DispatchMessage]
    jmp    cycl_msg
end_cycl_msg:
;����� �� ����������
push    NULL
   call    [ExitProcess]
;-------------------WindowProc-----------------------------------------------
proc WindowProc   @@hwnd:DWORD, @@mes:DWORD, @@wparam:DWORD, @@lparam:DWORD
;ebx,edi, esi       ;��� �������� ����������� ������ �����������
;uses ebx, esi, edi
local    @@hdc:DWORD
;push    ebx esi edi
push ebx
push edi
push esi
    cmp    [@@mes],WM_DESTROY
    je    wmdestroy
    cmp    [@@mes],WM_CREATE
    je    wmcreate
    cmp    [@@mes],WM_PAINT
    je    wmpaint
    jmp    default
wmcreate:
;��������� �������� ���� �������� ��������
    push    00020000h
    push    NULL
    push    playFileCreate
       call    [addrf1]
    mov    eax,0    ;������������ �������� 0
       jmp     exit_wndproc
wmpaint:
    push    00020000h
       push    NULL
       push    playFilePaint
    call    [addrf1]
;������� �������� ���������� HDC BeginPaint( HWND hwnd, // handle to window LPPAINTSTRUCT lpPaint // pointer to structure for paint information);
push    ps
    push    [@@hwnd]
    call    [BeginPaint]
    mov    [@@hdc],eax
;������� ������ ������ � ���� BOOL TextOut(
    push    MesWindowLen
    push    MesWindow
    push    100
    push    10
    push    [@@hdc]
    call    [TextOut]
;���������� �������� BOOL EndPaint(
push    ps
push    [@@hdc]
call    [EndPaint]
    mov    eax,0    ;������������ �������� 0
    jmp    exit_wndproc
wmdestroy:
    push    00020000h
       push    NULL
       push    playFileDestroy
       call    [addrf1]
;������� ��������� WM_QUIT
    push    0
    call    [PostQuitMessage]
    mov    eax,0    ;������������ �������� 0
    jmp    exit_wndproc
default:
;��������� �� ���������
    push    [@@lparam]
    push    [@@wparam]
    push    [@@mes]
    push    [@@hwnd]
    call    [DefWindowProc]
    jmp exit_wndproc
;... ... ...
exit_wndproc:pop esi
pop edi
pop ebx
    ret
       endp
      section '.idata' import data readable writeable
library kernel32,'KERNEL32.DLL',\
      user32,'USER32.DLL',\
      gdi32,'GDI32.DLL'
include 'kernel32.inc'
include 'user32.inc'
include 'gdi32.inc'