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

  ; Check if this is the first run
  cmp byte [firstRun], 1
  je firstRunFunc

  ; List the names of the current files
  cmp bl, 1
  je .listFiles

  ; Find address from filename
  cmp bl, 2
  je .findFileAddress

  retf ; No syscall, return

; Go throug each file and print the filename using a modified print function
.listFiles:
  mov si, file1        ; Point to first file entry
  mov cx, 15           ; 15 files total

.printLoop:
  push cx              ; Save loop counter

  push si              ; Save current SI (filename pointer)
  mov byte bl, 1       ; Example: set syscall type for print
  call 0x9000:0x0000   ; Your print function at 9000:0000 expects SI = string
  pop si               ; Restore SI after call

  ; Move SI to next file entry
  mov cx, 0            ; Clear CX for counting bytes
.nextChar:
  mov al, [si]
  inc si
  inc cx
  cmp al, 0            ; Look for null-terminator
  jne .nextChar

  add si, 3            ; Skip 3 CHS address bytes after filename string

  pop cx               ; Restore loop counter
  loop .printLoop      ; Repeat until CX = 0

  retf                 ; Far return to calling segment
  

; Compare the string in SI to each filename
; If a match is found, return the CHS address in the correct address for int 0x13
.findFileAddress:
  push si               ; Save SI (input string pointer)
  mov di, file1         ; DI points to current file entry
  mov cx, 15            ; Total number of files

.searchLoop:
  push cx               ; Save loop counter for this round
  mov bx, si            ; BX = pointer to input string
  mov cx, 6             ; Compare first 6 chars (filenames padded to 6)

.compareChar:
  mov al, [bx]          ; Load char from input string
  mov dl, [di]          ; Load char from file entry
  cmp al, dl
  jne .noMatch          ; If chars not equal, move to next filename

  inc bx
  inc di
  loop .compareChar

  ; If code execution get here, it's a match — DI now points to STREND (past filename)
  add di, 3             ; Skip over STREND and reach CHS address bytes
  mov cl, [di]          ; Sector (CL)
  inc di
  mov ch, [di]          ; Cylinder (CH)
  inc di
  mov dh, [di]          ; Head (DH)

  pop cx                ; Restore loop counter
  pop si                ; Restore SI
  retf                  ; Return with CHS in registers

.noMatch:
  ; Move DI to next file entry
  ; Skip remaining filename chars if exited early
  add di, cx          ; cx = remaining chars not checked
  add di, 3           ; Skip over STREND (3 bytes)
  pop cx              ; Restore loop counter
  loop .searchLoop

  pop si
  retf

  retf

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

; Filename definitions
; Each filename has a name that can be printed to the console, and a CHS address
; Filenames starting with : are text files
file1  db "basic ", STREND, 1, 0, 14 ; Sector 50 - EXE
file2  db "ls    ", STREND, 1, 0, 15 ; Sector 51 - EXE
file3  db "view  ", STREND, 1, 0, 16 ; Sector 52 - EXE
file4  db "echo  ", STREND, 1, 0, 17 ; Sector 53 - EXE
file5  db "add   ", STREND, 1, 0, 18 ; Sector 54 - EXE
file6  db "write ", STREND, 1, 1, 1  ; Sector 55 - EXE
file7  db "delete", STREND, 1, 1, 2  ; Sector 56 - EXE
file8  db "clear ", STREND, 1, 1, 3  ; Sector 57 - EXE
file9  db ":     ", STREND, 1, 1, 4  ; Sector 58 - TXT
file10 db ":     ", STREND, 1, 1, 5  ; Sector 59 - TXT
file11 db ":     ", STREND, 1, 1, 6  ; Sector 60 - TXT
file12 db ":     ", STREND, 1, 1, 7  ; Sector 61 - TXT
file13 db ":     ", STREND, 1, 1, 8  ; Sector 62 - TXT
file14 db ":     ", STREND, 1, 1, 9  ; Sector 63 - TXT
file15 db ":     ", STREND, 1, 1, 10 ; Sector 64 - TXT

; Pad to 10 sectors
times 5120 - ($ - $$) db 0
