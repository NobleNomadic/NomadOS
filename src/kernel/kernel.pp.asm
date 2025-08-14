; kernel.asm - Main OS controller
[org 0x0000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

kernelEntry:
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Check syscall in BL
  cmp bl, 0
  je kernelSetup

.badSyscall:
  ; Bad syscall, print error and kill system
  mov si, kernelBadSyscallErr
  call printString

  ; Delay to show message
  mov bx, 0x2FFF
.outerDelay:
  mov cx, 0xFF00
.innerDelay:
  loop .innerDelay
  dec bx
  jnz .outerDelay
  cli

  ; JUMP_killscreen
  jmp 0x0000:0x1000


; --- Syscalls ---
; Syscall 0: Setup kernel
kernelSetup:
  mov si, kernelEntryMessage
  call printString
  ; Example: load module from sector 11 into slot 0 (0x2000:0x0000)
  mov cl, 11           ; Sector number
  mov dh, 0            ; Head 0
  mov bh, 0            ; Slot 0
  call sysLoadModule
  jmp 0x2000:0x0000
  jmp hang


; Syscall 1: Load module with 2-byte header ID
; CL = Disk sector (1-based)
; DH = Disk head
; BH = Slot to load into (0..4)
sysLoadModule:
  push ax
  push bx
  push cx
  push dx
  push es
  push si
  ; ---------------------------
  ; ES:0000 = destination from table (moduleSegs[slot])
  ; ---------------------------
  mov bl, bh                  ; BL = slot index
  xor bh, bh
  mov si, moduleSegs
  add si, bx
  add si, bx                  ; word index
  mov es, [si]                ; ES = segment for this slot
  xor bx, bx                  ; BX = 0 offset
  ; ---------------------------
  ; BIOS read 1 sector -> ES:BX
  ; ---------------------------
  mov ah, 0x02                ; read sectors
  mov al, 1                   ; read 1 sector
  xor ch, ch                  ; Cylinder 0
  mov dl, 0                   ; First floppy drive
  int 0x13
  jc .error
  ; ---------------------------
  ; Store module's 2-byte ID in table
  ; moduleFlags[slot] = [ES:0000]
  ; ---------------------------
  mov bl, bh                  ; BL = slot (restore)
  xor bh, bh
  mov si, moduleFlags
  add si, bx
  add si, bx                  ; word index
  mov ax, [es:0x0000]         ; read module ID from loaded code
  mov [si], ax
  jmp .done
.error:
  mov si, moduleLoadFailErr
  call printString
  ; Nested delay
  mov bx, 0x2FFF
.outerDelay:
  mov cx, 0xFF00
.innerDelay:
  loop .innerDelay
  dec bx
  jnz .outerDelay
  cli
  ; JUMP_killscreen
  jmp 0x0000:0x1000

.done:
  pop si
  pop es
  pop dx
  pop cx
  pop bx
  pop ax
  ret

; --- Utility functions ---
; Print string in SI
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

; Backup hang function
hang:
  jmp $

; DATA SECTION
; Strings
kernelEntryMessage db "[*] Kernel loaded", STREND
moduleLoadFailErr db "[!] Module load fail", STREND
kernelBadSyscallErr db "[!] Bad syscall made", STREND

; Table of loaded module IDs (word array)
; 0x0000 = empty slot
moduleFlags dw 0x0000, 0x0000, 0x0000, 0x0000, 0x0000

; Segment addresses for each slot
moduleSegs  dw 0x2000, 0x3000, 0x4000, 0x5000, 0x6000

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
