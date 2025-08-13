; echo.asm - Echo a message
[org 0x2000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

echoEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x3000
  mov ds, ax
  mov es, ax

  ; Print message
  mov si, message
  call printString

  ; Return to caller
  pop ds
  popa
  retf


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
  ret

; DATA SECTION
message db "[*] Success", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
