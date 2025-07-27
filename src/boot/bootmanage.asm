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

  ; SAFE MODE CHECKING
  ; Print prompt
  mov si, safeModePrompt
  call printString
  ; Get input
  mov ah, 0x00
  int 0x16
  ; Check AL output for 'd'
  cmp al, 0x64
  je safeBoot ; If d pressed, then enter safe boot

  ; Safe mode was not called, continue
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
  mov bx, 0x2000 ; Offset
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



; SAFE BOOT
;;;;;;;;;;;;;;;;;
; Entry function
safeBoot:
  mov si, safeBootEntryMsg
  call printString
  jmp safeBootLoop

; Main command loop
safeBootLoop:
  ; Print options
  mov si, safeBootOptionsMsg
  call printString

  ; Get input
  mov ah, 0x00
  int 0x16

  ; Check options
  ; 1: Continue boot
  cmp al, 0x31
  je bootManageEntry

  ; 2: Load kernel into memory
  cmp al, 0x32
  je .loadKernelHandler

  ; 3: Jump to kernel
  cmp al, 0x33
  je .goToKernel

  ; 4: Load shell into memory
  cmp al, 0x34
  je .loadShellHandler

  ; 5: Jump directly to shell
  cmp al, 0x35
  je .goToShell

  ; Continue loop
  jmp safeBootLoop

; Load the kernel into memory with normal function
.loadKernelHandler:
  call loadKernel
  jmp safeBootLoop

; Jump straight to the kernel address
.goToKernel:
  mov byte bl, 1
  jmp 0x1000:0x0000

; Load the shell into memory
.loadShellHandler:
  call loadShell
  jmp safeBootLoop

; Jump straight to the shell address (0x2000:0x2000)
.goToShell:
  jmp 0x2000:0x2000

; Backup hang function
hang:
  jmp $ 

; DATA SECTION
; Entry message
bootManageEntryMsg db "[+] Bootmanager loaded", STREND
; Loading alert messages
loadingKernelMsg db "[*] Loading kernel", STREND
loadingShellMsg db "[*] Loading shell", STREND
; Prompt for safe mode
safeModePrompt db "[>] Press any key to boot normally, or 'd' for safe boot", STREND
; Error messages
failedKernelLoadMsg db "[-] Error loading kernel - 3", STREND
failedShellLoadMsg db "[-] Error loading shell - 4", STREND

; Safe boot strings
safeBootEntryMsg db "[*] ENTERING SAFE BOOT", STREND
safeBootOptionsMsg db "Safe boot commands: ", 0x0D, 0x0A, \
                      "  1: Continue regular boot", 0x0D, 0xA, \
                      "  2: Load kernel into memory", 0x0D, 0x0A, \
                      "  3: Jump directly to kernel address", 0x0D, 0x0A, \
                      "  4: Load shell into memory", 0x0D, 0x0A, \
                      "  5: Jump directly to shell", STREND

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
