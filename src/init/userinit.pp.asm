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

  ; Hang system
  jmp 0x0000:0x1000

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

; Backup hang
hang:
  jmp $


; DATA SECTION
userInitEntryMsg db "[+] User task init running", STREND

; Pad to 1 sector
times 512 - ($ - $$) db 0
