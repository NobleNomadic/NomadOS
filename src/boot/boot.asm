; boot.asm - Initial bootloader
[org 0x7C00]
[bits 16]

; Bootloader entry
bootEntry:
  jmp $

; Pad to 512 bytes with boot sector
times 510 - ($ - $$) db 0
dw 0xAA55
