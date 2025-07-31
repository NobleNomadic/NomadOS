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

  ; Clear screen by reseting the video mode
  mov ah, 0x00
  mov al, 0x03
  int 0x10

  ; Print entry message
  mov si, bootEntryMsg
  call printString

  ; Load next sector into memory
  ; LOAD_bootmanage
  mov ch, 0
  mov cl, 2
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x1000
  mov ax, 0x0000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13
  ; JUMP_bootmanage
  jmp 0x0000:0x1000

; Print the string stored in SI
printString:
  push ax      ; Push used registers
  push si
.printLoop:
  lodsb          ; Load next byte into AL
  or al, al      ;  Check for null terminator
  jz .done       ; Conditional finish
  mov ah, 0x0E   ; BIOS tty print
  int 0x10       ; Call BIOS
  jmp .printLoop ; Continue loop
.done:
  pop si       ; Return registers and return
  pop ax
  ret

; Fallback to hang function
hang:
  jmp $

; Data section
bootEntryMsg db "[*] Bootable device found", STREND ; Print on boot entry

; Pad to 512 bytes with boot sector
times 510 - ($ - $$) db 0
dw 0xAA55
