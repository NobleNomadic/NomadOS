; echo.asm - Shell program to echo the text that is entered
[org 0x4000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point
echoEntry:
  ; Save registers
  pusha
  push ds
  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print prompt with syscall 2
  mov si, echoPrompt ; Message to print
  mov byte bl, 2     ; Syscall 2: print
  call 0x1000:0x0000 ; Call kernel

  ; Get a line of input into the input buffer using syscall 3
  mov si, inputBuffer ; Output to inputBuffer
  mov byte bl, 3      ; Syscall 3: get input
  call 0x1000:0x0000  ; Call kernel address

  ; Print the value of input buffer using syscall 2
  mov si, inputBuffer ; String to print
  mov byte bl, 2      ; Syscall 2: print
  call 0x1000:0x0000  ; Call kernel address

  ; Return register state and far return across segment back to shell
  pop ds
  popa
  retf

; DATA SECTION
inputBuffer times 256 db 0 ; Buffer to store input
echoPrompt db "[>] Enter text", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
