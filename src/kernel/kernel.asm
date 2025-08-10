; kernel.asm - Main OS controller
[org 0x0000]
[bits 16]

; Entry point
kernelEntry:
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Print debug entry message
  mov ah, 0x0E
  mov al, "!"
  int 0x10

  jmp hang

; Backup hang
hang:
  jmp $

; Pad kernel to 4 sectors
times 2048 - ($ - $$) db 0
