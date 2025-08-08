; nnfs.asm - NobleNomadic file system kernel module (Syscall structure)
[org 0x1000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

nnfsEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Check syscall
  ; Syscall 0: Setup the module
  cmp bl, 0
  je .nnfsSetupHandler

  ; Return to caller
  pop ds
  popa
  retf

; Syscall handlers
.nnfsSetupHandler:
  ; Call function
  call nnfsSetup
  ; Return to caller
  popa
  pop ds
  retf

; Setup the file system
nnfsSetup:
  ; Call kernel and print message to show NNFS loaded
  mov si, nnfsEntryMsg ; Message to print
  mov byte bl, 4       ; Syscall 4: print from kernel segment
  ;CALL_kernel
  ret

; DATA SECTION
nnfsEntryMsg db "[+] NNFS mounted", STREND

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
