# NomadOS
NomadOS is a 16 bit command line based operating system written in x86 assembly.

## Structure
NomadOS has a bootloader, kernel, and shell.

The [bootloader](src/boot/) is made of [boot.asm](src/boot/boot.asm) and [bootmanage.asm](src/boot/bootmanage.asm).
Boot is the initial bootloader that is found by the BIOS to load the operating system.
The bootmanager is more complex and handles loading the shell and kernel into memory which can't be done by a bootloader limited to 512 bytes.

The [kernel](src/kernel/kernel.asm) provides a system for making syscalls.
When first jumped to by the bootmanager, it will run syscall 1, which is to give control to the shell.
If code is returned to the kernel, it will check the value of **BL** which contains a syscall value, and run the appropriate command such as printing a string.

The [shell](src/shell/) is the main userspace system and allows the user to type in commands to interact with the operating system.

## Disk Structure
| Sectors | File             |
|---------|------------------|
| 1       | `boot.asm`       |
| 2-5     | `bootmanage.asm` |
| 6-12    | `kernel.asm`     |
| 13-16   | `shell.asm`      |

## Syscalls
| Value | Purpose               | Arguments                        |
|-------|-----------------------|----------------------------------|
| 1     | Give control to shell | None                             |
| 2     | Print a string        | **SI**: String to print          |
| 3     | Get input             | **SI**: Variable to store output |

## Message Codes
| Code | Meaning                            |
|------|------------------------------------|
| 0    | Success                            |
| 1    | General failure                    |
| 2    | Boot.asm couldnt load boot manager |
| 3    | Boot manager failed to load kernel |
| 4    | Boot manager failed to load shell  |

## Memory Map
- **0x0000:0x7C00**: boot.asm
- **0x0000:0x2000**: bootmanage.asm
- **0x1000:0x0000**: kernel.asm
- **0x2000:0x2000**: shell.asm
