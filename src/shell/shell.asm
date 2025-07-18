;  shell.asm - This code is jumped to by the kernel and by other programs
; Controls loading programs into memory and executing them
; When programs return to this code, they simply jump to its memory address
[org 0x2000]
[bits 16]

jmp shellEntry

shellEntry:
  ; Setup segment
  mov ax, 0x6000
  mov ds, ax
  mov es, ax

  ; Proof of load
  mov ah, 0x0E
  mov al, ">"
  int 0x10
  jmp $

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
