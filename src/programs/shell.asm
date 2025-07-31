; shell.asm - Default userspace entry program to provide a basic command line
[org 0x0000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Shell entry
shellEntry:
  ; Setup segment data
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Test syscall 1 in kernel
  mov si, shellEntryMsg
  mov byte bl, 1
  ;CALL_kernel

  ; Go to the main shell loop
  jmp shellLoop


; Commands - load program from disk and run
; For now, programs are coded into shell
clearCommand:
  ; Reset video mode with BIOS
  mov ah, 0x00
  mov al, 0x03
  int 0x10
  jmp shellLoop

shellLoop:
  ; Print prompt
  mov si, shellPromptMsg
  mov byte bl, 1
  ;CALL_kernel

  ; Get a line of input with syscall 2 into buffer
  mov si, buffer
  mov byte bl, 2
  ;CALL_kernel

  ; COMMAND CHECKING
  ; Check for clear command with syscall 3
  mov si, buffer
  mov di, clearCmd
  mov byte bl, 3
  ;CALL_kernel
  ; Reset segment after calling kernel
  mov bx, 0x2000
  mov ds, ax
  mov es, ax
  ; Check AX result
  cmp ax, 1
  je clearCommand

  ; Continue loop
  jmp shellLoop

; Fallback hang function
hang:
  jmp $

; DATA SECTION
; Strings
shellEntryMsg db "[+] Userpace syscalls setup", STREND ; Message to show that syscalls are working
shellPromptMsg db "[>]", STREND ; Shell prompt message

buffer times 256 db 0 ; Buffer for input

; Command names
clearCmd db "clear", STREND

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
