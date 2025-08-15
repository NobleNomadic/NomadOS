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
