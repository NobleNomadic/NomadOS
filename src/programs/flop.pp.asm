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
  ; CALL_floppydrivermodule
  call 0x1000:0x1000

  ; Reset segment after return
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Wait for key input before resetting
  mov ah, 0x00
  int 0x16

  ; Reset system
  cli             ; disable interrupts
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0x7C00  ; reset stack to safe place
  jmp 0xFFFF:0x0000  ; BIOS reset entry point

; Pad to 1 sector
times 512 - ($ - $$) db 0
