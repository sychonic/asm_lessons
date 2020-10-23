;ѕример каркасного приложени€ дл€ Win32
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
szClassName    db    'ѕриложение Win32',0
szTitleName    db    ' аркасное приложение Win32 на ассемблере',0
MesWindow    db    'ѕривет! Ќу, как вам процесс разработки приложени€ на ассемблере?'
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
    mov    [hInst], eax       ; по которому загружен модуль.
;ќпредел€ем адрес функции воспроизведени€ звукового файла
push winmmdllname;
call [LoadLibrary];
push namef1;
push eax;
call [GetProcAddress];
mov  [addrf1], eax;
WinMain:
    mov    [wcl.cbSize], wcllen      ;размер структуры в wcl.cbSize
    mov    [wcl.style], CS_HREDRAW+CS_VREDRAW
    mov    [wcl.lpfnWndProc],WindowProc       ;адрес оконной процедуры
    mov    [wcl.cbClsExtra],0
    mov    [wcl.cbWndExtra],0
    mov    eax,hInst
;дескриптор приложени€ в поле hInstance структуры wcl
    mov    [wcl.hInstance],eax
    push  IDI_APPLICATION          ;стандартна€ иконка
    push  0;
    call [LoadIcon];
    mov    [wcl.hIcon],eax   ;дескриптор иконки в поле hIcon структуры wcl
    push    IDC_ARROW    ;стандартный курсор - стрелка
    push    0
    call    [LoadCursor]
    mov    [wcl.hCursor],eax ;дескриптор курсора в поле hCursor структуры wcl
;определим цвет фона окна - белый
;готовим вызов HGDIOBJ GetStockObject(int fnObject)     ;type of stock object
    push    WHITE_BRUSH
    call    [GetStockObject]
    mov    [wcl.hbrBackground],eax
    mov    dword    ptr wcl.lpszMenuName,0    ;без главного меню
    mov    dword ptr wcl.lpszClassName, szClassName  ;им€ класса окна  szClassName
    mov    [wcl.hIconSm],0
;регистрируем класс окна - готовим вызов RegisterClassExA (&wndclass)
    push    wcl;
    call    [RegisterClassEx]
    test    ax,ax    ;проверить на успех регистрации класса окна
    jz    end_cycl_msg    ;неудача
;создаем окно:
    push    0    ;lpParam
    push    [hInst]   ;hInstance
    push    NULL    ;menu
    push    NULL    ;parent hwnd
    push    CW_USEDEFAULT    ;высота окна
    push    CW_USEDEFAULT    ;ширина окна
    push    CW_USEDEFAULT    ;координата y левого верхнего угла окна
    push    CW_USEDEFAULT    ;координата x левого верхнего угла
    push    WS_OVERLAPPEDWINDOW    ;стиль окна
    push    szTitleName     ;—трока заголовка окна
    push    szClassName     ;им€ класса окна
    push    NULL
    call    [CreateWindowEx]
    mov    [hwnd],eax      ;hwnd - дескриптор окна
;показать окно:
    push    SW_SHOWNORMAL
    push    [hwnd]
    call    [ShowWindow]
;перерисовываем содержимое окна
    push    [hwnd]
    call    [UpdateWindow]
;запускаем цикл сообщений:
cycl_msg:
    push    0
    push    0
    push    NULL
    push    message
    call    [GetMessage]
    cmp    ax,0
    je    end_cycl_msg
;трансл€ци€ ввода с клавиатуры
    push    message
    call    [TranslateMessage]
;отправим сообщение оконной процедуре
    push    message
    call    [DispatchMessage]
    jmp    cycl_msg
end_cycl_msg:
;выход из приложени€
push    NULL
   call    [ExitProcess]
;-------------------WindowProc-----------------------------------------------
proc WindowProc   @@hwnd:DWORD, @@mes:DWORD, @@wparam:DWORD, @@lparam:DWORD
;ebx,edi, esi       ;эти регистры об€зательно должны сохран€тьс€
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
;обозначим создание окна звуковым эффектом
    push    00020000h
    push    NULL
    push    playFileCreate
       call    [addrf1]
    mov    eax,0    ;возвращаемое значение 0
       jmp     exit_wndproc
wmpaint:
    push    00020000h
       push    NULL
       push    playFilePaint
    call    [addrf1]
;получим контекст устройства HDC BeginPaint( HWND hwnd, // handle to window LPPAINTSTRUCT lpPaint // pointer to structure for paint information);
push    ps
    push    [@@hwnd]
    call    [BeginPaint]
    mov    [@@hdc],eax
;выведем строку текста в окно BOOL TextOut(
    push    MesWindowLen
    push    MesWindow
    push    100
    push    10
    push    [@@hdc]
    call    [TextOut]
;освободить контекст BOOL EndPaint(
push    ps
push    [@@hdc]
call    [EndPaint]
    mov    eax,0    ;возвращаемое значение 0
    jmp    exit_wndproc
wmdestroy:
    push    00020000h
       push    NULL
       push    playFileDestroy
       call    [addrf1]
;послать сообщение WM_QUIT
    push    0
    call    [PostQuitMessage]
    mov    eax,0    ;возвращаемое значение 0
    jmp    exit_wndproc
default:
;обработка по умолчанию
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