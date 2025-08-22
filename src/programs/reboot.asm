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
; reboot.asm - Use BIOS int 0x19 to reboot system
[org 0x2000]
[bits 16]

rebootEntry:
  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Call BIOS interupt to reboot system
  mov ax, 0xFFFF
  int 0x19

; Backup hang
hang:
  jmp $

; Pad to 1 sector
times 512 - ($ - $$) db 0
