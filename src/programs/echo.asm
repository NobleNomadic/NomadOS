; echo.asm - Echo a simple message
[org 0x2000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

echoEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print message
  mov si, echoMessage
  call printString

  ; Return to caller
  pop ds
  popa
  retf
 
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
  int 0x10       ; Call interupt
  jmp .printLoop ; Continue loop
.done:
  pop si         ; Restore registers and return
  pop ax
  ret

; DATA SECTION
echoMessage db "[*] Success", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
