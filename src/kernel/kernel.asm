[org 0x0000]
%define STREND 0x0D, 0x0A, 0x00

; Kernel entry, check for syscalls
kernelEntry:
  ; Save caller's segment registers
  push ds
  push es
  
  ; Setup kernel segments
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
  ; Syscall 4: Compare strings
  cmp bl, 4
  je .compareStringsHandler
  
  ; Restore caller's segments and return
  pop es
  pop ds
  retf

; HANDLER FUNCTIONS
; Print function handler
.printStringHandler:
  push bx            ; Preserve BX register
  push ds            ; Save current DS
  ; Set DS to caller's segment (0x2000 for shell)
  mov ax, 0x2000
  mov ds, ax
  call printString   ; Call the function
  pop ds             ; Restore DS
  pop bx             ; Restore BX register
  ; Restore caller's segments and return
  pop es
  pop ds
  retf               ; Far return across segment

; Input function handler
.getInputHandler:
  push bx            ; Preserve BX register
  push ds            ; Save current DS
  ; Set DS to caller's segment (0x2000 for shell)
  mov ax, 0x2000
  mov ds, ax
  call getInput
  pop ds             ; Restore DS
  pop bx             ; Restore BX register
  ; Restore caller's segments and return
  pop es
  pop ds
  retf

; Compare string handler
.compareStringsHandler:
  push bx            ; Preserve BX register
  push ds            ; Save current DS
  ; Set DS to callers segment (0x2000 for shell)
  mov ax, 0x2000
  mov ds, ax
  call compareStrings
  pop ds             ; Restore DS
  pop bx             ; Restore BX register
  ; Restore caller segments and return
  pop es
  pop ds
  retf

; Function that runs on kernel first run
kernelFirstRun:
  ; Print message to show kernel is running  
  ; Kernel code control reached message
  mov si, kernelEntryMsg
  call printString
  
  ; Restore segments before jumping to shell
  pop es
  pop ds
  
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
  int 0x10       ; Call interrupt
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
  int 0x16       ; Call BIOS interrupt
  
  ; Check if the byte written to AL was enter key (0x0D)
  cmp al, 0x0D
  je .done

  ; Write the character to SI
  mov [si], al
  inc si

  ; Echo the character back
  mov ah, 0x0E   ; BIOS tty print
  int 0x10       ; Call interrupt for tty print
  jmp .inputLoop ; Continue getting input
  
.done:
  ; Add newline and null terminator to SI
  mov byte [si], 0x0D
  inc si
  mov byte [si], 0x0A
  inc si
  mov byte [si], 0x00
  inc si

  ; Print newline after enter
  mov al, 0x0D
  mov ah, 0x0E
  int 0x10
  mov al, 0x0A
  int 0x10
  
  pop si         ; Return register state and return
  pop ax
  ret

; Compare strings function - Compare the strings in SI and DI, return 1 or 0 in AX
compareStrings:
    push cx            ; Preserve registers
    xor ax, ax         ; Default to AX = 0 (false)
.loop:
    lodsb              ; Load byte from [SI] into AL, advance SI
    cmp al, [di]       ; Compare AL with byte at [DI]
    jne .done          ; If not equal, exit (AX already 0)
    cmp al, 0          ; Check for null terminator
    je .equal          ; If both hit null, strings are equal
    inc di             ; Move to next byte in second string
    jmp .loop          ; Repeat
.equal:
    mov ax, 1          ; Strings match, set AX = 1
.done:
    pop cx             ; Restore registers
    ret


; Backup hang function
hang:
  jmp $

; DATA SECTION
kernelEntryMsg db "[+] Kernel code execution reached", STREND

; Pad the kernel to 6 sectors
times 3072 - ($ - $$) db 0
