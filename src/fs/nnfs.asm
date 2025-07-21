; nnfs.asm - NNFS Filesystem Entry and Data
[org 0x2000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00 ; End of string with newline

; Force entry to nnfsEntry function
jmp nnfsEntry

nnfsEntry:
  ; Setup segment
  mov ax, 0x7000
  mov ds, ax
  mov es, ax

  ; Check if this is first run
  cmp byte [firstRun], 1
  je firstRunFunc

  retf ; No syscall, return


; Function runs to print debug message after being loaded by kernel
firstRunFunc:
  mov byte [firstRun], 0
  mov byte bl, 1
  mov si, nnfsLoadedMsg
  call 0x9000:0x0000

  mov byte bl, 0
  jmp nnfsEntry

; Data Section
; Strings and data for first run
firstRun db 1
nnfsLoadedMsg db "[+] NNFS Mounted", STREND
