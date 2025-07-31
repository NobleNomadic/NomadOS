; bootmanage.asm - Second stage of bootloader
[org 0x1000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point
bootManageEntry:
  ; Setup segment
  mov ax, 0x0000
  mov ds, ax
  mov es, ax

  ; Print entry message
  mov si, bootManagerEntryMsg
  call printString

  ; Load the kernel into memory
  ; LOAD_kernel
  mov ch, 0
  mov cl, 3
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x0000
  mov ax, 0x1000
  mov es, ax
  mov ah, 0x02
  mov al, 4
  int 0x13

  ; Load the first userland program into memory (Typically shell)
  ; LOAD_shell
  mov ch, 0
  mov cl, 7
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x0000
  mov ax, 0x2000
  mov es, ax
  mov ah, 0x02
  mov al, 4
  int 0x13

  ; Give control to the kernel with syscall 0
  mov byte bl, 0
  ; JUMP_kernel
  jmp 0x1000:0x0000

; Print function to print the string in SI
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
  pop si         ; Return registers and return
  pop ax
  ret

; Fallback hang function
hang:
  jmp $

; DATA SECTION
bootManagerEntryMsg db "[*] Boot manager loaded", STREND
kernelSyscallTestMsg db "[+] Kernel syscalls setup", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
