# NomadOS
NomadOS is a minimal 16 bit operating system made in x86 assembly.

## Project Overview
NomadOS is designed to provide a minimal and customisable operating system to provide users with a simple DOS like command line.
The goal of this project is to provide a system for users to configure their own operating system by editing the source code, and [config.json](config.json) file.
The structure of the project is designed to be simple so that anybody interested in x86 assembly can make their operating system their own.
This is a very minimal project that does not have any drivers.
The entire system uses BIOS interupts and runs on a floppy disk image.

## Installing and Setup
To install NomadOS, clone this repo and make a virtual machine using the `build/os.img` file.
For a lightweight OS like NomadOS, I would suggest using Qemu.

Quick start with Qemu
```bash
git clone https://NobleNomadic/NomadOS.git
cd NomadOS/build
qemu-system-i386 -drive file=os.img,if=floppy,format=raw
```

## Build System
NomadOS is written in x86 assembly, however compiling the `.asm` files manually will not create  a working operating system.
The `build.py` script and `config.json` files are used to preprocess each file into `.pp.asm` file, which are then used to generate code.

The configuration file is reasonably simple to understand; for each file included in the OS, there is an object in the `objects` section of the config file.
This contains data about where to write the file to the disk, where its source file is, etc.
During the preprocessing of the files, the python script will convert code such as
```asm
;LOAD_(object name)
```
into proper assembly.
This allows the structure of the project to be defined in the universal configuration file without needing to edit hard coded values.

## OS Structure
NomadOS is structued with a bootloader, kernel, and userspace.
Being a 16 bit operating system, there is no memory protection and it is worth noting that any user program could overwrite data in the kernel, or other core parts of the system.

### Bootloader
The bootloader is a 2 stage system made of 2, 512 byte files: [boot.asm](src/boot/boot.asm) and [bootmanage.asm](src/boot/boot.asm).
`boot.asm` is loaded first by the BIOS into **0x0000:0x7C00**, which prints a simple message to show the OS is booting, before loading the boot manager, `bootmanage.asm`.
The boot manager then prints a debug message to show that the disk is working correctly, and then loads the kernel and gives it control.

### Kernel
The kernel is a 4 sector binary file that handles syscalls.
Syscalls are made by setting the **bl** register to the syscall number you want to make, then calling the kernel address.
The kernel does not do much on its own, instead it provides a minimal system for userspace programs to be executed.
By default, the kernel will load the shell (known as userspacestart in `config.json`) into memory, but this can be modified to load a game, directly into a program, or somewhere else.
The kernel is also in charge of running kernel modules.
You can modify the `config.json` file and add kernel modules which are loaded on startup such as file systems, code for handling additional syscalls, or any other core component of the OS that you want to add.
Simply write the modules in the `src/modules` folder, edit the config file, and add code in the `kernelSetup` function to load these modules into memory.

### Userspace
Userspace is the location in memory and programs that allow a user of the OS to interact with the system.
The kernel loads userspace into memory (userspacestart) at address **0x2000:0x0000**.
Userspace programs should always be loaded into segment 0x2000, as the kernel temporarily switches to that segment while running certain syscalls.
The initial userspace program (shell by default) is then given control of the main OS loop.
You can then type commands to load programs and run them, give control to other programs, or use other utilities depending on how the system is configured.

### Memory and Disk Structure
The entire disk and memory layout can be seen and customised in the [config.json](config.json) file.
