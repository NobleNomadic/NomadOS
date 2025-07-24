; shell.asm - Main userspace system for OS interaction
[org 0x2000]
; Macro for end of line and null terminator
%define STREND 0x0D, 0x0A, 0x00

shellEntry:
  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print shell entry message
  mov si, shellLoadedMsg ; Message to print
  mov byte bl, 2         ; Syscall 2 for print
  call 0x1000:0x0000     ; Kernel address
  
  ; Jump to the main shell loop
  jmp shellLoop

; Clear command - Reset video mode with BIOS
; In future, commands will load a file from the disk and run them, with this code being like a handler
clearCommand:
  ; Use BIOS interupt to clear screen
  mov ah, 0x00
  mov al, 0x03        ; 80x25 color text mode
  int 0x10            ; Call interupt

  ; Return to the shell loop
  jmp shellLoop


; Main shell loop
; - Print prompt
; - Get input
; - Match with command
; - Run command
shellLoop:
  ; Use kernel syscall 2 to print string stored in SI
  mov si, shellPrompt ; Value to print
  mov byte bl, 2      ; Syscall for print
  call 0x1000:0x0000  ; Kernel address

  ; Syscall 3 for input
  mov si, inputBuffer ; Get input into the inputBuffer variable
  mov byte bl, 3      ; Use syscall 3 for input
  call 0x1000:0x0000  ; Call kernel address

  ; Check if the user typed "clear"
  mov si, inputBuffer ; Compare the input with the command string
  mov di, clearCmd    ; String to compare against
  mov byte bl, 4      ; Syscall for string comparison
  call 0x1000:0x0000  ; Call kernel

  ; Check result in AX
  cmp ax, 1
  je clearCommand

  ; Continue shell loop
  jmp shellLoop

; DATA SECTION
; Strings
shellPrompt db "[>]", STREND ; Prompt to print each loop of shell
shellLoadedMsg db "[+] Shell loaded", STREND ; Debug message to prove shell loaded
; Input buffer
inputBuffer times 256 db 0
; Commands
clearCmd db "clear", STREND ; Command to clear screen

; Pad shell to 4 sectors
times 2048 - ($ - $$) db 0
