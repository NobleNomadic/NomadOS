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
  call printKString

  ; Load the kernel library for syscalls
  call loadKernelLibrary
  ; Reset segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Print message to show library setup
  mov si, kernelReturnAfterLibLoadMsg
  call printKString

  ; Print a string using the external syscall system in kernellibrary
  ; Start with a debug notify message with local printKString
  mov si, kernelStartingSyscallTestMsg
  call printKString
  ; Use library print string
  mov byte bl, 1                       ; Syscall for print string
  mov si, kernelTestingSyscallTableMsg ; Message to print argument in SI
  call 0x9000:0x0000                   ; Call code at kernel library location, the kernel library will automatically handle the syscall

  ; FILE SYSTEM MOUNTING
  ; Message to show mounting
  mov si, kernelLoadingFileSystemMsg
  call printKString
  ; Load the file system table (sector 49) into memory
  mov ax, 0x7000    ; Segment
  mov es, ax
  mov bx, 0x2000    ; Offset
  ; Disk parameters
  mov ah, 0x02    ; BIOS read sectors from disk
  mov al, 1         ; Read 1 sector
  mov ch, 1         ; Cylinder 1
  mov cl, 4         ; Sector 4
  mov dh, 0         ; Head 0
  mov dl, 0x00      ; Floppy drive

  ; Call BIOS interupt
  int 0x13
  jc .loadFSFail

  ; Call code
  call 0x7000:0x2000

  ; Reset segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax
  
  ; Final kernel success complete message
  mov si, kernelFullyInitMsg
  call printKString


  ; MOVE TO SHELL
  ; Load the shell
  mov ax, 0x6000    ; Segment
  mov es, ax
  mov bx, 0x2000    ; Offset
  ; Disk parameters
  mov ah, 0x02      ; BIOS read sectors from disk
  mov al, 4         ; Read 2 sectors
  mov ch, 0         ; Cylinder 0
  mov cl, 17        ; Start from sector 17 (read 17-20)
  mov dh, 0         ; Head 0
  mov dl, 0x00      ; Floppy drive

  ; Call BIOS
  int 0x13

  ; Error handling
  jc .loadShellFail

  ; Give the shell control
  jmp 0x6000:0x2000

; Carry flag was set when shell loaded
.loadShellFail:
  ; Manual print of fatal error code 5
  mov ah, 0x0E
  mov al, "["
  int 0x10
  mov al, "!"
  int 0x10
  mov al, "]"
  int 0x10
  mov al, " "
  int 0x10
  mov al, "5"
  int 0x10
  ; Hang system
  jmp hang

.loadFSFail:
  ; Manual print of fatal error code 6
  mov ah, 0x0E
  mov al, "["
  int 0x10
  mov al, "!"
  int 0x10
  mov al, "]"
  int 0x10
  mov al, " "
  int 0x10
  mov al, "6"
  int 0x10
  ; Hang system
  jmp hang


; Print function to display string in SI
printKString:
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
  call printKString

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
  call 0x9000:0x0000
  ret

.alreadyLoaded:
  ; Library already loaded, just return
  ret

.kernelLibraryReadFail:
  mov ah, 0x0E ; Basic tty output. If there was an error, calling more functions should be avoided to minimise memory interaction
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
kernelEntryMsg db "[+] Kernel code execution reached", STREND                    ; String to prove kernel code is running
kernelLibLoadStartingMsg db "[*] Starting library load from kernel", STREND      ; Notify that kernel library function is running
kernelReturnAfterLibLoadMsg db "[+] Kernel main code execution returned", STREND ; Success, the library was loaded and code execution returned
kernelFullyInitMsg db "[+] Kernel init complete", STREND                         ; Final success message for kernel setup complete
kernelStartingSyscallTestMsg db "[*] Starting syscall test", STREND              ; Message to show syscall test is starting
kernelTestingSyscallTableMsg db "[+] Library syscalls test success", STREND      ; Test the syscalls library by printing this string using the kernel library
kernelLoadingFileSystemMsg db "[*] Kernel mounting file system", STREND          ; Print this just before kernel loads file system table into memory

buffer times 256 db 0

; Pad the kernel to 6 sectors
times 3072 - ($ - $$) db 0
