; testfile.asm - Binary program written to sector 20 on disk for testing file operations
[org 0x3000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point
entry:
  ; Save registers
  pusha
  push ds

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print entry message
  mov si, entryMsg
  call printString

  ; Return to caller
  pop ds
  popa
  retf

; Print string function to print string in SI
printString:
  push ax        ; Push used registers
  push si
.printLoop:
  lodsb          ; Load byte from SI into AL
  or al, al      ; Check for null terminator
  jz .done       ; Conditional finish
  mov ah, 0x0E   ; Setup BIOS read sectors interupt
  int 0x10       ; Call interupt
  jmp .printLoop ; Continue loop
.done:
  pop si         ; Return registers and return
  pop ax
  ret

; DATA SECTION
entryMsg db "[DEBUG] File test program loaded", STREND ; Message for entry

; Pad to 1 sector
times 512 - ($ - $$) db 0
