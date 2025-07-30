; shell.asm - Default userspace entry program to provide a basic command line
[org 0x0000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

shellEntry:
  ; Setup segment data
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Test syscall 1 in kernel
  mov si, shellEntryMsg
  mov byte bl, 1
  ; CALL_kernel
  call 0x1000:0x0000

  ; Go to the main shell loop
  jmp shellLoop


shellLoop:
  ; Print prompt
  mov si, shellPromptMsg
  mov byte bl, 1
  ; CALL_kernel
  call 0x1000:0x0000

  ; Get a line of input with syscall 2 into buffer
  mov si, buffer
  mov byte bl, 2
  ; CALL_kernel
  call 0x1000:0x0000

  ; Echo the message
  mov si, buffer
  mov byte bl, 1
  ; CALL_kernel
  call 0x1000:0x0000

  ; Continue loop
  jmp shellLoop

; Fallback hang function
hang:
  jmp $

; DATA SECTION
shellEntryMsg db "[+] Userpace syscalls setup", STREND ; Message to show that syscalls are working
shellPromptMsg db "[>]", STREND ; Shell prompt message

buffer times 256 db 0 ; Buffer for input

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
