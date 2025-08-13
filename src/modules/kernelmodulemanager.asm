; kernelmodulemanager.asm - Main module manager for kernel modules
[org 0x2000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point
moduleManagerEntry:
  ; Here the module manager would load modules and initialise them - not implemented

  ; Request kernel to run the user program
  mov byte bl, 2
  ;JUMP_kernel

; Pad to 1 sector
times 512 - ($ - $$) db 0
