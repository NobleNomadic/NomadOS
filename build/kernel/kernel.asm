; kernel.asm - Main OS controller
[org 0x0000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

kernelEntry:
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Check syscall in BL
  cmp bl, 0
  je kernelSetup


; --- Syscalls ---
; Syscall 0: Setup kernel
kernelSetup:
  ; Print entry message, load modules, run shell
  ; Entry message
  mov si, kernelEntryMessage
  call printString

  ; Load modules
  call loadModule

  jmp hang

; Syscall 1: Load module
; CX = Disk sector to read from
; DH = Disk head to read from
; BH = Slot to load into
loadModule:
  cmp bh, 5
  ja .loadError

  ;Check if slot free
  mov si, bh
  mov al, [moduleFlags + si]
  cmp al, 1
  je .loadError

  ; Load segment for slot
  mov bx, bh
  shl bx, 1            ; index * 2 bytes
  mov ax, [moduleSegments + bx]

  ; Setup ES:BX= segment:0x0000 - defines where to load module
  mov es, ax
  mov bx, 0x0000       ; offset = 0

  ; Prepare BIOS call to read sectors
  mov ah, 0x02         ; BIOS read sectors
  mov al, 1            ; sectors count
  mov dh, 
  mov dl, 0x00         ; Disk 0: First floppy drive

  int 0x13             ; BIOS disk read

  ; Mark slot as occupied
  mov byte [moduleFlags + si], 1

  mov al, 1            ; success
  ret

.loadError:
   mov al, 0           ; failure
   ret

; --- Utility functions ---
; Print string in SI
printString:
  push ax        ; Preserve registers
  push si
.printLoop:
  lodsb          ; Load next byte into AL
  or al, al      ; Check for null terminator
  jz .done       ; Conditional finish
  mov ah, 0x0E   ; Setup BIOS tty print
  int 0x10       ; Call BIOS interupt
  jmp .printLoop ; Continue loop
.done:
  ; Return register state and return
  pop si
  pop ax
  ret

; Backup hang function
hang:
  jmp $

; DATA SECTION
; Strings
kernelEntryMessage db "[*] Kernel loaded", STREND ; Print on kernel setup

; Data for loaded modules
moduleFlags db 0, 0, 0, 0, 0

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
