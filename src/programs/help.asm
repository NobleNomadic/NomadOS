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
; help.asm - Print information
[org 0x2000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00
%define NEWLIN 0x0D, 0x0A

helpEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print help message
  mov si, helpMessage
  call printString

  ; Return to caller
  pop ds
  popa
  retf

; Print string stored in SI
printString:
  push ax ; Preserve used registers
  push si
.printLoop:
  lodsb          ; Load next byte into al
  or al, al      ; Check for null terminator
  jz .done       ; Finish if null
  mov ah, 0x0E   ; Set BIOS tty print
  int 0x10       ; Call interupt
  jmp .printLoop ; Continue loop
.done:
  pop si ; Return register state and finish
  pop ax
  ret

; DATA SECTION
helpMessage db "Noble Util Programs 2.0", NEWLIN, \
               " echo    - Display a message", NEWLIN, \
               " help    - Print this message", NEWLIN, \
               " clear   - Clear screen", NEWLIN, \
               " fetch   - Print info and ASCII art", NEWLIN, \
               " reboot  - Reboot system", NEWLIN, \
               " hex     - Print hex data of a location", NEWLIN, \
               " flop    - Interact with external disk", NEWLIN, \
               "           Type 1 to read the external disk", NEWLIN, \
               "           Type 2 to write a string to the external disk", NEWLIN, \
               "           Press a key to restart after running an action", NEWLIN, \
               " time    - Display time information", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
