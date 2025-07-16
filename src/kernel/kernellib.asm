; kernellib.asm - Loaded in by the kernel for handling reused functions
[org 0x0000]
[bits 16]
jmp kernelLibEntry

; End of line macro with null terminator
%define STREND 0x0D, 0x0A, 0

; Proof of concept library function
kernelLibEntry:
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
  retf

.skipFirstRun:
  ; For subsequent calls, you would check what function is being requested
  ; and jump to the appropriate handler
  retf  ; Far return to return to calling segment

; Print function to display string in SI
printString:
  push ax           ; Push used registers
  push si
.printLoop:
  lodsb             ; Load next byte into AL
  or al, al         ; Check for null terminator
  jz .done          ; Finish function early if it is
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
libraryFirstRun db 1    ; Keep track of the first run of the library

; Strings
libraryFirstRunMsg db "[+] Kernel library initialised", STREND
libraryLoading db "[*] Running library setup", STREND

; Pad library to 4 sectors
times 2048 - ($ - $$) db 0
