; kernellib.asm - Loaded in by the kernel for handling reused functions
[org 0x0000]
[bits 16]
jmp kernelLibEntry

; End of line macro with null terminator
%define STREND 0x0D, 0x0A, 0

; Entry to the library
kernelLibEntry:
  ; Save the caller's DS register so we can access their data later
  push ds
  
  ; Set up proper segments for library (should be called from 0x9000 segment)
  mov ax, 0x9000
  mov ds, ax
  mov es, ax
  
  ; Check if this is the first time the library is being run
  cmp byte[libraryFirstRun], 1   ; Compare first run variable
  jne .skipFirstRun
  
  ; Code here runs on the first library run
  mov si, libraryLoading
  call printString
  call libraryFirstRunSetup      ; Run the setup function for the kernel library
  pop ds                         ; Clean up stack
  retf

.skipFirstRun:
  ; Compare the value in BL with each syscall number
  ; Print syscall
  cmp bl, 1                      ; Check if it is the syscall for print
  je .handlePrintString          ; Run the handler function
  ; Input syscall
  cmp bl, 2                      ; Check BL for input syscall
  je .handleGetInput             ; Run handler for input

  ; Finish function if the syscall was not found
  pop ds                         ; Clean up stack before returning
  retf                           ; Far return across segment

; Handler functions. Call their related function, and then return across segment
; Print
.handlePrintString:
  ; Restore the caller's DS so we can access their string
  pop ds
  call printString
  retf

; Input
.handleGetInput:
  pop ds
  call getInput
  retf


; KERNEL LIBRARY SYSCALL FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Print function to display string in SI (assumes DS is set to caller's segment)
printString:
  push ax           ; Push used registers
  push si
.printLoop:
  lodsb             ; Load next byte into AL
  or al, al         ; Check for null terminator
  jz .done          ; Finish function now before character print if it is
  mov ah, 0x0E      ; BIOS tty print
  int 0x10          ; Call BIOS interupt
  jmp .printLoop    ; Continue loop
.done:
  pop si            ; Return register state and finish function
  pop ax
  ret


; Input to get a line of text from the user, and send it back to caller
getInput:
  push ax ; Push all used registers to stack
  push bx
  push cx
  push dx
  push si
.readChar:
  ; Read a character with BIOS, echo it, and store in buffer
  mov ah, 0x00      ; BIOS input
  int 0x16          ; Wait for keypress

  ; Check for enter
  cmp al, 0x0D      ; Hex code for enter
  je .done          ; Finish input

  ; Echo the character to tty
  mov ah, 0x0E
  int 0x10

  ; Store output in buffer
  mov [si], al
  inc si

  ; Continue loop
  jmp .readChar

.done:
  ; Add a carriage return and null terminator manually to the string
  mov al, 0x0D
  mov [si], al
  inc si
  mov al, 0x0A   ; Carriage return
  mov [si], al
  inc si
  mov al, 0x00   ; Null terminator
  mov [si], al

  mov ah, 0x0E   ; Manual newline after enter
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10

  pop si         ; Return used registers and return from function
  pop dx
  pop cx
  pop bx
  pop ax
  ret


; First run setup code
; This code runs when the library is called for the first time to print a debug message
libraryFirstRunSetup:
  ; Print the message to show that the library has loaded
  mov si, libraryFirstRunMsg
  call printString
  
  ; Set the first run var to 0 to prevent this from running in future
  mov byte [libraryFirstRun], 0
  
  ; Return to the entry function
  ret

; Data section
; Variables
libraryFirstRun db 1    ; Keep track of the first run of the library. Make 0 after the setup has run

; String messages
libraryFirstRunMsg db "[+] Kernel library initialised", STREND ; Positive success message for library loaded and setup
libraryLoading db "[*] Running library setup", STREND          ; Initial proof of library loading

; Pad library to 4 sectors
times 2048 - ($ - $$) db 0
