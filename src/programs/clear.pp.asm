; clear.asm - Clear the screen with BIOS interupt to reset video mode
[org 0x2000]
[bits 16]

entry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Clear screen by resetting video mode
  mov ah, 0x00
  mov al, 0x03
  int 0x10

  ; Return to caller
  pop ds
  popa
  retf

; Pad to 1 sector
times 512 - ($ - $$) db 0
