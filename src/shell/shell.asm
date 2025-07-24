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

; Clear command - Load and run clear program
clearCommand:
  ; Load into memory
  ; Memory args
  mov ax, 0x2000 ; Segment
  mov es, ax
  mov bx, 0x4000 ; Offset
  ; Disk args
  mov al, 1      ; Read 1 sector
  mov ch, 0      ; Cylinder 0
  mov cl, 17     ; Sector 17
  mov dh, 0      ; Head 0
  mov dl, 0x00   ; Floppy drive
  ; Call BIOS
  mov ah, 0x02
  int 0x13

  ; Error handling
  jc programLoadFail

  ; Call loaded code
  call 0x2000:0x4000

  ; Return to the shell loop
  jmp shellLoop

; General error for when carry flag set during loading a program
programLoadFail:
  ; Print error message
  mov si, shellProgramLoadFail ; Error message string to print
  mov byte bl, 2               ; Use syscall 2 - print
  call 0x1000:0x0000           ; Call kernel
  ; Continue shell loop
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
shellProgramLoadFail db "[-] Error loading program - 5", STREND ; Carry flag set when loading program
; Input buffer
inputBuffer times 256 db 0
; Commands
clearCmd db "clear", STREND ; Command to clear screen

; Pad shell to 4 sectors
times 2048 - ($ - $$) db 0
