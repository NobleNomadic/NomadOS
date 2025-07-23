; bootmanage.asm - Second stage of bootloader to setup OS
[org 0x2000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point
bootManageEntry:
  ; Setup data
  mov ax, 0x0000
  mov ds, ax
  mov es, ax

  ; Print message to show boot manager loaded
  mov si, bootManageEntryMsg
  call printString

  ; Load the kernel and shell
  ; LOADING KERNEL
  ; Print message to show that kernel is loading
  mov si, loadingKernelMsg
  call printString
  ; Load the kernel
  call loadKernel

  ; LOADING SHELL
  ; Print message to show that shell is loading
  mov si, loadingShellMsg
  call printString
  ; Load the shell
  call loadShell
  
  ; Finally, give kernel code control with syscall 1
  mov byte bl, 1
  jmp 0x1000:0x0000


; Print function - Print each byte in SI
printString:
  push ax        ; Push used registers
  push si
.printLoop:
  lodsb          ; Load next byte into AL
  or al, al      ; Check for null terminator
  jz .done       ; Finish if it is
  mov ah, 0x0E   ; BIOS tty print
  int 0x10       ; Call BIOS
  jmp .printLoop ; Continue loop
.done:
  pop si         ; Return register state and return
  pop ax
  ret


; Load the kernel from disk into 0x1000:0x0000
loadKernel:
  ; Memory arguments
  mov ax, 0x1000  ; Segment
  mov es, ax
  mov bx, 0x0000  ; Offset
  ; Disk arguments
  mov al, 6       ; Read 6 sectors
  mov ch, 0       ; Cynlinder 0
  mov cl, 6       ; Sector 6 (6-12)
  mov dh, 0       ; Head 0
  mov dl, 0x00    ; Floppy drive

  ; Call BIOS interupt
  mov ah, 0x02    ; BIOS read sectors function
  int 0x13

  ; Error handling
  jc .readFail
  ret
; Carry flag check
.readFail:
  mov si, failedKernelLoadMsg
  call printString
  jmp hang


; Load the shell from disk into 0x2000:0x2000
loadShell:
  ; Memory arguments
  mov ax, 0x2000 ; Segment
  mov es, ax
  mov bx, 0x1000 ; Offset
  ; Disk arguments
  mov al, 4      ; Read 4 sectors
  mov ch, 0      ; Cylinder 0
  mov cl, 13     ; Sector 13 (13-16)
  mov dh, 0      ; Head 0
  mov dl, 0x00   ; Floppy drive

  ; Call BIOS interupt
  mov ah, 0x02
  int 0x13

  ; Error handling
  jc .readFail
  ret
; Carray flag check
.readFail:
  mov si, failedShellLoadMsg
  call printString
  jmp hang


; Backup hang function
hang:
  jmp $ 

; DATA SECTION
; Entry message
bootManageEntryMsg db "[+] Bootmanager loaded", STREND
; Loading alert messages
loadingKernelMsg db "[*] Loading kernel", STREND
loadingShellMsg db "[*] Loading shell", STREND
; Error messages
failedKernelLoadMsg db "[-] Error loading kernel - 3", STREND
failedShellLoadMsg db "[-] Error loading shell - 4", STREND


; Pad to 4 sectors
times 2048 - ($ - $$) db 0
