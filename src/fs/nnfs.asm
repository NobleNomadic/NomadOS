; nnfs.asm - Contains data for the filesystem
[org 0x2000]
[bits 16]

; Entry point
nnfsEntry:
  mov ax, 0x7000
  mov ds, ax
  mov es, ax

  ; Check if this is the first run of the file system
  cmp byte [firstRun], 1 ; Check if 1
  je firstRunFunc        ; If so, run the firstRun function

  retf


; This code runs on the first time the NNFS file is called
firstRunFunc:
  ; Make sure function doesn't run again
  mov byte [firstRun], 0

  ; Call syscall to print debug message
  mov byte bl, 1
  mov si, nnfsLoadedMsg
  call 0x9000:0x0000

  ; Return to entry code to allow retf
  jmp nnfsEntry

; Data section
; Data for first run of file system
firstRun db 1                                      ; Set to 0 after first run
nnfsLoadedMsg db "[+] NNFS Mounted", 0x0D, 0x0A, 0 ; Prove NNFS has loaded

; Data for each filename and their data
; Each file is an executable set of binary data that takes up 1 sector on the disk
; A file is either an EXE program which executes assembly instructions, or a text file
; Text files are still binary data, but when the file is called, operations can be peformed on the data it contains
; Programs are marked with ! and general text files marked with : at the start
fileA db "!basic", 0     ; Sector 50 - EXE - Basic program for debugging
fileB db "!ls   ", 0     ; Sector 51 - EXE - List current files
fileC db "!view ", 0     ; Sector 52 - EXE - View contents of chosen file
fileD db "!echo ", 0     ; Sector 53 - EXE - Echo a message
fileE db "!add  ", 0     ; Sector 54 - EXE - Append data to a file
fileF db "!write", 0     ; Sector 55 - EXE - Write data in a file
fileG db "!del  ", 0     ; Sector 56 - EXE - Reset a text filename and its contents
fileH db "!clear", 0     ; Sector 57 - EXE - Clear the screen
fileI db ":     ", 0     ; Sector 58 - TXT - Blank file
fileJ db ":     ", 0     ; Sector 59 - TXT - Blank file
fileK db ":     ", 0     ; Sector 60 - TXT - Blank file
fileL db ":     ", 0     ; Sector 61 - TXT - Blank file
fileM db ":     ", 0     ; Sector 62 - TXT - Blank file
fileN db ":     ", 0     ; Sector 63 - TXT - Blank file
fileO db ":     ", 0     ; Sector 64 - TXT - Blank file

; Pad to 1 sector
times 512 - ($ - $$) db 0
