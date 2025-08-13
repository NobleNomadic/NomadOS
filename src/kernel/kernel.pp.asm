; kernel.asm - Main OS controller and process handler
[org 0x0000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point for kernel - setup the timer
kernelEntry:
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Check value of BL - 0 for entry, 1 for module manager program, 2 for user program
  ; Check for setup function
  cmp bl, 0
  je kernelStartup

  ; CHeck if kernel module manager is being requested to run
  cmp bl, 1
  je kernelModuleManager

  ; Check if user task is being requested to run
  cmp bl, 2
  je userTask

  ; No task requested, fatal
  ; JUMP_killscreen
  jmp 0x0000:0x1000

; Kernel entry function
kernelStartup:
  ; Print entry message
  mov si, kernelEntryMsg
  call printString

  ; Load kernel module manager and user task
  ; LOAD_kernelmodulemanager
  mov cx, 10
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x0000
  mov ax, 0x2000
  mov es, ax
  mov ah, 0x02
  mov al, 1
  int 0x13
  ; LOAD_userstart
  mov cx, 20
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x0000
  mov ax, 0x3000
  mov es, ax
  mov ah, 0x02
  mov al, 2
  int 0x13

  ; Run kernel module manager
  mov bl, 1
  ; JUMP_kernel
  jmp 0x1000:0x0000


; --- TASK REQUESTS ---
; Run kernel module manager
kernelModuleManager:
  ; JUMP_kernelmodulemanager
  jmp 0x2000:0x0000


; Run user program
userTask:
  ; JUMP_userstart
  jmp 0x3000:0x0000

; Utility functions
; printString: Print string from SI until null
printString:
  push ax                           ; Save AX
  push si                           ; Save SI
printLoop:
  lodsb                             ; AL = [SI++]
  or al, al                         ; Null terminator?
  jz printDone                      ; Yes → exit
  mov ah, 0x0E                      ; BIOS teletype
  int 0x10                          ; Print AL
  jmp printLoop                     ; Continue
printDone:
  pop si                            ; Restore SI
  pop ax                            ; Restore AX
  ret                               ; Return


; Backup hang function
hang:
  jmp $


; DATA SECTION
; Strings
kernelEntryMsg db "[*] Kernel loaded", STREND

; Pad to 4 sectors
times 2048 - ($ - $$) db 0
