; boot.asm - Initial bootloader
[org 0x7C00]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point
bootEntry:
  ; Setup data segments
  xor ax, ax
  mov ds, ax
  mov es, ax

  ; Clear screen
  mov ah, 0x00
  mov al, 0x03        ; 80x25 color text mode
  int 0x10

  ; Print string to show loaded
  mov si, bootEntryMsg
  call printString

  ; Move to loading the boot manager
  jmp loadBootManage

; Print the string stored in SI
printString:
  push ax     ; Push used registers
  push si
.printLoop
  lodsb          ; Load next
  or al, al      ; Check for null terminator
  jz .done       ; Finish if it is
  mov ah, 0x0E   ; BIOS print tty
  int 0x10       ; Interupt
  jmp .printLoop ; Continue loop
.done:
  pop si       ; Return used registers and return
  pop ax
  ret

loadBootManage:
  ; Memory arguments
  mov ax, 0x0000   ; Segment
  mov es, ax
  mov bx, 0x2000   ; Offset
  ; Disk arguments
  mov al, 4        ; Read 4 sectors
  mov ch, 0        ; Cylinder 0
  mov cl, 2        ; Sector 2 (read 2-5)
  mov dh, 0        ; Head 0
  mov dl, 0x00     ; Drive 0

  ; Call BIOS
  mov ah, 0x02     ; BIOS read sectors
  int 0x13

  ; Check for error
  jc .diskReadFail

  ; Jump to loaded address
  jmp 0x0000:0x2000

; Print error message and hang
.diskReadFail:
  mov si, failedLoadMsg
  call printString
  jmp hang

hang:
  jmp $


; Data section
bootEntryMsg db "[*] Bootable device found", STREND ; Print to show bootloader is bootable
failedLoadMsg db "[-] Disk read failed - 2", STREND ; Print if the disk failed to read

; Pad and add boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
