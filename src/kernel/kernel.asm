[org 0x0000]

%define STREND 0x0D, 0x0A, 0x00

; Kernel entry, check for syscalls
kernelEntry:
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Check syscalls
  ; Syscall 1: Kernel first run
  cmp bl, 1
  je kernelFirstRun

  ; Syscall 2: Print string
  cmp bl, 2
  je .printStringHandler

  ; Syscall 3: Input
  cmp bl, 3
  je .getInputHandler

  ; Return far across segment to caller
  retf

; HANDLER FUNCTIONS
; Print function handler
.printStringHandler:
  call printString ; Call the function
  retf             ; Far return across segment

.getInputHandler:
  call getInput
  retf

; Function that runs on kernel first run
kernelFirstRun:
  ; Print message to show kernel is running  
  ; Kernel code control reached message
  mov si, kernelEntryMsg
  call printString

  ; Give control to the shell
  jmp 0x2000:0x2000


; Print function - Print the string stored in SI
printString:
  push ax        ; Push used registers
  push si
.printLoop:
  lodsb          ; Load next byte of string into AL
  or al, al      ; Check for null terminator
  jz .done       ; Conditional finish
  mov ah, 0x0E   ; BIOS tty print value
  int 0x10       ; Call interupt
  jmp .printLoop ; Continue loop
.done:
  pop si         ; Return used registers and return
  pop ax
  ret

; Input function - Get a line of input and write to the variable in SI
getInput:
  push ax        ; Push used registers
  push si
.inputLoop:
  ; Use BIOS for getting a key of input
  mov ah, 0x00   ; BIOS blocking input
  int 0x16       ; Call BIOS interupt

  ; Check if the byte written to AL was enter key (0x0D)
  cmp al, 0x0D
  je .done

  ; Echo the character back
  mov ah, 0x0E   ; BIOS tty print
  int 0x10       ; Call interupt for tty print
.done:
  pop ax         ; Return register state and return
  pop si
  ret

; Backup hang function
hang:
  jmp $


; DATA SECTION
kernelEntryMsg db "[+] Kernel code execution reached", STREND


; Pad the kernel to 6 sectors
times 3072 - ($ - $$) db 0
