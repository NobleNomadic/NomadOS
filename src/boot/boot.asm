; boot.asm - Initial bootloader
[org 0x7C00]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point
bootEntry:
  ; Setup segment
  mov ax, 0x0000
  mov ds, ax
  mov es, ax

  ; Clear screen by reseting video mode
  mov ah, 0x00
  mov al, 0x02
  int 0x10

  ; Print boot entry message
  mov si, bootEntryMsg
  call printString

  ; Load the kill program so OS can shutdown if needed
  ;LOAD_killscreen

  ; Load the kernel and request kernel setup
  ;LOAD_kernel
  mov bl, 0
  ;JUMP_kernel

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

; Backup hang function
hang:
  jmp $

; DATA SECTION
bootEntryMsg db "[*] Bootable device found", STREND

; Pad to 512 byte with boot sector
times 510 - ($ - $$) db 0
dw 0xAA55
