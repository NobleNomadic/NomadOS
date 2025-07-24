; shell.asm - Main userspace system for OS interaction
[org 0x2000]
; Macro for end of line and null terminator
%define STREND 0x0D, 0x0A, 0x00

shellEntry:
  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Use syscall 5 and print a char
  mov byte al, 'T'    ; Character to write
  mov bh, 0x5         ; Colour attribute
  mov dh, 10          ; X position
  mov dl, 10          ; Y position
  mov byte bl, 5      ; Syscall 5 for put char
  call 0x1000:0x0000
  
  ; Print shell entry message
  mov si, shellLoadedMsg ; Message to print
  mov byte bl, 2         ; Syscall 2 for print
  call 0x1000:0x0000     ; Kernel address
  
  ; Jump to the main shell loop
  jmp shellLoop

<<<<<<< HEAD

; Clear command - Reset video mode with BIOS
; In future, commands will load a file from the disk and run them, with this code being like a handler
clearCommand:
  ; Use BIOS interupt to clear screen
  mov ah, 0x00
  mov al, 0x03        ; 80x25 color text mode
  int 0x10            ; Call interupt

  ; Return to the shell loop
  jmp shellLoop


=======
>>>>>>> parent of 623615e (Clear command implementation)
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

<<<<<<< HEAD
  ; Check if the user typed "clear" to clear screen with syscall 5
  mov si, inputBuffer ; String 1
  mov di, clearCmd    ; String 2
  mov byte bl, 5      ; Syscall 5 for string comparison
  call 0x1000:0x0000  ; Call address of kernel
  ; Check AX value
  cmp al, 1
  je clearCommand
=======
  ; Check if the user typed "test" to test syscall 4
  mov si, inputBuffer ; Compare the input with the test string
  mov di, testString
  mov byte bl, 4      ; Syscall for string comparison
  call 0x1000:0x0000  ; Call kernel

  cmp ax, 1
  je .testGood

  mov si, testFail
  mov byte bl, 2
  call 0x1000:0x0000
>>>>>>> parent of 623615e (Clear command implementation)

  ; Continue shell loop
  jmp shellLoop

.testGood:
  mov si, testGood
  mov byte bl, 2
  call 0x1000:0x0000
  jmp shellLoop

; DATA SECTION
shellPrompt db "[>]", STREND ; Prompt to print each loop of shell
shellLoadedMsg db "[+] Shell loaded", STREND ; Debug message to prove shell loaded
inputBuffer times 256 db 0

<<<<<<< HEAD
=======
; STRING COMPARE TESTING
testString db "test", STREND ; String to check if the user typed
testGood db "test success", STREND
testFail db "test fail", STREND

>>>>>>> parent of 623615e (Clear command implementation)
; Pad shell to 4 sectors
times 2048 - ($ - $$) db 0
