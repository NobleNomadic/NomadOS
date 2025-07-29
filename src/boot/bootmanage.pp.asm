[org 0x1000]
[bits 16]

; Entry point
bootManageEntry:
  ; Setup segment
  mov ax, 0x0000
  mov ds, ax
  mov es, ax

  ; Print debug char
  mov ah, 0x0E
  mov al, "!"
  int 0x10

; Pad to 1 sector
times 512 - ($ - $$) db 0
