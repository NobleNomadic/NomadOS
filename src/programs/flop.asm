; flop.asm - Use syscall 1 on floppy driver module to interact with an external disk
[org 0x2000]
[bits 16]

flopEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Call syscall 1 in floppy driver
  mov byte bl, 1 ; Syscall 1
  ;CALL_floppydrivermodule

  ; Reset segment after return
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  popa
  pop ds
  retf

; Pad to 1 sector
times 512 - ($ - $$) db 0
