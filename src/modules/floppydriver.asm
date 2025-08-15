; floppydriver.asm - Kernel module for interacting with an external floppy disk
[org 0x1000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry function
moduleEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Check syscall in BL
  ; Syscall 0, setup module
  cmp bl, 0
  je .fdSetupHandler

  ; Syscall 1, load from external disk
  cmp bl, 1
  je .loadFromDiskHandler

  ; Syscall 2, write data in buffer to disk
  cmp bl, 2
  je .writeToDiskHandler

  ; No valid syscall, return to shell
  pop ds
  popa
  ;JUMP_shell

; Syscall handlers
.fdSetupHandler:
  ; Call function
  call fdSetup
  ; Return to caller
  pop ds
  popa
  ;JUMP_shell

.loadFromDiskHandler:
  ; Call function
  call loadFromDisk
  ; Return to shell
  pop ds
  popa
  ;JUMP_shell

.writeToDiskHandler:
  ; Call function
  call writeToDisk
  ; Return to shell
  pop ds
  popa
  ;JUMP_shell

; --- Syscalls ---
; Syscall 0: Floppy driver setup
fdSetup:
  mov si, setupMessage
  call printString
  ret


; Syscall 1: Read data from external disk into memory
; CX = Sector to read from
; DH = Head to read from
loadFromDisk:
  ; Memory arguments for file data buffer
  mov ax, 0x2000 ; Segment
  mov es, ax
  mov bx, 0x4000 ; Offset
  ; Disk args
  mov al, 1      ; Read 1 sector
  mov dh, 0      ; Head 0
  mov ah, 0x02   ; Set BIOS read sectors
  mov dl, 0x01   ; Use second floppy disk

  int 0x13       ; Call interupt

; Error handling
  jc .error

  mov si, successLoad
  call printString
  ret
.error:
  ; Non fatal error loading from disk
  mov si, failedLoadErr
  call printString
  ret


; Syscall 2: Write data in file buffer to disk
; CX = Sector to write to
; DH = Head to write to
writeToDisk:
  ; Memory arguments for file buffer
  mov ax, 0x2000 ; Segment
  mov es, ax
  mov bx, 0x4000 ; Offset
  ; Disk args for write location
  mov al, 1      ; Write 1 sector
  mov dl, 0x01   ; Second floppy drive
  mov ah, 0x03   ; BIOS write to disk
  int 0x13       ; Call interupt

  ; Error handling
  jc .error

  mov si, successWrite 
  ret
.error:
  mov si, failedWriteErr
  call printString
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


; DATA SECTION
; Entry message
setupMessage db "[+] Floppy driver module setup", STREND

; Strings for read function
failedLoadErr db "[-] Floppy driver: Failed to load from external disk", STREND
successLoad db "[*] Floppy driver: Data loaded from disk", STREND

; Strings for write function
failedWriteErr db "[-] Floppy driver: Failed to write to file disk", STREND
successWrite db "[*] Floppy driver: Data written to floppy disk", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0

