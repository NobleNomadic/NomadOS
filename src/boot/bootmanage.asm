; bootmanage.asm - Handle loading the kernel and safe mode
[bits 16]
[org 0x8000]

%define STREND 0x0D, 0x0A, 0

bootManageEntry:
  ; Print boot manage starting message
  mov si, kernelLoadMsg
  mov bl, 0x07
  call printString

  ; Here the code for choosing normal boot or safe mode would go
  ; For now, skip this and go straight to the kernel

  ; Load the kernel, don't go back
  jmp loadKernel

; Load Kernel. Start reading from sector 6 (bootloader (1) + bootmanager (5))
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
  call printString
  jmp hang

; Bootmanager implementation of print string
printString:
  push ax
  push si

.printLoop:
  lodsb
  or al, al
  jz .done
  mov ah, 0x0E
  int 0x10

  jmp .printLoop

.done:
  pop si
  pop ax
  ret

hang:
  jmp $


; Data
kernelLoadMsg db "[*] Boot manager starting kernel", STREND         ; Message to show kernel is being loaded
kernelLoadErr db "[!] Kernel load failed - 3", STREND ; Error message - kernel loading failed

; Pad Boot Manager to 2048 Bytes (4 sectors)
times 2048 - ($ - $$) db 0
