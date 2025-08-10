; shell.asm - Default userspace entry program to provide a basic command line
[org 0x0000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Shell entry
shellEntry:
  ; Setup segment data
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Test syscall 1 in kernel
  mov si, shellEntryMsg
  mov byte bl, 1
  ;CALL_kernel

  ; Go to the main shell loop
  jmp shellLoop

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


; Commands - load program from disk and run
clearCommand:
  ;LOAD_clearprogram
  ;CALL_clearprogram
  jmp shellLoop

helpCommand:
  ;LOAD_helpprogram
  ;CALL_helpprogram
  jmp shellLoop

fsInfoCommand:
  ; Use syscall 3 for print file system data
  mov byte bl, 3
  ;CALL_nnfsmodule
  jmp shellLoop

shellLoop:
  ; Print prompt
  mov si, shellPromptMsg
  mov byte bl, 1
  ;CALL_kernel

  ; Get a line of input with syscall 2 into buffer
  mov si, buffer
  mov byte bl, 2
  ;CALL_kernel

  ; COMMAND CHECKING
  ; Check for clear command
  push si
  push di
  mov si, buffer
  mov di, clearCmd
  call compareStrings
  pop di
  pop si
  ; Check AX result
  cmp ax, 1
  je clearCommand

  ; Check for help command
  push si
  push di
  mov si, buffer
  mov di, helpCmd
  call compareStrings
  pop di
  pop si
  ; Check AX result
  cmp ax, 1
  je helpCommand

  ; Check for request filesystem data
  push si
  push di
  mov si, buffer
  mov di, fsInfoCmd
  call compareStrings
  pop di
  pop si
  ; Check AX result
  cmp ax, 1
  je fsInfoCommand

  push ds
  ; Continue loop
  jmp shellLoop

; Fallback hang function
hang:
  jmp $

; DATA SECTION
; Strings
shellEntryMsg db "[+] Userpace syscalls setup", STREND ; Message to show that syscalls are working
shellPromptMsg db "[>]", STREND ; Shell prompt message

buffer times 256 db 0 ; Buffer for input

; Noble util Command names
clearCmd db "clear", STREND
helpCmd db "help", STREND

; Filesystem info command
fsInfoCmd db "ls", STREND

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
