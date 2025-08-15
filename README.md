# NomadOS
NomadOS is a simple 16 bit operating system made with x86 NASM assembly.
It uses a modular kernel design which aims to make the OS as customisable and lightweight as possible.

## Project Overview
This is a rewrite of the original project due to the messiness of the OS structure. \
**Project Goals**
- Provide a command line to the user
- Build a simple file structure where binary and text programs can be stored on the disk and interacted with
- Develop a kernel module system where additional code can be loaded into the kernel to provide more functionality
  - Standard library to automate basic functions (print, input, etc)
  - Basic file system
  - Floppy disk driver for interacting with a second disk
- Create a driver for interacting with a second floppy disk seperate from the main OS disk
- Create a minimal set of command line tools
  - echo:   Echo a string
  - help:   Help menu for commands
  - clear:  Clear the screen
  - fetch:  Print system information and ASCII art
  - write:  Write to data on the disk
  - read:   Read data from the disk
  - reboot: Reboot system
  - hex:    Print the hex data in a memory location
  - kmod:   Load kernel modules manually
  - flop:   Read data from an external floppy disk

## Structure
NomadOS uses a modular kernel design.
The kernel program itself has 3 very basic system calls.
- Setup system:              Load user start program and module manager into memory
- Run kernel module manager: Make a request to the module manager
- Run user program:          Jump to the code at 0x3000:0x0000

The user start program is typically the shell, and once given control allows the user to type the name of programs to load and run them.
The programs loaded in user space may also make requests to the module manager to load modules or remove them.

## OS Control Structure
- Bootloader loads kernel
- Kernel loads first user program (shell)
- User program is given control of system
- Programs can request for certain modules to be loaded through kernel syscalls to provide additional function

