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

  ; Load user program into memory
  ; LOAD_shell
  mov cx, 20
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x0000
  mov ax, 0x2000
  mov es, ax
  mov ah, 0x02
  mov al, 4
  int 0x13

  ; Give control to shell
  ; JUMP_shell
  jmp 0x2000:0x0000

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
  push ax        ; Preserve used registers
  push si
.printLoop:
  lodsb          ; Load next byte from SI into AL
  or al, al      ; Check for null terminator
  jz .done       ; Finish if null
  mov ah, 0x0E   ; Setup BIOS tty print
  int 0x10       ; Call interupt
  jmp .printLoop ; Continue loop
.done:
  pop si         ; Restore registers and return
  pop ax
  ret


; Backup hang function
hang:
  jmp $

; DATA SECTION
; Strings
kernelEntryMessage db "[*] Kernel loaded", STREND
kernelBadSyscallErr db "[!] Bad syscall made", STREND

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
