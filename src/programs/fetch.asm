; fetch.asm - Print ASCII art and OS information
[org 0x2000]
[bits 16]

; Entry function
fetchEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print fetch message
  mov si, fetchMessage
  call printString

  ; Return to caller
  pop ds
  popa
  retf

; --- Utility functions ---
; Print string in SI
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
fetchMessage db "     ^        NomadOS 2.0", 0x0D,0x0A
             db "    .         Noble Kernel 2.0", 0x0D,0x0A
             db "   .          Noble Modules 1.0", 0x0D,0x0A
             db "  .           Noble Shell 2.0", 0x0D,0x0A
             db " .            Noble Bootloader 2.0", 0x0D,0x0A
             db "<           > Noble Util Programs 2.0", 0x0D, 0x0A, 0x00

; Pad to 1 sector
times 512 - ($ - $$) db 0
