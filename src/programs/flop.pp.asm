; flop.asm - External floppy disk interaction tool
[org 0x2000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00
%define NEWLIN 0x0D, 0x0A

flopEntry:
  pusha
  push ds

  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print entry message
  mov si, flopEntryMessage
  call printString
  mov si, inputPrompt
  call printString

  ; Get first input
  mov ah, 0x00
  int 0x16
  ; Save AL
  push ax

  ; Print newline after input
  mov ah, 0x0E
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10

  pop ax

  ; Check for 1 input
  cmp al, 0x31 
  je .readFromDiskHandler

  ; Check for 2 input
  cmp al, 0x32
  je .writeToDiskHandler

  mov ah, 0x0E
  mov al, "?"
  int 0x10

  ; Return to caller
  pop ds
  popa
  retf

; Handler functions
.readFromDiskHandler:
  ; Call function
  call readFromDisk
  ; Return to caller
  pop ds
  popa
  retf

.writeToDiskHandler:
  ; Call function
  call writeToDisk
  ; Return to caller
  pop ds
  popa
  retf

; Read from disk using floppy disk driver module syscall 1
readFromDisk:
  ; Call floppy driver syscall 1
  mov byte bl, 1 ; Syscall 1 in BL
  mov cx, 1      ; Sector 1
  mov dh, 0      ; Head 0
  ; CALL_floppydrivermodule
  call 0x1000:0x1000


; Write to disk with floppy disk driver syscall 2
writeToDisk:
  ; Call floppy driver syscall 2
  mov byte bl, 2
  mov cx, 1
  mov dh, 0
  ; CALL_floppydrivermodule
  call 0x1000:0x1000

; --- Utility functions ---
; Print string in SI
printString:
  push ax        ; Preserve used registers
  push si
.printLoop:
  lodsb          ; Load next byte from SI into AL
  or al, al      ; Check for null terminator
  jz .done       ; Finish if null
  mov ah, 0x0E   ; Setup BIOS tty print
  int 0x10       ; Call interupt
  jmp .printLoop ; Continue loop
.done:
  pop si         ; Restore registers and return
  pop ax
  ret

; DATA SECTION
; Entry message to display menu
flopEntryMessage db "[*] Flop disk tool", NEWLIN, \
                    "  1: Read from disk", NEWLIN, \
                    "  2: Write to disk", STREND

; Generic prompt for input
inputPrompt db "> ", 0x00

; Pad to 1 sector
times 512 - ($ - $$) db 0
