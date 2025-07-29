; boot.asm - Initial bootloader
[org 0x7C00]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Bootloader entry
bootEntry:
  ; Setup segment
  mov ax, 0x0000
  mov ds, ax
  mov es, ax

  ; Print boot entry
  mov si, bootEntryMsg
  call printString

  ; Load next sector into memory and jump to it
  call loadNextSector
  jmp 0x0000:0x1000

; Print string stored in SI
printString:
  push ax        ; Save registers
  push si
.printLoop:
  lodsb          ; Load next byte into AL
  or al, al      ; Check for null terminator
  je .done       ; Conditional finish
  mov ah, 0x0E   ; BIOS tty print
  int 0x10
  jmp .printLoop ; Continue loop
.done:
  pop si     ; Return used registers and return
  pop ax
  ret

; Load boot manager into memory
loadNextSector:
  ; Memory args
  mov ax, 0x0000 ; Segment
  mov es, ax
  mov bx, 0x1000 ; Offset
  ; Disk args
  mov al, 1      ; Read 1 sector
  mov ch, 0      ; Cylinder 0
  mov cl, 2      ; Sector 2
  mov dh, 0      ; Head 0
  mov dl, 0x00   ; Floppy disk
  ; Call BIOS
  mov ah, 0x02   ; BIOS read sectors
  int 0x13       ; Call interupt

  ; Error handling
  je .loadFail

.loadFail:
  mov si, loadFailMsg
  call printString
  ret

; Backup hang
hang:
  jmp $


; DATA SECTION
bootEntryMsg db "[*] Bootable device found", STREND
loadFailMsg db "[-] Error loading next sector - 2", STREND

; Pad to 512 bytes with boot sector
times 510 - ($ - $$) db 0
dw 0xAA55
