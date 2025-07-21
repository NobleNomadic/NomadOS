# Nomad OS
A simple 16 bit operating system with a basic command line.
It uses simple floppy disks to boot, and store files.

## OS Structure
NomadOS is made of **bootloader**, **kernel**, **kernel library**, **shell**, and **files**.

The bootloader is made of `boot.asm`, and `bootmanage.asm`.
The `boot.asm` file contains the boot signature and will load `bootmanage.asm`, removing the 512 byte restriction of initial bootloaders.
The bootmanager also has a system for entering a debugging mode.
In the future, this will also allow you to manually load parts of the OS safely and print all operations being done.

The kernel is designed to setup the operating system so that programs can be run.
It loads the kernel library, the filesystem, and the shell, before giving code execution control to the shell.

The kernel library is located at 0x9000:0x0000 and is used to make syscalls and peform repetitive operations quickly.
It is useful for uer programs that have limited file size and don't have room for their own print or input function implementation.

The filesystem is made of a file loaded into memory by the kernel which contains data for the names of each file on the system.
It also has its own syscalls which can provide information about the files.

The shell provides a set of commands to load and execute simple oeprations for interacting with the file system and OS.

## Structure on Disk
| Sectors      | Purpose               |
|--------------|-----------------------|
| 1            | `boot.asm`            |
| 2–5          | `bootmanage.asm`      |
| 6–12         | `kernel.asm`          |
| 13–16        | `kernellib.asm`       |
| 17–20        | `shell.asm`           |
| 40-49        | `nnfs.asm`            |
| 50–64        | File Data Blocks      |


## Codes For Errors and Debugging
| Code | Meaning                                       |
|------|-----------------------------------------------|
| 0    | No error, success                             |
| 1    | User program general non-fatal fail           |
| 2    | Bootloader did not load bootmanage properly   |
| 3    | Bootmanage failed to load kernel              |
| 4    | Kernel failed to load kernel library          |
| 5    | Kernel failed to load shell                   |
| 6    | Kernel failed to load file system             |
| 7    | Basic program was loaded and run successfully |

## Message System
Nomad OS has a specific format for printing messages.
When the system is printing a command it starts with an indicator.
This indicator determines the type of message.
All indicators (except [>]) will have a either a message

Indicators:
| Indicator              | Meaning                                                  |
|------------------------|----------------------------------------------------------|
| [*] (message) (code)   | Notification. Neutral alert                              |
| [+] (message) (code)   | Operation success                                        |
| [-] (message) (code)   | General error                                            |
| [!] (message) (code)   | Fatal system error, crash.                               |
| [>]                    | Ready for input                                          |

## Kernel Syscall Table
To make a syscall from anywhere in the OS from either within the kernel or user programs, use the kernel library.
Set **BL** to the syscall you want to make, along with any extra requirements that might be needed as shown in the table below.
The kernel library is always loaded by the kernel to **0x9000:0x0000**.
By using the call function on that memory address, everything will be automated for you.

| Syscall number (BL) | Function  | Arguments                                               |
|---------------------|-----------|---------------------------------------------------------|
| 1                   | Print     | SI: String to print                                     |
| 2                   | Input     | SI: Set to the buffer for output. Output goes to buffer |


## Development Notes
- Unnessarcary code from an old version of the kernel is still there. (Possible rewrite?)
- Need a system for loading files from the shell into memory and executing them.
