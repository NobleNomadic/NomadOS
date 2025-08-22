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
; flop.asm - Use syscall 1 on floppy driver module to interact with an external disk
[org 0x2000]
[bits 16]

flopEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Call syscall 1 in floppy driver
  mov byte bl, 1 ; Syscall 1
  ;CALL_floppydrivermodule

  ; Reset segment after return
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Wait for key input before resetting
  mov ah, 0x00
  int 0x16

  ; Reset system
  cli             ; disable interrupts
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00  ; reset stack to safe place
  jmp 0xFFFF:0x0000  ; BIOS reset entry point

; Pad to 1 sector
times 512 - ($ - $$) db 0
