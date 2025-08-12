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
  ; LOAD_killscreen
  mov cx, 6
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x1000
  mov ax, 0x0000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13

  ; Setup init systems for kernel
  ; LOAD_kerneltaskinit
  mov cx, 7
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x0000
  mov ax, 0x2000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13
  ; LOAD_usertaskinit
  mov cx, 8
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x0000
  mov ax, 0x3000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13

  ; Load the kernel
  ; LOAD_kernel
  mov cx, 2
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x0000
  mov ax, 0x1000
  mov es, ax
  mov ah, 0x02
  mov al, 4
  int 0x13
  ; JUMP_kernel
  jmp 0x1000:0x0000

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
