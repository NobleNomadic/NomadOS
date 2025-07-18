# Nomad OS
A simple 16 bit operating system with a basic command line.
It uses simple floppy disks to boot, and store files.

## Structure
The operating system code is divided into 4 main parts.
- Bootloader
- Kernel
- Kernel Programs
- User Programs

### Bootloader
The bootloader is made of 2 files. `boot.asm` and `bootmanage.asm`.

The initial boot is done with boot.asm. It is padded to exactly 512 bytes the boot signature.
This file only exists to allow the OS to escape the 512 byte limit of a bootable file.
It only runs a function to show the bootloader was found, and then loads the boot manager into memory to handle the full boot process without a file size limit.

The boot manager controls the main booting system.
It gives the user the chance to boot the operating system, or enter a safe mode for debugging.
If the user chooses regular boot, then the kernel is loaded into memory.

Safe mode will not load the kernel immediatly.
If this option is selected, then the user will enter a command line built into the same file as the boot manager, where they can select what to load with each individual action being logged.
The commands are:
- load: Load the kernel normally, but print every action and then continue into shell
- state: Display the current system information including what has been loaded
- loadsafe: Load the kernel safely with minimal parts

### Kernel
The kernel of NomadOS controls the functionality of the operating system.
It primarily serves to load other programs into memory for the user to use.

When first loaded by the bootloader, full control is given to the `kernelEntry` function at the top of the file.
This function will load the kernel programs into memory.
The kernel programs are 2 pieces of code NomadOS uses to control user programs.


The first is the kernel library which is for handling common OS functions like disk interaction, printing to the screen, and getting input.

It then starts the shell, a command line tool that allows the user to enter the name of a program, and then run it.

Once these 2 pieces of code are loaded into memory, the shell is given control of code execution.

### Kernel Programs
As stated above, the kernel programs are used to control the user programs once loaded by the kernel.

#### Kernel Library
The kernel library is a 4 sector file that processes requests from both the kernel and user programs.
A user program or the kernel itself can setup registers as arguments for a certain system call, then load and call the code located at sector 13.
The kernel library can handle managing processing the system call based on the arguments provided in the registers.

Pseudo Usage:
```asm
; Entry
kernelLibraryEntry:
  ; Check what request was made
  cmp requestArgumentReg, [printFunctionName] ; Check for print function
  je printFunction                            ; Conditonal jump to the print function
  ; Continue checking other requests

  ret
```

#### Shell
Unlike many operating systems, the shell in NomadOS is not a program, instead it is built into the kernel.
It uses functions from the kernel library to get input, and handle commands.
The shell is very simple and looks for a user program with the same name as the command entered, and then will try and execute that code.

### User Programs
User progams are the useful part of the OS.
With just a kernel, the operating system can't do anything.
The user programs allow the user to interact with the operating system and hardware.
These programs include:
- basic: Print out a debug message. Designed only for kernel to test running user programs at startup. Sector 50
- ls: List the current files
- view [File]: Print the contents of a file
- echo [Text]: Print the first argument
- add [File] [Text]: Append data to a file
- write [File] [Text]: Rewrite the contents of a file
- del [File]: Delete a file
- new [Filename]: Create a new file
- clear: Clear the screen

### Structure on Disk
| Sectors      | Purpose               |
|--------------|-----------------------|
| 1            | `boot.asm`            |
| 2–5          | `bootmanage.asm`      |
| 6–12         | `kernel.asm`          |
| 13–16        | `kernellib.asm`       |
| 17–20        | Shell                 |
| 49           | File Index            |
| 50–100       | File Data Blocks      |

## NobleFS Filesystem
The entire NomadOS uses a file system stored on the same disk that the OS runs on.
Sectors 50-100 are assigned to the file system, with 49 being used to store the data about what each file is named, and what sector to find that file in.
This allows for 50 files with unique names and up to 512 bytes of content per file.
They can be used to store binary programs, or just store text.
You can write text files within the OS using write and add programs, but binary programs have to be written in assembly, compiled, and then arranged on the file system before booting.

## Error Codes
| Code | Meaning                                      |
|------|----------------------------------------------|
| 0    | No error, success                            |
| 1    | User program general non-fatal fail          |
| 2    | Bootloader did not load bootmanage properly  |
| 3    | Bootmanage failed to load kernel             |
| 4    | Possible fatal disk read by internal program |

## Message System
Nomad OS has a specific format for printing messages.
When the system is printing a command it starts with an indicator.
This indicator determines the type of message.

Indicators:
| Indicator              | Meaning                                                  |
|------------------------|----------------------------------------------------------|
| [*] (message)          | Notification. Neutral alert                              |
| [+] (message)          | Operation success                                        |
| [-] (message) (code)   | General error                                            |
| [!] (message) (code)   | Fatal system error, crash. Sometimes will only be a code |

## Syscall Table
To make a syscall from anywhere in the OS from either within the kernel or user programs, use the kernel library.
Set **BL** to the syscall you want to make, along with any extra requirements that might be needed as shown in the table below.
The kernel library is always loaded by the kernel to **0x9000:0x0000**.
By using the call function on that memory address, everything will be automated for you.

| Syscall number (BL) | Function  | Arguments                                               |
|---------------------|-----------|---------------------------------------------------------|
| 1                   | Print     | SI: String to print                                     |
| 2                   | Input     | SI: Set to the buffer for output. Output goes to buffer |
| 3                   | Read Disk | CH: Cylinder, CL: Sector, ES:BX: Address to load into   |

### Example syscall usage

```asm
mov byte bl, 1     ; Syscall for print
mov si, string     ; Set the argument for the string to print
call 0x9000:0x0000 ; Memory address of kernel library
```

### Development note for building syscalls

Each syscall has a handler function.
This handler will call the function, then use the `retf` instruction to return to the calling code.
You cannot use a conditional jump like most functions, because you need to use `retf` in the kernelLibEntry label.

Example within kernel library:

```asm
kernelLibraryEntry:
  ; Initial code
; Runs anytime that the library is called after the first time
.skipFirstRun:
  cmp bl, 1
  je .handlePrintString
  retf
; Handler function to make the retf for the library
.handlePrintString:
  call printString
  retf
```
