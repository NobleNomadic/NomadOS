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
- Create a minimal set of command line tools
  - echo
  - help
  - clear
  - fetch
  - write
  - read
  - reboot
  - hex
  - modulise
