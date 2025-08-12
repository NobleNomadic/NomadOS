; kernel.asm - Main OS controller and process handler
[org 0x0000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point for kernel - setup the timer
kernelEntry:
  cli                              ; Disable interrupts during setup
  ; Setup segment
  mov ax, 0x1000
  mov ds, ax
  mov es, ax

  ; Print the entry message
  mov si, kernelEntryMsg
  call printString

  mov ss, ax                       ; SS = CS (stack segment)
  mov sp, 0x7FF0                   ; Temporary bootstrap stack

  ; Install the timer
  xor cx, cx                       ; CX = 0
  mov es, cx                       ; ES = 0 (IVT segment)
  mov word [es:0x20], timerHandler ; Set IRQ0 offset
  mov word [es:0x22], ax           ; Set IRQ0 segment
  mov ds, ax                       ; Restore DS = CS
  mov es, ax                       ; Restore ES = CS

  ; enable IRQ0
  in  al, 0x21                     ; Read PIC mask
  and al, 0xFE                     ; Clear bit0 to enable IRQ0
  out 0x21, al                     ; Write new PIC mask

  ; setup PIT
  mov al, 0x36                     ; PIT mode: channel0, lobyte/hibyte, mode 3
  out 0x43, al                     ; Send mode command
  mov ax, 65535                    ; ~100Hz divisor
  out 0x40, al                     ; Send low byte
  mov al, ah                       ; Get high byte
  out 0x40, al                     ; Send high byte

  mov byte [currentTask], 0        ; Start with task0

  ; initTask0
  mov ax, cs                       ; AX = CS
  mov ss, ax                       ; SS = CS
  mov sp, 0x2000                   ; Task0 stack pointer
  push word 0x0200                 ; FLAGS (IF=1)
  push word ax                     ; CS
  push word task0Entry             ; IP
  push word 0                      ; AX
  push word 0                      ; BX
  push word 0                      ; CX
  push word 0                      ; DX
  mov [task0SP], sp                ; Save SP for task0

  ; initTask1
  mov ss, ax                       ; SS = CS
  mov sp, 0x3000                   ; Task1 stack pointer
  push word 0x0200                 ; FLAGS
  push word ax                     ; CS
  push word task1Entry             ; IP
  push word 0                      ; AX
  push word 0                      ; BX
  push word 0                      ; CX
  push word 0                      ; DX
  mov [task1SP], sp                ; Save SP for task1

  ; startFirstTask
  cli                              ; Disable interrupts
  mov ss, ax                       ; SS = CS
  mov sp, [task0SP]                ; Load SP for task0
  pop dx                           ; Restore DX
  pop cx                           ; Restore CX
  pop bx                           ; Restore BX
  pop ax                           ; Restore AX
  sti                              ; Enable interrupts
  iret                             ; Jump to task0Entry

; Timer handler
timerHandler:
  cli                              ; Disable interrupts
  push ax                          ; Save AX
  push bx                          ; Save BX
  push cx                          ; Save CX
  push dx                          ; Save DX

  push cs                          ; Save CS to AX
  pop ax                           ; AX = CS
  mov ds, ax                       ; DS = CS

  cmp byte [currentTask], 0        ; Is currentTask = 0?
  je saveTask0                     ; Yes → save task0 SP
  mov [task1SP], sp                ; Save SP for task1
  jmp switchTask
saveTask0:
  mov [task0SP], sp                ; Save SP for task0

switchTask:
  xor byte [currentTask], 1        ; Flip between 0 and 1

  cmp byte [currentTask], 0        ; Check which task is active now
  je loadTask0
  mov ax, [task1SP]                 ; Load task1 SP
  mov sp, ax
  jmp afterLoad
loadTask0:
  mov ax, [task0SP]                 ; Load task0 SP
  mov sp, ax
afterLoad:

  mov al, 0x20                      ; PIC EOI command
  out 0x20, al                      ; Send EOI

  pop dx                            ; Restore DX
  pop cx                            ; Restore CX
  pop bx                            ; Restore BX
  pop ax                            ; Restore AX

  sti                               ; Enable interrupts
  iret                              ; Return to resumed task

; ---- TASKS ----
; Task 1 entry: Kernel task
task0Entry:
  ; Call kernel process entry
  call 0x2000:0x0000
; If code execution returns, a fatal error has occoured
.task0Crash:
  mov si, kernelKernelTaskFatal
  call printString
  jmp hang

; Task 1 Entry: User task
task1Entry:
  ; Call init system
  call 0x3000:0x0000
; If code returns from init system, fatal error
.task1Crash:
  mov si, kernelUserTaskFatal
  call printString
  jmp hang

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
currentTask db 1                   ; 0 = task0, 1 = task = 1
task0SP     dw 0                   ; Saved SP for task0
task1SP     dw 0                   ; Saved SP for task1

; Strings
kernelEntryMsg db "[*] Kernel loaded", STREND
kernelTaskRunningMsg db "[+] Kernel task running", STREND

; Fatal error messages
kernelUserTaskFatal db "[!] Fatal error: User task quit unexpectedly", STREND
kernelKernelTaskFatal db "[!] Fatal error: Kernel task quit unexpectedly", STREND

; Boot signature if needed
times 510-($-$$) db 0
dw 0xAA55
