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
  cmp bl, 1                      ; Check if it is the syscall for print (note: bl not byte bl)
  je .handlePrintString          ; Run the handler function
  pop ds                         ; Clean up stack before returning
  retf                           ; Far return to return to calling segment

.handlePrintString:
  ; Restore the caller's DS so we can access their string
  pop ds
  call printString
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

; Function for the first run of the kernel library
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
