; help.asm - Print help message
[org 0x2000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00
%define NEWLIN 0x0D, 0x0A

; Entry point
helpEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print the help string to the screen with syscall 1
  mov si, helpMsg ; Message to print
  mov byte bl, 1  ; Syscall 1 for print
  ; CALL_kernel
  call 0x1000:0x0000

  ; Return to caller
  pop ds
  popa
  retf


; DATA SECTION
; Help message
helpMsg db "Nomad OS util programs 0.1", NEWLIN, \
           "  help    - Print this message", NEWLIN, \
           "  clear   - Clear screen", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
