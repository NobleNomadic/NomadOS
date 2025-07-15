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
  mov bl, 0x07   ; White color
  call printString
  ; Load the kernel, code should not return from here
  jmp loadBootManage

; Load the second part of the bootloader from the disk into memory and give it control
loadBootManage:
  mov ax, 0x0000      ; Load segment 0x0000
  mov es, ax
  mov bx, 0x8000      ; Load to 0000:8000 (segment:offset = physical 0x8000)
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
  mov bl, 0x04
  call printString
  jmp hang

; Print a string with color
; SI = string pointer, BL = color attribute
printString:
  push ax    ; Push used registers to stack
  push bx
  push cx
  push dx
  push si
  
.printLoop:
  lodsb         ; Load the next character
  or al, al     ; Check if its a null terminator
  jz .done      ; Finish and exit function
  
  ; Handle newline characters properly
  cmp al, 0x0D  ; Carriage return
  je .printChar
  cmp al, 0x0A  ; Line feed
  je .printChar
  
  ; For normal characters, use write character with attribute
  mov ah, 0x09  ; BIOS: write character and attribute at cursor
  mov bh, 0     ; Page number
  mov cx, 1     ; Number of characters
  int 0x10      ; Call BIOS interrupt
  
  ; Move cursor forward
  mov ah, 0x03  ; Get cursor position
  mov bh, 0     ; Page number
  int 0x10      ; DH = row, DL = column
  inc dl        ; Move to next column
  mov ah, 0x02  ; Set cursor position
  mov bh, 0     ; Page number
  int 0x10
  
  jmp .printLoop

.printChar:
  ; For control characters (newlines), switch to TTY output and print them
  mov ah, 0x0E  ; BIOS TTY output
  mov bh, 0     ; Page number
  int 0x10      ; Call BIOS interrupt
  jmp .printLoop
; Done printing at null terminator, pop from stack and return to caller
.done:
  pop si        ; Return register state
  pop dx
  pop cx
  pop bx
  pop ax
  ret

; Hang program
hang:
  jmp $ ; Jump to the current location in memory

; DATA SECTION
msg db "[*] Bootable device found", STREND
diskErr db "[-] Disk read failed", STREND

; Boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
