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

  ; Load the kernel, kernel library and shell
  ; LOADING KERNEL
  ; Print message to show that kernel is loading
  mov si, loadingKernelMsg
  call printString
  ; Load the kernel
  call loadKernel
  ; Finally, give kernel code control
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


; Load the kernel from disk int 0x1000:0x0000
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

; Backup hang function
hang:
  jmp $ 

; DATA SECTION
bootManageEntryMsg db "[+] Bootmanager loaded", STREND
loadingKernelMsg db "[*] Loading kernel", STREND
failedKernelLoadMsg db "[-] Error loading kernel - 3", STREND


; Pad to 4 sectors
times 2048 - ($ - $$) db 0
