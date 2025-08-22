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
; time.asm - Get time data from module and print it to the screen as HH:MM
[org 0x2000]
[bits 16]
%define STREND 0x0D, 0x0A, 0x00

timeEntry:
  pusha
  push ds
  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax
  ; Print the time
  call printTime
  pop ds
  popa
  retf

; Print current time as HH:MM:SS AM/PM
printTime:
  push ax
  push bx
  push cx
  push dx
  
  ; Get time from time module
  mov byte bl, 1
  call 0x1000:0x2000
  
  ; Check if call was successful (CF should be clear)
  jc .error
  
  ; --- Print Hour (CH) ---
  mov al, ch
  call printBCDDigits
  
  ; --- Print ':' ---
  mov al, ':'
  call printChar
  
  ; --- Print Minute (CL) ---
  mov al, cl
  call printBCDDigits
  
  ; --- Print ':' ---
  mov al, ':'
  call printChar
  
  ; --- Print Second (DH) ---
  mov al, dh
  call printBCDDigits
  
  ; Check if PM bit is set (bit 7 of DL in 12-hour mode)
  test dl, 0x80
  jz .am
  mov si, pmMsg
  call printString
  jmp .done
.am:
  mov si, amMsg
  call printString
  
  jmp .done
  
.error:
  ; Print error message if BIOS call failed
  mov si, errorMsg
  call printString
  
.done:
  ; Final newline before returning
  mov ah, 0x0E
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10
  
  pop dx
  pop cx
  pop bx
  pop ax
  ret

; Print AL as two BCD digits (clean version)
printBCDDigits:
  push ax
  push bx
  
  ; Print upper nibble (tens digit)
  mov bl, al        ; Save original value
  shr al, 4         ; Get upper nibble
  add al, '0'       ; Convert to ASCII
  call printChar
  
  ; Print lower nibble (ones digit)
  mov al, bl        ; Restore original value
  and al, 0x0F      ; Get lower nibble
  add al, '0'       ; Convert to ASCII
  call printChar
  
  pop bx
  pop ax
  ret

; Print a single character from AL
printChar:
  push ax
  mov ah, 0x0E
  int 0x10
  pop ax
  ret

; Print string stored in SI
printString:
  push ax
  push si
.printLoop:
  lodsb          ; Load next byte into al
  or al, al      ; Check for null terminator
  jz .done       ; Finish if null
  mov ah, 0x0E   ; Set BIOS tty print
  int 0x10       ; Call interrupt
  jmp .printLoop ; Continue loop
.done:
  pop si
  pop ax
  ret

errorMsg db "TIME ERROR", 0
amMsg db " AM", 0
pmMsg db " PM", 0

; Pad to 1 sector
times 512 - ($ - $$) db 0
