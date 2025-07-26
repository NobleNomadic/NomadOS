ASM = nasm

SRC_DIR = src
BUILD_DIR = build
BOOT_DIR = boot
KERNEL_DIR = kernel
SHELL_DIR = shell
PROGRAM_DIR = programs

# boot.asm
BOOT_SRC = $(SRC_DIR)/$(BOOT_DIR)/boot.asm
BOOT_BIN = $(BUILD_DIR)/$(BOOT_DIR)/boot.bin

# bootmanage.asm
BOOT_MANAGE_SRC = $(SRC_DIR)/$(BOOT_DIR)/bootmanage.asm
BOOT_MANAGE_BIN = $(BUILD_DIR)/$(BOOT_DIR)/bootmanage.bin

# kernel.asm
KERNEL_SRC = $(SRC_DIR)/$(KERNEL_DIR)/kernel.asm
KERNEL_BIN = $(BUILD_DIR)/$(KERNEL_DIR)/kernel.bin

# shell.asm
SHELL_SRC = $(SRC_DIR)/$(SHELL_DIR)/shell.asm
SHELL_BIN = $(BUILD_DIR)/$(SHELL_DIR)/shell.bin

# SHELL/USERSPACE PROGRAMS
# clear.asm
CLEAR_SRC = $(SRC_DIR)/$(PROGRAM_DIR)/clear.asm
CLEAR_BIN = $(BUILD_DIR)/$(PROGRAM_DIR)/clear.bin

# echo.asm
ECHO_SRC = $(SRC_DIR)/$(PROGRAM_DIR)/echo.asm
ECHO_BIN = $(BUILD_DIR)/$(PROGRAM_DIR)/echo.bin

# help.asm
HELP_SRC = $(SRC_DIR)/$(PROGRAM_DIR)/help.asm
HELP_BIN = $(BUILD_DIR)/$(PROGRAM_DIR)/help.bin

# fetch.asm
FETCH_SRC = $(SRC_DIR)/$(PROGRAM_DIR)/fetch.asm
FETCH_BIN = $(BUILD_DIR)/$(PROGRAM_DIR)/fetch.bin

IMG = $(BUILD_DIR)/os.img

# Default target
all: $(IMG)

# Assemble the bootloader to exactly 512 bytes
$(BOOT_BIN): $(BOOT_SRC)
	mkdir -p $(BUILD_DIR)/$(BOOT_DIR)
	$(ASM) -f bin $< -o $@

# Assemble boot manager
$(BOOT_MANAGE_BIN): $(BOOT_MANAGE_SRC)
	mkdir -p $(BUILD_DIR)/$(BOOT_DIR)
	$(ASM) -f bin $< -o $@

# Assemble kernel
$(KERNEL_BIN): $(KERNEL_SRC)
	mkdir -p $(BUILD_DIR)/$(KERNEL_DIR)
	$(ASM) -f bin $< -o $@

# Assemble the shell
$(SHELL_BIN): $(SHELL_SRC)
	mkdir -p $(BUILD_DIR)/$(SHELL_DIR)
	$(ASM) -f bin $< -o $@

# Assemble clear program
$(CLEAR_BIN): $(CLEAR_SRC)
	mkdir -p $(BUILD_DIR)/$(PROGRAM_DIR)
	$(ASM) -f bin $< -o $@

# Assemble echo program
$(ECHO_BIN): $(ECHO_SRC)
	mkdir -p $(BUILD_DIR)/$(PROGRAM_DIR)
	$(ASM) -f bin $< -o $@

# Assemble help program
$(HELP_BIN): $(HELP_SRC)
	mkdir -p $(BUILD_DIR)/$(PROGRAM_DIR)
	$(ASM) -f bin $< -o $@

# Assemble fetch program
$(FETCH_BIN): $(FETCH_SRC)
	mkdir -p $(BUILD_DIR)/$(PROGRAM_DIR)
	$(ASM) -f bin $< -o $@

# Create floppy disk image
$(IMG): $(BOOT_BIN) $(BOOT_MANAGE_BIN) $(KERNEL_BIN) $(SHELL_BIN) $(CLEAR_BIN) $(ECHO_BIN) $(HELP_BIN) $(FETCH_BIN)
	mkdir -p $(BUILD_DIR)
	cp $(BOOT_BIN) $(IMG)
	dd if=$(BOOT_MANAGE_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc
	dd if=$(KERNEL_BIN) of=$(IMG) bs=512 seek=5 conv=notrunc
	dd if=$(SHELL_BIN) of=$(IMG) bs=512 seek=12 conv=notrunc
	dd if=$(CLEAR_BIN) of=$(IMG) bs=512 seek=16 conv=notrunc
	dd if=$(ECHO_BIN) of=$(IMG) bs=512 seek=17 conv=notrunc
	dd if=$(HELP_BIN) of=$(IMG) bs=512 seek=18 conv=notrunc
	dd if=$(FETCH_BIN) of=$(IMG) bs=512 seek=19 conv=notrunc
	truncate -s 1440k $(IMG)

# Clean build directory
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
