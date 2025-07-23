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

; STRING COMPARE TESTING
testString db "test", STREND ; String to check if the user typed
testGood db "test success", STREND
testFail db "test fail", STREND

; Pad shell to 4 sectors
times 2048 - ($ - $$) db 0
