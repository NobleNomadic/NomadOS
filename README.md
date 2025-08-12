# NomadOS
NomadOS is a simple 16 bit operating system made with x86 NASM assembly.
It uses a microkernel design which is designed to make the OS as flexible and modular as possible.

## Project Overview
This is a rewrite of the original project due to the messiness of the OS structure. \
**Project Goals**
- Provide a command line to the user
- Create a kernel which can run multiple controlled processes
- Build a simple file structure where binary and text programs can be stored on the disk and interacted with
- Develop a kernel module system where additional code can be loaded into the kernel to provide more functionality
  - Standard library to automate basic functions (print, input, etc)
  - Basic file system
  - Floppy disk driver for interacting with a second disk
- Create a driver for interacting with a second floppy disk seperate from the main OS disk
- Create a minimal set of command line tools
  - echo
  - help
  - clear
  - fetch
  - write
  - read
  - reboot
  - hex
  - kmod
  - flop
- Create a driver for interacting with a second floppy disk seperate from the main OS disk
- Create a driver for interacting with a second floppy disk seperate from the main OS disk

## Structure
NomadOS uses a microkernel design.
The kernel itself is a simple process controller, and manages the usage of kernel modules.
Kernel modules are loaded by the kernel during startup, and can be manually modified while the OS is running.
Modules are usually libraries which can be called to make syscalls.
For example, a module may be a library which can have syscalls made to it to automate interaction with a filesystem.
