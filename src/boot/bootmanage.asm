; bootmanage.asm - Second stage of bootloader
[bits 16]
[org 0x8000]

; End a string with a newline and null terminator
%define STREND 0x0D, 0x0A, 0

; Entry point for the boot manager
bootManageEntry:
  jmp $

; Load sector from disk into RAM
; This is needed for loading the main kernel, and can be used manually for safe mode
load

; Data and variables

; Pad to 4 sectors (2048 bytes)
times 2048 - ($ - $$) db 0
