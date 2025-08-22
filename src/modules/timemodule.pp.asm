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
; timemodule.asm - Module for getting time data
[org 0x2000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

moduleEntry:
  push ds

  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Check syscall in BL
  ; Syscall 0: Setup module
  cmp bl, 0
  je .setupModuleHandler

  ; Syscall 1: Get time data
  cmp bl, 1
  je .getTimeDataHandler

  ; No valid syscall
  jmp .return

.setupModuleHandler:
  ; Call function
  call setupModule
  ; Return to caller
  jmp .return

.getTimeDataHandler:
  ; Call function
  call getTimeData
  ; Return to caller
  jmp .return

; Common return point
.return:
  pop ds
  retf

; --- Syscalls ---
; Syscall 0: Setup time module
setupModule:
  ; Print success message
  mov si, timeModuleSetupMessage
  call printString
  ret

; Syscall 1: Get time data
; Return CH: hour CL: minute DH: second
getTimeData:
  ; BIOS get time interupt
  mov ah, 0x02
  int 0x1A
  ret

; --- Utility functions ---
; Print string stored in SI
printString:
  push ax        ; Preserve used registers
  push si
.printLoop:
  lodsb          ; Load next byte into al
  or al, al      ; Check for null terminator
  jz .done       ; Finish if null
  mov ah, 0x0E   ; Set BIOS tty print
  int 0x10       ; Call interrupt
  jmp .printLoop ; Continue loop
.done:
  pop si ; Return register state and finish
  pop ax
  ret


; Data section
timeModuleSetupMessage db "[+] Time module loaded", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
