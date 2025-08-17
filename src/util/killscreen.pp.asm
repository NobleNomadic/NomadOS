; killscreen.asm - When this code is run, all processes and current will stop (BSoD equivalent)
; Triggered at any stage by running jmp 0x0000:0x1000 to kill OS as fast as possible
[org 0x1000]
[bits 16]

%define COLATTRIBUTE 0x4F

killEntry:
    cli                     ; Stop interrupts immediately (kill process controller)
    call disableCursor
    call clearScreen
    call fatalMsg
    jmp $                   ; Halt forever


; Stop cursor from blinking
disableCursor:
    mov ah, 0x01      ; BIOS: Set cursor shape
    mov ch, 0x20      ; Start scan line > End scan line (hides it)
    mov cl, 0x00
    int 0x10
    ret

; Fill screen with red background
clearScreen:
    push ax
    push di

    mov ax, 0xB800
    mov es, ax
    xor di, di              ; Start at top-left

    mov ah, COLATTRIBUTE    ; Set color style
    mov al, ' '             ; Space char
    mov cx, 80*25
.fillLoop:
    stosw
    loop .fillLoop

    pop di
    pop ax
    ret

; Print "[!] Fatal error" manually
fatalMsg:
    push ax
    push di

    mov ax, 0xB800
    mov es, ax

    mov di, 0            ; Position 0 (top left)
    mov ah, COLATTRIBUTE ; Set color attribute

    mov al, '['
    stosw
    mov al, '!'
    stosw
    mov al, ']'
    stosw
    mov al, ' '
    stosw
    mov al, 'F'
    stosw
    mov al, 'a'
    stosw
    mov al, 't'
    stosw
    mov al, 'a'
    stosw
    mov al, 'l'
    stosw
    mov al, ' '
    stosw
    mov al, 'E'
    stosw
    mov al, 'r'
    stosw
    mov al, 'r'
    stosw
    mov al, 'o'
    stosw
    mov al, 'r'
    stosw

    pop di
    pop ax
    ret

; Pad to 1 sector
times 512 - ($ - $$) db 0
