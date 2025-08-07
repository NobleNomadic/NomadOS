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
  ; CALL_kernel
  call 0x1000:0x0000

  ; Go to the main shell loop
  jmp shellLoop


; Commands - load program from disk and run
clearCommand:
  ; LOAD_clearprogram
  mov ch, 0
  mov cl, 8
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x2000
  mov ax, 0x2000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13
  ; CALL_clearprogram
  call 0x2000:0x2000
  jmp shellLoop

helpCommand:
  ; LOAD_helpprogram
  mov ch, 0
  mov cl, 9
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x2000
  mov ax, 0x2000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13
  ; CALL_helpprogram
  call 0x2000:0x2000
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

  ; COMMAND CHECKING
  ; Check for clear command with syscall 3
  mov si, buffer
  mov di, clearCmd
  mov byte bl, 3
  ; CALL_kernel
  call 0x1000:0x0000
  ; Reset segment after calling kernel
  mov bx, 0x2000
  mov ds, ax
  mov es, ax
  ; Check AX result
  cmp ax, 1
  je clearCommand

  ; Check for help command with syscall 3
  mov si, buffer
  mov di, helpCmd
  mov byte bl, 3
  ; CALL_kernel
  call 0x1000:0x0000
  ; Reset segment after calling kernel
  mov bx, 0x2000
  mov ds, ax
  mov es, ax
  ; Check AX result
  cmp ax, 1
  je helpCommand

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
helpCmd db "help", STREND

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
