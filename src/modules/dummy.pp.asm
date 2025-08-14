; dummy.asm - Example kernel module
[bits 16]

; Header (DM)
dw 0x444D

moduleEntry:
  ; Set segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Print debug message
  mov ah, 0x0E
  mov al, "["
  int 0x10
  mov al, "+"
  int 0x10
  mov al, "]"
  int 0x10
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10

  mov bl, 1
  jmp 0x1000:0x0000

; Pad to 1 sector
times 512 - ($ - $$) db 0
