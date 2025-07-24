; clear.asm - Shell program to clear the screen using BIOS interupts
[org 0x4000]
[bits 16]


clearEntry:
  pusha
  push ds
  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Reset video mode
  mov ah, 0x00
  mov al, 0x03 ; 80x25 color text mode
  int 0x10     ; Call interupt

  ; Return to caller
  pop ds
  popa
  retf

; Pad program to 1 sector
times 512 - ($ - $$) db 0
