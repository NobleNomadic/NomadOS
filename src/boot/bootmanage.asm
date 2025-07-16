[bits 16]
[org 0x8000]

%define STREND 0x0D, 0x0A, 0

bootManageEntry:
  ; Print boot manage starting message
  mov si, kernelLoadMsg
  mov bl, 0x07
  call printBootManageString

  ; Here the code for choosing normal boot or safe mode would go
  ; For now, skip this and go straight to the kernel

  ; Load the kernel, don't go back
  jmp loadKernel

; Load Kernel
loadKernel:
  mov ax, 0x1000     ; Segment 0x1000
  mov es, ax
  mov bx, 0x0000     ; Load to 1000:0000 (physical 0x10000)
  mov ah, 0x02       ; BIOS read sectors
  mov al, 10         ; Read 10 sectors
  mov ch, 0          ; Cylinder 0
  mov cl, 6          ; Sector 6 (1-indexed) - this reads from seek=5 (0-indexed)
  mov dh, 0          ; Head 0
  mov dl, 0x00       ; Floppy drive A
  int 0x13
  jc .kernelReadFail

  ; Jump to kernel at 1000:0000
  jmp 0x1000:0x0000

.kernelReadFail:
  ; Print a red error message then jump to hang
  mov si, kernelLoadErr
  mov bl, 0x04
  call printBootManageString
  jmp hang

; Bootmanager implementation of print string
; Identical to boot.asm print function
printBootManageString:
  push ax ; Push all registers to stack before starting
  push bx
  push cx
  push dx
  push si

.printLoop:
  lodsb          ; Load the next byte into al
  or al, al      ; Check for null byte
  jz .done       ; Conditional jump to done function if finished
  cmp al, 0x0D   ; Check for carriage return
  je .printChar  ; Use tty output instead
  cmp al, 0x0A   ; Check for newline
  je .printChar  ; Use tty output instead

  mov ah, 0x09   ; Set BIOS print
  mov bh, 0      ; Set data to print 1 character
  mov cx, 1
  int 0x10       ; Call BIOS interupt

  ; Adjust curser position manually after printing character
  mov ah, 0x03   ; BIOS: Move curser
  mov bh, 0
  int 0x10       ; Call first interupt
  inc dl
  mov ah, 0x02
  mov bh, 0
  int 0x10       ; Final interupt

  ; Run next iteration of the loop
  jmp .printLoop

.printChar:
  mov ah, 0x0E
  mov bh, 0
  int 0x10
  jmp .printLoop

.done:
  pop si
  pop dx
  pop cx
  pop bx
  pop ax
  ret

hang:
  jmp $


; Data
kernelLoadMsg db "[*] Loading kernel", STREND     ; Message to show kernel is being loaded
kernelLoadErr db "[!] Kernel load failed - 3", STREND ; Error message - kernel loading failed

; Pad Boot Manager to 2048 Bytes (4 sectors)
times 2048 - ($ - $$) db 0
