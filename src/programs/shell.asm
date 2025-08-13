; shell.asm - Simple shell input/output handler
[org 0x1000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Shell entry point
shellEntry:
  ; Setup segment registers
  mov ax, 0x3000
  mov ds, ax
  mov es, ax

shellLoop:
  ; Print shell prompt
  mov si, shellPrompt
  call printString

  ; Read input line into inputBuffer
  mov si, inputBuffer
  call getInput

  ; Check if the command was "clear"
  mov si, inputBuffer
  mov di, clearCommandString
  call compareStrings
  je clearCommand

  ; Continue shell loop
  jmp shellLoop

; Print null-terminated string at DS:SI using BIOS teletype
printString:
  push ax
  push si
.printLoop:
  lodsb           ; Load byte from DS:SI into AL and increment SI
  or al, al       ; Check for null terminator
  jz .done
  mov ah, 0x0E    ; BIOS teletype output
  int 0x10
  jmp .printLoop
.done:
  pop si
  pop ax
  ret

; Get line of input into buffer pointed by DS:SI
; Leaves SI unchanged, uses DI internally to write bytes
; Supports backspace editing
getInput:
  push ax
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
  pop ax
  ret

; Compare the strings in SI and DI, result in AX
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


; COMMANDS
clearCommand:
  ; Clear the screen with BIOS print to reset video mode
  mov ah, 0x00
  mov al, 0x03
  int 0x10
  jmp shellLoop


; DATA SECTION
; Strings
shellPrompt db "[>]", STREND
; Buffer for getting input
inputBuffer times 256 db 0

; Command names
clearCommandString db "clear", STREND

; Pad to 2 sectors (512 bytes each)
times 1024 - ($ - $$) db 0
