; boot.asm - Inital bootloader to load the boot manager
[bits 16]
[org 0x7C00]
; Macro for end of string with newline
%define STREND 0x0D, 0x0A, 0x00
; Entry point
start:
  ; Setup data
  mov ax, 0
  mov ds, ax
  ; Setup stack
  mov ss, ax
  mov sp, 0x7C00
  ; Clear the screen with BIOS interupt to reset mode
  mov ah, 0x00 ; Setup font and tty data
  mov al, 0x03
  int 0x10     ; Call BIOS interupt
  ; Print msg variable
  mov si, msg    ; Load message into SI
  call printString
  ; Load the kernel, code should not return from here
  jmp loadBootManage

; Load the second part of the bootloader from the disk into memory and give it control
loadBootManage:
  mov ax, 0x0000      ; Segment 0x0000
  mov es, ax
  mov bx, 0x8000      ; Load to 0000:9000 (physical 0x9000)
  mov ah, 0x02        ; BIOS: read sectors
  mov al, 4           ; Read 4 sectors
  mov ch, 0           ; Cylinder 0
  mov cl, 2           ; Start from sector 2 (sector 1 is boot)
  mov dh, 0           ; Head 0
  mov dl, 0x00        ; Drive 0 (floppy)
  int 0x13            ; Call BIOS
  jc .diskReadFail    ; Jump if carry (error)
  ; Fully jump to 0000:8000 and give that code control
  jmp 0x0000:0x8000

; Handle a failed disk read
.diskReadFail:
  mov si, diskErr
  call printString
  jmp hang

; Print a string stored in SI
printString:
  push ax
  push si

.printLoop:
  lodsb
  or al, al
  jz .done

  mov ah, 0x0E
  mov bh, 0     ; Page number (ignored)
  mov bl, 0x07  ; Text attribute (ignored by 0x0E)
  int 0x10

  jmp .printLoop

.done:
  pop si
  pop ax
  ret

; Hang program
hang:
  jmp $ ; Jump to the current location in memory

; DATA SECTION
msg db "[*] Bootable device found", STREND
diskErr db "[!] Disk read failed - 2", STREND

; Boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
