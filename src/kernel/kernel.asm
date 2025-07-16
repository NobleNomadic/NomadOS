; kernel.asm - Main kernel system loop
[bits 16]
[org 0x0000]

; Force the code to use the kernelEntry as the main function
jmp kernelEntry

; Macro for newlines and null terminator for string ending
%define STREND 0x0D, 0x0A, 0

; Entry point
kernelEntry:
  ; Set up proper segment registers for kernel
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Prove kernel reached successfully with print
  mov si, kernelEntryMsg
  call printString

  call loadKernelLibrary
  
  ; After library is loaded, continue with normal kernel operations
  ; Here would normally start shell or other kernel operations
  jmp hang


; Print function to display string in SI
printString:
  push ax           ; Push used registers
  push si
.printLoop:
  lodsb             ; Load next byte into AL
  or al, al         ; Check for null terminator
  jz .done          ; Finish function early if it is
  mov ah, 0x0E      ; BIOS tty print
  int 0x10          ; Call BIOS interupt
  jmp .printLoop    ; Continue loop
.done:
  pop si            ; Return register state and finish function
  pop ax
  ret

; Load the kernel library into memory starting at sector 13 to 16
loadKernelLibrary:
  ; Check if library is already loaded
  cmp byte [libraryLoaded], 1
  je .alreadyLoaded

  mov si, kernelLibLoadStartingMsg
  call printString

  mov ax, 0x9000     ; Segment
  mov es, ax
  mov bx, 0x0000     ; Offset - Physical location in memory
  
  ; Parameters for disk
  mov ah, 0x02       ; BIOS read sectors
  mov al, 4          ; Read 4 sectors (sectors 13-16)
  mov ch, 0          ; Read from cylinder 0
  mov cl, 13         ; Start from sector 13 (1-indexed)
  mov dh, 0          ; Head 0
  mov dl, 0x00       ; Drive 0 (floppy)
  int 0x13           ; Call BIOS interrupt
  
  ; Check carry flag for failure
  jc .kernelLibraryReadFail
  
  ; Mark library as loaded
  mov byte [libraryLoaded], 1
  
  ; Call the library initialization
  ; Use far call to properly set up segments
  call 0x9000:0x0000

  ; Once returned, prove that code execution is being done by kernel
  mov si, kernelReturnAfterLibLoadMsg
  call printString

  ret

.alreadyLoaded:
  ; Library already loaded, just return
  ret

.kernelLibraryReadFail:
  mov ah, 0x0E ; Basic tty output
  mov al, 0x0A ; Newline
  int 0x10
  mov al, 0x0D ; Carriage return
  int 0x10
  mov al, "["  ; Load each character into AL then call BIOS print
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

; Strings
kernelEntryMsg db "[+] Kernel code execution reached", STREND
kernelLibLoadStartingMsg db "[*] Starting library load from kernel", STREND
kernelReturnAfterLibLoadMsg db "[+] Kernel main code execution returned", STREND

; Pad the kernel to 6 sectors
times 3072 - ($ - $$) db 0
