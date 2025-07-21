; shell.asm - This code is jumped to by the kernel and by other programs
; Controls loading programs into memory and executing them
; When programs return to this code, they simply jump to its memory address
[org 0x2000]
[bits 16]

; Newline and null terminator
%define STREND 0x0D, 0x0A, 0

; Force to go to shell entry
jmp shellEntry

shellEntry:
  ; Setup segment
  mov ax, 0x6000
  mov ds, ax
  mov es, ax

  ; Give control to the main loop
  jmp shellLoop


shellLoop:
  ; Reset the buffer to 0s before taking new input
  lea di, buffer      ; Load address of buffer
  mov cx, 256         ; Size of the buffer
  mov al, 0           ; Value to fill (zero)
  rep stosb           ; Repeat STOSB to set the entire buffer to 0

  ; Print the prompt
  mov si, shellPrompt ; Prompt message for the shell
  mov byte bl, 1      ; Kernel library syscall
  call 0x9000:0x0000  ; Call the kernel library

  ; Get a line of input into the buffer
  mov si, buffer      ; Output variable
  mov byte bl, 2      ; Input syscall
  call 0x9000:0x0000  ; Make syscall

  ; SI now contains a line of input
  ; Use file index to find CHS address of matching file
  mov byte bl, 2      ; Find address syscall
  call 0x7000:0x2000  ; Address of file index

  ; Use int 0x13 to load CHS address into memory
  mov ah, 0x4000      ; Segment to load program
  mov es, ax
  mov bx, 0x2000      ; Offset
  mov ah, 0x02        ; BIOS read sectors from disk
  mov al, 1           ; Read 1 sector
  mov dl, 0x00        ; Floppy drive

  ; Call BIOS
  int 0x13

  ; Call the loaded code
  call 0x4000:0x2000
  ; Reset the segment data
  mov ax, 0x6000
  mov ds, ax
  mov es, ax

  ; Continue loop
  jmp shellLoop

; Data section
; Buffer for getting input
buffer times 256 db 0

; Strings
shellPrompt db "[>]", STREND   ; Prompt printed before input

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
