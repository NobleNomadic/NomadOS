;
; NomadOS - 16 bit hobby operating system
;
; Copyright (C) 2025 NobleNomadic
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, see <http://www.gnu.org/licenses/>.
;
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
