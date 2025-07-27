; fetch.asm - Print ASCII art and system information
[org 0x4000]
[bits 16]

%define STREND 0x0D, 0x0A, 0x00

fetchEntry:
  ; Push used registers
  pusha
  push ds
  ; Setup segment
  mov ax, 0x2000
  mov ds, ax
  mov es, ax

  ; Print the fetch message
  mov si, fetchLine1 ; Message to print
  mov byte bl, 2     ; Syscall 2: print
  call 0x1000:0x0000 ; Call kernel
  mov si, fetchLine2 ; Message to print
  mov byte bl, 2     ; Syscall 2: print
  call 0x1000:0x0000 ; Call kernel
  mov si, fetchLine3 ; Message to print
  mov byte bl, 2     ; Syscall 2: print
  call 0x1000:0x0000 ; Call kernel
  mov si, fetchLine4 ; Message to print
  mov byte bl, 2     ; Syscall 2: print
  call 0x1000:0x0000 ; Call kernel
  mov si, fetchLine5 ; Message to print
  mov byte bl, 2     ; Syscall 2: print
  call 0x1000:0x0000 ; Call kernel
  mov si, fetchLine6 ; Message to print
  mov byte bl, 2     ; Syscall 2: print
  call 0x1000:0x0000 ; Call kernel
  mov si, fetchLine7 ; Message to print
  mov byte bl, 2     ; Syscall 2: print
  call 0x1000:0x0000 ; Call kernel

  ; Return register state and return to caller
  pop ds
  popa
  retf

fetchLine1 db STREND
fetchLine2 db "     ^     OS:         Nomad OS", STREND
fetchLine3 db "      *    Kernel:     Noble Kernel 1.0", STREND
fetchLine4 db "       *   Bootloader: Noble B Manager 0.9", STREND
fetchLine5 db "        *  Shell:      Noble Shell 1.0", STREND
fetchLine6 db "<        > Programs:   Noble Utils 1.0", STREND
fetchLine7 db STREND
