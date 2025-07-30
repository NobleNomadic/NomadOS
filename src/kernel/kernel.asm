; kernel.asm - Main syscall handler

%define STREND 0x0D, 0x0A, 0x00

; Entry point
kernelEntry:
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Check syscall by checking the value of BL
  cmp bl, 0              ; Syscall 0: Setup kernel
  je kernelSetup

  cmp bl, 1              ; Syscall 1: Print string for user programs in sector 0x2000
  je .printStringHandler

  cmp bl, 2              ; Syscall 2: Get a line of input for user programs
  je .getInputHandler

  ; No syscall, return far across segment
  retf


; SYSCALL HANDLERS
.printStringHandler:
  ; Move to correct segment (All user programs are stored in 0x2000:0xXXXX)
  mov ax, 0x2000
  mov ds, ax
  mov es, ax
  call printString ; Call print function
  retf             ; Return far across segment

.getInputHandler:
  ; Move to userland segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax
  call getInput
  retf

; SYSCALLS
; ;;;;;;;

; Syscall 0: Setup kernel
kernelSetup:
  push si                ; Push used registers

  ; Load any kernel modules here

  ; Use print function to display kernel entry message
  mov si, kernelEntryMsg
  call printString

  ; Give control to the first program in userland(Typically the shell)
  jmp 0x2000:0x0000


; Syscall 1: Print string in SI
printString:
  push ax        ; Push used registers
  push si
.printLoop:
  lodsb          ; Load next byte into AL
  or al, al      ; Check for null terminator
  jz .done       ; Conditional finish
  mov ah, 0x0E   ; BIOS tty
  int 0x10       ; Call BIOS
  jmp .printLoop ; Continue loop
.done:
  pop si         ; Return register state and return
  pop ax
  ret

; Syscall 2: Input function to return a string in SI
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

; Fallback hang function
hang:
  jmp $


; DATA SECTION
kernelEntryMsg db "[*] Kernel loaded successfully", STREND

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
