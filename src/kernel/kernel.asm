[org 0x0000]

%define STREND 0x0D, 0x0A, 0x00

; Kernel entry
kernelEntry:
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Kernel code control reached message
  mov si, kernelEntryMessage
  call printString

  ; Hang system
  jmp hang


; Print function - Print the string stored in SI
printString:
  push ax        ; Push used registers
  push si
.printLoop:
  lodsb          ; Load next byte of string into AL
  or al, al      ; Check for null terminator
  jz .done       ; Conditional finish
  mov ah, 0x0E   ; BIOS tty print value
  int 0x10       ; Call interupt
  jmp .printLoop ; Continue loop
.done:
  pop si         ; Return used registers and return
  pop ax
  ret


; Backup hang function
hang:
  jmp $


; DATA SECTION
kernelEntryMsg db "[+] Kernel code execution reached", STREND


; Pad the kernel to 6 sectors
times 3072 - ($ - $$) db 0
