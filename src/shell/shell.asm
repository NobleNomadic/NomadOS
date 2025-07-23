; shell.asm - Main userspace system for OS interaction
[org 0x2000]

; Macro for end of line and null terminator
%define STREND 0x0A, 0x0D, 0x00

shellEntry:
  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print shell entry message
  mov si, shellLoadedMsg ; Message to print
  mov byte bl, 2         ; Syscall 2 for print
  call 1000:0x0000       ; Kernel address

  ; Jump to the main shell loop
  jmp shellLoop


; Main shell loop
; - Print prompt
; - Get input
; - Match with command
; - Run command
shellLoop:
  ; Use kernel syscall 2 to print string stored in SI
  mov si, shellprompt ; Value to print
  mov byte bl, 2      ; Syscall for print
  call 0x1000:0x0000  ; Kernel address

  ; Continue shell loop
  jmp shellLoop


; DATA SECTION
shellPrompt db "[>]", STREND ; Prompt to print each loop of shell
shellLoadedMsg db "[+] Shell loaded", STREND

; Pad shell to 4 bytes
times 2048 - ($ - $$) db 0
