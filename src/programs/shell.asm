; shell.asm - Default userspace entry program to provide a basic command line
[org 0x0000]

%define STREND 0x0D, 0x0A, 0x00

shellEntry:
  ; Setup segment data
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Test syscall 1 in kernel
  mov si, syscallTest
  mov byte bl, 1
  ;CALL_kernel


; Fallback hang function
hang:
  jmp $

; DATA SECTION
syscallTest db "[+] Kernel syscalls setup", STREND

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
