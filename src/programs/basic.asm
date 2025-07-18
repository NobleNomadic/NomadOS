; basic.asm - Simple debug program
[org 0x9000]       ; Match the BX offset where we load it
[bits 16]

programEntry:
  pusha
  push ds
  ; Set up segments for this program
  mov ax, 0x2000
  mov ds, ax
  mov es, ax
  
  ; Set up for BIOS print
  mov ah, 0x0E     ; BIOS TTY output function
  
  ; Print "Works!"
  mov al, "W"
  int 0x10
  mov al, "o"
  int 0x10  
  mov al, "r"
  int 0x10
  mov al, "k"
  int 0x10
  mov al, "s"
  int 0x10
  mov al, "!"
  int 0x10
  
  ; Newline
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10

  pop ds
  popa
  retf

; Pad to 512 bytes
times 512 - ($ - $$) db 0
