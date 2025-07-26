; help.asm - Shell program to list commands
[org 0x4000]
[bits 16]

%define NEWLIN 0x0D, 0x0A
%define STREND 0x0D, 0x0A, 0x00

; Entry point
helpEntry:
  ; Save registers
  pusha
  push ds
  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Use syscall 2 to print the help message
  mov si, helpMessage ; Message to print
  mov byte bl, 2      ; Syscall 2: print
  call 0x1000:0x0000  ; Call kernel

  ; Restore registers and return
  pop ds
  popa
  retf

; DATA SECTION
helpMessage db "[*] NomadOS 1.0", NEWLIN, "Commands:", NEWLIN, " help : Display this", NEWLIN, " clear: Clear the screen", NEWLIN, " fetch: Show system information", NEWLIN, " echo : Echo a message", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
