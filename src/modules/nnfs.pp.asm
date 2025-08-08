; nnfs.asm - NobleNomadic file system kernel module (Syscall structure)
[org 0x1000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00
%define NEWLIN 0x0D, 0x0A

; How NNFS works
; This kernel module will contain functions to automate interacting with sectors 20-29 on the floppy disk the OS runs from
; It provides syscalls to write data to these sectors, load them into memory, and get module information

; Entry function
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

  ; Syscall 1: Load file into memory
  cmp bl, 1
  je .loadFileHandler

  ; Syscall 2: Write to a file on the disk
  cmp bl, 2
  je .writeToFileHandler

  ; Return to caller
  pop ds
  popa
  retf

; Syscall handlers
.nnfsSetupHandler:
  ; Call function
  call nnfsSetup
  ; Return to caller
  pop ds
  popa
  retf
.loadFileHandler:
  ; Call function
  call loadFile
  ; Return to caller
  pop ds
  popa
  retf
.writeToFileHandler:
  ; Call function
  call writeToFile
  ; Return to caller
  pop ds
  popa
  retf

; Syscall 0: Setup the file system
nnfsSetup:
  ; Call kernel and print message to show NNFS loaded
  mov si, nnfsEntryMsg ; Message to print
  mov byte bl, 4       ; Syscall 4: print from kernel segment
  ; CALL_kernel
  call 0x1000:0x0000
  ret

; Syscall 1: Load a file into memory
; DX = File number to load (20-29)
loadFile:
  ; Move to userland segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Arguments for disk read
  mov cx, dx     ; Sector to read
  mov dh, 0      ; Head 0
  mov dl, 0x00   ; Floppy drive
  ; Load files into memory at 0x2000:0x3000 after user program
  mov bx, 0x3000 ; Offset
  mov ax, 0x2000 ; Segment buffer
  mov es, ax     ; Segment
  mov ah, 0x02   ; BIOS read sectors function
  mov al, 1      ; Read 1 sector

  ; Call interupt
  int 0x13
  ret

; Syscall 2: Write to a file on the disk
; DX = File number (20-29)
; Set the data to 0x2000:0x3000 to the data that is going to be written to the disk
writeToFile:
  ; Move to userland segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax
  
  ; Setup buffer location
  mov ax, 0x2000
  mov es, ax
  mov bx, 0x3000    ; Buffer offset
  
  ; BIOS disk write parameters
  mov ah, 0x03      ; BIOS write sectors function
  mov al, 1         ; Number of sectors to write
  mov ch, 0         ; Cylinder 0
  mov cl, dl        ; Sector number (from DX low byte)
  mov dh, 0         ; Head 0
  mov dl, 0x00      ; Drive number (floppy)
  
  ; Call interrupt
  int 0x13
  ret


; DATA SECTION
nnfsEntryMsg db "[+] NNFS mounted", STREND ; Message to print on syscall 0

nnfsDataMsg db "NNFS module mounted at 0x1000:0x1000", NEWLIN, \
               "Sector"

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
