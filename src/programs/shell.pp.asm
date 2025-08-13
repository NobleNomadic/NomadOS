; shell.asm - Loaded by init system to provide a command line
[org 0x1000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Shell entry
shellEntry:
  ; Setup segment
  mov ax, 0x3000
  mov ds, ax
  mov es, ax

.shellLoop
  ; Print shell prompt
  mov si, shellPrompt
  call printString

  ; Get a line of input into string buffer
  mov si, inputBuffer
  call getInput

  ; Echo the message back
  mov si, inputBuffer
  call printString
  jmp .shellLoop

  jmp hang

printString:
  push ax ; Preserve used registers
  push si
.printLoop:
  lodsb          ; Load next byte into al
  or al, al      ; Check for null terminator
  jz .done       ; Finish if null
  mov ah, 0x0E   ; Set BIOS tty print
  int 0x10       ; Call interupt
  jmp .printLoop ; Continue loop
.done:
  pop si ; Return register state and finish
  pop ax          

 ; Get a line of input into the buffer in SI
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


; Backup hang function
hang:
  jmp $

; DATA SECTION
; Strings
shellPrompt db "[>]", STREND

; Buffer to store input
inputBuffer times 256 db 0

; Pad to 2 sectors
times 1024 - ($ - $$) db 0
