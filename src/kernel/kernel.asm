; kernel.asm - Main kernel system loop
[bits 16]
[org 0x0000]

; Force the code to use the kernelEntry as the main function
jmp kernelEntry


; Entry point
kernelEntry:
  mov ah, 0x0E
  mov al, "k"
  int 0x10
  call loadKernelLibrary
  jmp hang

; Load the kernel library into memory starting at sector 13 to 16
loadKernelLibrary:
  ; Check if library is already loaded
  cmp byte [libraryLoaded], 1
  je .alreadyLoaded
  
  ; Debug - print loading message
  mov ah, 0x0E
  mov al, "1"
  int 0x10
  
  mov ax, 0x9000     ; Segment
  mov es, ax
  mov bx, 0x0000     ; Offset - Physical location in memory
  
  ; Parameters for disk
  mov ah, 0x02       ; BIOS Read sectors
  mov al, 4          ; Read 4 sectors (sectors 13-16)
  mov ch, 0          ; Read from cylinder 0
  mov cl, 13         ; Start from sector 13
  mov dh, 0          ; Head 0
  mov dl, 0x00       ; Drive 0 (floppy)
  int 0x13           ; Call BIOS interrupt
  
  ; Check carry flag for failure
  jc .kernelLibraryReadFail
  
  ; Debug - print read success
  mov ah, 0x0E
  mov al, "2"
  int 0x10
  
  ; Test if library loaded by checking first byte
  mov ax, 0x9000
  mov es, ax
  mov al, [es:0x0000]
  mov ah, 0x0E
  int 0x10
  
  ; Mark library as loaded
  mov byte [libraryLoaded], 1

  ; Call the library to ensure it loaded
  jmp 0x9000:0x0000

  ; Debug - print after call
  mov ah, 0x0E
  mov al, "3"
  int 0x10
  
  ; Return to main kernel
  ret

.alreadyLoaded:
  ; Debug - print already loaded message
  mov ah, 0x0E
  mov al, "A"
  int 0x10
  ret
  
.kernelLibraryReadFail:
  mov ah, 0x0E ; Basic tty output
  mov al, 0x0A ; Newline
  int 0x10
  mov al, 0x0D ; Carriage return
  int 0x10
  mov al, "["  ; Load each character into al then call BIOS print
  int 0x10
  mov al, "!"
  int 0x10
  mov al, "]"
  int 0x10
  mov al, " "
  int 0x10
  mov al, "4"
  int 0x10
  jmp hang

; General hang function to freeze system
hang:
  jmp hang


; Data section
; Variables
libraryLoaded db 0    ; Keep track of if the library is loaded yet 0 = not loaded, 1 = loaded

; Pad the kernel to 6 sectors
times 3072 - ($ - $$) db 0
