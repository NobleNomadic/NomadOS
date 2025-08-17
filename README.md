# NomadOS
NomadOS is a simple 16 bit operating system made with x86 NASM assembly.
It uses a modular/micro kernel design which aims to make the OS as customisable and lightweight as possible.

## Project Overview
**Project Goals**
- Provide a command line to the user
- Build a simple file structure where binary and text programs can be stored on the disk and interacted with
- Build basic kernel modules to add more functionality to the OS
  - Floppy disk driver for interacting with a second disk for a filesystem - DONE
  - Time module for getting the current time                               - DONE
- Create a driver for interacting with a second floppy disk seperate from the main OS disk
- Create a minimal set of command line tools
  - echo:   Display a string                               - DONE
  - help:   Help menu for commands                         - DONE
  - clear:  Clear the screen                               - DONE
  - fetch:  Print system information and ASCII art         - DONE
  - reboot: Reboot system                                  - DONE
  - hex:    Print the hex data in a memory location        - DONE
  - flop:   Interact with files on an external floppy disk - DONE
  - time:   Get current time                               - DONE

## Structure
NomadOS uses a modular/micro kernel design.
The kernel does very little work, and instead focuses on giving user programs a simple environment to run in.
Kernel modules can be loaded at any point by user programs which provide additional locations to make syscalls.

## OS Control Structure
- Bootloader loads kernel
- Kernel loads first user program (shell)
- User program is given control of system
- User programs can call the kernel, and interact with modules
