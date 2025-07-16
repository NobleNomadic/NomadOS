; kernellib.asm - Loaded in by the kernel for handling reused functions
[org 0x0000]
[bits 16]

; Proof of concept library function
kernelLibEntry:
  ; Print L to the screen
  mov ah, 0x0E
  mov al, "L"
  int 0x10
  ; Now return to the kernel with a jump instruction
  jmp 0x1000:0x0000

; Pad library to 4 sectors
times 2048 - ($ - $$) db 0
