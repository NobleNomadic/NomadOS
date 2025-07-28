; nnfs.asm - Noble Nomadic file system module (0x1000:0x1000)
[org 0x1000]

%define STREND 0x0D, 0x0A, 0x00

; Entry point
nnfsEntry:
  ; Setup segment data
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Check the BH syscall
  ; Syscall 1: Setup file system
  cmp bh, 1
  je .setupFSHandler

; Handler functions
; Setup file system
.setupFSHandler:
  call setupFS ; Call setup function
  retf         ; Return far across segment


; Setup file system
; Call kernel syscall 1 and
setupFS:
  ; Push used registers
  push bx
  ; Call syscall 2 for print
  mov si, firstRunMsg ; Message to print
  mov byte bl, 2      ; Syscall 2 for print
  call 0x1000:0x0000  ; Call kernel
  pop bx
  ret                 ; Return to handler

; DATA SECTION
; Strings for first run
firstRunMsg db "[+] NNFS Loaded", STREND

; Pad to 4 sectors
times 512 - ($ - $$) db 0
