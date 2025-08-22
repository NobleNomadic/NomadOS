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
; hex.asm - Print data stored in a memory address
[org 0x2000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

hexEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Run program logic
  call hexMain

  ; Return to caller
  pop ds
  popa
  retf

; --- Main program ---
hexMain:
  ; Print entry message
  mov si, hexEntryMessage
  call printString

  ; Prompt for linear address
  mov si, hexPrompt
  call printString

  ; Read 5 hex digits -> DX:AX (20 bits)
  call readHexInput20

  ; Compute segment:offset
  mov bx, ax            ; BX = low word
  mov dx, bx
  shr dx, 4             ; DX = segment low
  and bx, 0x0F          ; BX = offset
  shl dx, 12            ; bring in upper nibble from DX
  or dx, cx             ; DX = full segment

  ; Read byte
  mov es, dx
  mov al, [es:bx]

  ; Print result
  mov si, hexResult
  call printString
  call printHexByte

  ; Print newline
  mov ah, 0x0E
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10
  ret

; --- Utility functions ---
printString:
  push ax
  push si
.printLoop:
  lodsb
  or al, al
  jz .done
  mov ah, 0x0E
  int 0x10
  jmp .printLoop
.done:
  pop si
  pop ax
  ret

getKey:
  mov ah, 0x00
  int 0x16
  ret

putChar:
  mov ah, 0x0E
  int 0x10
  ret

; Read 5 hex digits into DX:AX
; Example input: 07C00 -> DX:AX = 0x0007C00
readHexInput20:
  xor ax, ax
  xor dx, dx
  mov cx, 5
.loop:
  call getKey
  cmp al, 0x0D
  je .done
  call putChar
  call hexToNibble
  ; shift DX:AX left 4
  shl ax, 4
  rcl dx, 1
  rcl dx, 1
  rcl dx, 1
  rcl dx, 1
  or al, dl
  loop .loop
.done:
  ret

hexToNibble:
  mov dl, al
  cmp dl, '0'
  jb .bad
  cmp dl, '9'
  jbe .digit
  cmp dl, 'A'
  jb .bad
  cmp dl, 'F'
  jbe .upper
  cmp dl, 'a'
  jb .bad
  cmp dl, 'f'
  ja .bad
  sub dl, 32
.upper:
  sub dl, 'A'-10
  ret
.digit:
  sub dl, '0'
  ret
.bad:
  xor dl, dl
  ret

printHexByte:
  push ax
  mov ah, al
  shr ah, 4
  and ah, 0x0F
  and al, 0x0F
  mov dl, ah
  call hexOut
  mov dl, al
  call hexOut
  pop ax
  ret

hexOut:
  cmp dl, 9
  jbe .digit
  add dl, 'A'-10
  jmp .out
.digit:
  add dl, '0'
.out:
  mov al, dl
  call putChar
  ret

; --- DATA SECTION ---
hexEntryMessage db "[*] Hex inspector loaded", STREND
hexPrompt db "Enter 5-digit hex linear address: ", STREND
hexResult db 0Dh,0Ah,"Value: ", 0x00 

; Pad to 1 sector
times 512 - ($ - $$) db 0

