; userinit.asm - Code run by kernel to manage user task
[org 0x0000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

; Entry point
userInitEntry:
  ; Setup segment
  mov ax, 0x3000
  mov ds, ax
  mov es, ax

  ; Show kernel task is running
  mov si, userInitEntryMsg
  call printString

  ; Load the shell into memory
  ; LOAD_usershell
  mov cx, 20
  mov dh, 0
  mov dl, 0x00
  mov bx, 0x1000
  mov ax, 0x3000
  mov es, ax
  mov ah, 0x02
  mov al, 2
  int 0x13
  ; CALL_usershell
  call 0x3000:0x1000

  ; Hang system
  jmp hang

; printString: Print string from SI until null
printString:
  push ax                           ; Save AX
  push si                           ; Save SI
printLoop:
  lodsb                             ; AL = [SI++]
  or al, al                         ; Null terminator?
  jz printDone                      ; Conditional exit
  mov ah, 0x0E                      ; BIOS teletype
  int 0x10                          ; Print AL
  jmp printLoop                     ; Continue
printDone:
  pop si                            ; Restore SI
  pop ax                            ; Restore AX
  ret                               ; Return

; Backup hang
hang:
  jmp $


; DATA SECTION
userInitEntryMsg db "[+] User task init running", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
