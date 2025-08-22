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
; boot.asm - Initial bootloader
[org 0x7C00]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point
bootEntry:
  ; Setup segment
  xor ax, ax
  mov ds, ax
  mov es, ax

  ; Clear screen by reseting video mode
  mov ah, 0x00
  mov al, 0x03
  int 0x10

  ; Print boot entry message
  mov si, bootEntryMsg
  call printString

  ; Load the kill program so OS can shutdown if needed
  ;LOAD_killscreen

  ; Load kernel and jump to it
  ;LOAD_kernel
  ;CALL_kernel

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

; Backup hang function
hang:
  jmp $

; DATA SECTION
bootEntryMsg db "[*] Bootable device found", STREND

; Pad to 512 byte with boot sector
times 510 - ($ - $$) db 0
dw 0xAA55
