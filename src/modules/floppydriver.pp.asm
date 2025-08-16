; floppydriver.asm - Interact with file system on external disk
[org 0x1000]
[bits 16]
%define STREND 0x0D, 0x0A, 0x00

driverEntry:
  pusha
  push ds
  
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax
  
  ; Check syscall in BL 
  ; Syscall 0: Setup driver
  cmp bl, 0
  je .setupDriverHandler
  
  ; Syscall 1: IO with disk
  cmp bl, 1
  je .diskIOHandler
  
  ; Unknown syscall - return error or just return
  jmp .return

; Handler functions
.setupDriverHandler:
  ; Call function
  call setupDriver
  ; Jump to common return point
  jmp .return

.diskIOHandler:
  ; Call function
  call diskIO
  ; Jump to common return point
  jmp .return

.return:
  ; Common return point - restore stack and return
  pop ds
  popa
  retf

; --- Syscalls ---
; Syscall 0: Setup module
setupDriver:
  ; Print loaded message
  mov si, loadedMessage
  call printString
  ret

; Syscall 1: Perform read and write operations to file disk
diskIO:
  ; Get option for type of action
  mov ah, 0x00 ; Setup BIOS input
  int 0x16     ; Get input into AL
  ; Echo input
  mov ah, 0x0E
  int 0x10
  push ax      ; Save input
  
  ; Print newline after enter
  mov ah, 0x0E
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10
  
  ; Return input to AL
  pop ax
  
  ; Check if 1 was pressed
  cmp al, 0x31  ; ASCII '1'
  je .read
  cmp al, 0x32  ; ASCII '2'
  je .write
  
  ; Invalid input - return
  ret

; Read from disk into file biffer
.read:
  ; Show read is running
  mov si, readMessage
  call printString

  ; Use BIOS read sectors to load from disk
  mov ax, 0x2000 ; Segment
  mov es, ax
  mov bx, 0x4000 ; Offset
  ; Disk args
  mov al, 1      ; Read 1 sector
  mov dh, 0      ; Head 0
  mov dl, 0x01   ; Second floppy drive
  mov cx, 1      ; Sector 1

  ; Call interrupt
  mov ah, 0x02
  int 0x13
  jc .error

  mov ax, 0x2000
  mov ds, ax
  mov es, ax
  ; Print the string stored on the disk
  mov si, 0x4000
  call printString

  ; Restore segments
  mov ax, 0x1000
  mov ds, ax
  mov es, ax
  ret

; Copy data in file buffer onto disk
.write:
  mov si, writeMessage
  call printString

  ; Get input into file buffer
  call getInput

  ; Use BIOS to write data buffer to disk
  ; Memory args
  mov ax, 0x2000 ; Segment
  mov es, ax
  mov bx, 0x4000 ; Offset
  ; Disk args
  mov al, 1      ; Read 1 sector
  mov dh, 0      ; Head 0
  mov dl, 0x01   ; Second floppy drive
  mov cx, 1      ; Sector 1

  ; Call interupt
  mov ah, 0x03
  int 0x13
  jc .error
  ret

.error:
  mov si, diskOperationFailErr
  call printString
  ret

; --- Utility functions ---
; Print string stored in SI
printString:
  push ax        ; Preserve used registers
  push si
.printLoop:
  lodsb          ; Load next byte into al
  or al, al      ; Check for null terminator
  jz .done       ; Finish if null
  mov ah, 0x0E   ; Set BIOS tty print
  int 0x10       ; Call interrupt
  jmp .printLoop ; Continue loop
.done:
  pop si ; Return register state and finish
  pop ax
  ret

; Get input into data buffer
getInput:
  push ax
  push di

  ; Set destination segment:offset
  mov ax, 0x2000
  mov es, ax
  mov di, 0x4000

.inputLoop:
  mov ah, 0x00       ; Wait for keystroke
  int 0x16           ; AL = char

  cmp al, 0x0D       ; Enter pressed?
  je .done

  cmp al, 0x08       ; Backspace?
  jne .notBackspace

  ; Handle backspace if not at start of buffer
  cmp di, 0x4000
  je .inputLoop
  dec di

  ; Erase on screen
  mov ah, 0x0E
  mov al, 0x08
  int 0x10
  mov al, ' '
  int 0x10
  mov al, 0x08
  int 0x10
  jmp .inputLoop

.notBackspace:
  mov [es:di], al    ; Store char
  inc di
  ; Echo char
  mov ah, 0x0E
  int 0x10
  jmp .inputLoop

.done:
  ; Append CRLF + null terminator
  mov byte [es:di], 0x0D
  inc di
  mov byte [es:di], 0x0A
  inc di
  mov byte [es:di], 0
  ; Print newline
  mov ah, 0x0E
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10

  pop di
  pop ax
  ret


; DATA SECTION
; Strings
loadedMessage db "[*] Floppy driver loaded", STREND
readMessage db "[*] Running read operation", STREND
writeMessage db "[*] Running write operation", STREND
diskOperationFailErr db "[-] Disk operation failed", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
