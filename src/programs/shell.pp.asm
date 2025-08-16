; shell.asm - Main loop and user program
[org 0x0000]
[bits 16]
%define STREND 0x0D, 0x0A, 0x00
shellEntry:
  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax
  
  ; Setup stack segment for safety
  mov ss, ax
  mov sp, 0x1000

; Main shell loop
shellLoop:
  ; Restore segments in case they got corrupted
  mov ax, 0x2000
  mov ds, ax
  mov es, ax
  
  ; Print prompt
  mov si, shellPromptMessage
  call printString
  
  ; Get input into input buffer
  mov si, inputBuffer
  call getInput
  
  ; CHECK COMMANDS
  ; Check for 'clear' command
  mov si, inputBuffer
  mov di, clearCommandString
  call compareStrings
  je clearCommand
  
  ; Check for echo command
  mov si, inputBuffer
  mov di, echoCommandString
  call compareStrings
  je echoCommand
  
  ; Check for reboot command
  mov si, inputBuffer
  mov di, rebootCommandString 
  call compareStrings
  je rebootCommand

  ; Check for flop command
  mov si, inputBuffer
  mov di, flopCommandString
  call compareStrings
  je flopCommand
  jmp shellLoop

; --- Utility functions ---
; Print string in SI
printString:
  push ax        ; Preserve used registers
  push si
.printLoop:
  lodsb          ; Load next byte from SI into AL
  or al, al      ; Check for null terminator
  jz .done       ; Finish if null
  mov ah, 0x0E   ; Setup BIOS tty print
  int 0x10       ; Call interrupt
  jmp .printLoop ; Continue loop
.done:
  pop si         ; Restore registers and return
  pop ax
  ret

; Compare strings in SI and DI, result in AX
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

; Get input into the buffer in SI
getInput:
  push ax
  push di
  push si
  mov di, si      ; DI = buffer pointer

.inputLoop:
  mov ah, 0x00    ; BIOS keyboard input (blocking)
  int 0x16
  cmp al, 0x0D    ; Enter key (CR)?
  je .done
  cmp al, 0x08    ; Backspace?
  jne .notBackspace
  ; Handle backspace if not at start of buffer
  cmp di, inputBuffer
  je .inputLoop   ; If at start, ignore backspace
  dec di          ; Move pointer back

  ; Erase character on screen (backspace, space, backspace to overwrite)
  mov ah, 0x0E
  mov al, 0x08
  int 0x10
  mov al, ' '
  int 0x10
  mov al, 0x08
  int 0x10

  jmp .inputLoop
.notBackspace:
  mov [di], al    ; Store character in buffer
  inc di
  ; Echo character
  mov ah, 0x0E
  int 0x10
  jmp .inputLoop
.done:
  mov byte [di], 0x0D    ; Carriage return
  inc di
  mov byte [di], 0x0A    ; Line feed
  inc di
  mov byte [di], 0x00    ; Null terminator
  ; Print newline manually
  mov ah, 0x0E
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10

  ; Restore register state and return
  pop si
  pop di
  pop ax
  ret

; Backup hang
hang:
  jmp $

; --- Commands ---
clearCommand:
  ; LOAD_clearprogram
  mov cx, 24
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x2000
  mov ax, 0x2000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13
  ; CALL_clearprogram
  call 0x2000:0x2000
  jmp shellLoop

echoCommand:
  ; LOAD_echoprogram
  mov cx, 25
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x2000
  mov ax, 0x2000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13
  ; CALL_echoprogram
  call 0x2000:0x2000
  jmp shellLoop

rebootCommand:
  ; LOAD_rebootprogram
  mov cx, 26
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x2000
  mov ax, 0x2000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13
  ; JUMP_rebootprogram
  jmp 0x2000:0x2000

flopCommand:
  ; Save segments before calling external modules
  push ds
  push es
  push ss
  ; Make sure that floppy driver is loaded
  ; LOAD_floppydrivermodule
  mov cx, 10
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x1000
  mov ax, 0x1000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13
  ; LOAD_flopprogram
  mov cx, 27
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x2000
  mov ax, 0x2000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13
  ; CALL_flopprogram
  call 0x2000:0x2000
  ; Restore segments after external calls
  pop ss
  pop es
  pop ds
  ; Clear input buffer to prevent corruption
  mov di, inputBuffer
  mov cx, 256
  xor al, al
  rep stosb
  jmp shellLoop

; DATA SECTION
; Strings
shellPromptMessage db "[>]", STREND

; Command string names
clearCommandString db "clear", STREND
echoCommandString db "echo", STREND
rebootCommandString db "reboot", STREND
flopCommandString db "flop", STREND

; Buffer for getting input
inputBuffer times 256 db 0

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
