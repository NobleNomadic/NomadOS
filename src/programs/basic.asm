; basic.asm - Simple debug program
[org 0x9000]       ; Match the BX offset where we load it
[bits 16]

programEntry:
  ; Set up segments for this program
  mov ax, 0x2000
  mov ds, ax
  mov es, ax
  
  ; Set up for BIOS print
  mov ah, 0x0E     ; BIOS TTY output function
  
  ; Print "Works!"
  mov al, "["
  int 0x10
  mov al, "+"
  int 0x10  
  mov al, "]"
  int 0x10
  mov al, " "
  int 0x10
  mov al, "5"

  ; Newline
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10

  ; Make jump back to shell memory address
  ; SHELL NOT YET IMPLEMENTED
  jmp 0x4000:0x0000

; Pad to 512 bytes
times 512 - ($ - $$) db 0
