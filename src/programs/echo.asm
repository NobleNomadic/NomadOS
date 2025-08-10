; echo.asm - Repeat a message to stdout
[org 0x2000]
[bits 16]

%define STREND

; Entry
echoEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print prompt with syscall 1 to kernel
  mov si, shellPrompt ; String to print
  mov byte bl, 1      ; Syscall 1
  ;CALL_kernel

  ; Get input into buffer with syscall 2  
  mov si, buffer ; Buffer to get input into
  mov byte bl, 2 ; Syscall 2 for input
  ;CALL_kernel

  ; Echo the buffer back to screen with syscall 1
  mov si, buffer
  mov byte bl, 1
  ;CALL_kernel

  ; Return to caller
  popa
  pop ds
  retf

; DATA SECTION
buffer times 256 db 0 ; Buffer for input
shellPrompt db "[>] Enter text", STREND ; Prompt before input

; Pad to 1 sector
times 512 - ($ - $$) db 0
