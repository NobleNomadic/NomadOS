ASM = nasm

SRC_DIR = src
BUILD_DIR = build

BOOT_SRC = $(SRC_DIR)/boot/boot.asm
BMANAGE_SRC = $(SRC_DIR)/boot/bootmanage.asm
KERNEL_SRC = $(SRC_DIR)/kernel/kernel.asm
KERNELLIB_SRC = $(SRC_DIR)/kernel/kernellib.asm
BASIC_PROGRAM_SRC = $(SRC_DIR)/programs/basic.asm
SHELL_SRC = $(SRC_DIR)/shell/shell.asm
NNFS_SRC = $(SRC_DIR)/fs/nnfs.asm

BOOT_BIN = $(BUILD_DIR)/boot/boot.bin
BMANAGE_BIN = $(BUILD_DIR)/boot/bootmanage.bin
KERNEL_BIN = $(BUILD_DIR)/kernel/kernel.bin
KERNELLIB_BIN = $(BUILD_DIR)/kernel/kernellib.bin
BASIC_PROGRAM_BIN = $(BUILD_DIR)/programs/basic.bin
SHELL_BIN = $(BUILD_DIR)/shell/shell.bin
NNFS_BIN = $(BUILD_DIR)/fs/nnfs.bin

IMG = $(BUILD_DIR)/os.img

all: $(IMG)

# Assemble boot.asm
$(BOOT_BIN): $(BOOT_SRC)
	mkdir -p $(BUILD_DIR)/boot
	$(ASM) $< -f bin -o $@

# Assemble bootmanage.asm
$(BMANAGE_BIN): $(BMANAGE_SRC)
	mkdir -p $(BUILD_DIR)/boot
	$(ASM) $< -f bin -o $@

# Assemble kernel.asm
$(KERNEL_BIN): $(KERNEL_SRC)
	mkdir -p $(BUILD_DIR)/kernel
	$(ASM) $< -f bin -o $@

# Assemble kernellib.asm
$(KERNELLIB_BIN): $(KERNELLIB_SRC)
	mkdir -p $(BUILD_DIR)/kernel
	$(ASM) $< -f bin -o $@

# Assemble shell.asm
$(SHELL_BIN): $(SHELL_SRC)
	mkdir -p $(BUILD_DIR)/shell
	$(ASM) $< -f bin -o $@

# Assemble nnfs.asm
$(NNFS_BIN): $(NNFS_SRC)
	mkdir -p $(BUILD_DIR)/fs
	$(ASM) $< -f bin -o $@

# Assemble basic.asm
$(BASIC_PROGRAM_BIN): $(BASIC_PROGRAM_SRC)
	mkdir -p $(BUILD_DIR)/programs
	$(ASM) $< -f bin -o $@

# Build floppy image
$(IMG): $(BOOT_BIN) $(BMANAGE_BIN) $(KERNEL_BIN) $(KERNELLIB_BIN) $(SHELL_BIN) $(NNFS_BIN) $(BASIC_PROGRAM_BIN)
	cp $(BOOT_BIN) $(IMG)
	dd if=$(BMANAGE_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc
	dd if=$(KERNEL_BIN) of=$(IMG) bs=512 seek=5 conv=notrunc
	dd if=$(KERNELLIB_BIN) of=$(IMG) bs=512 seek=12 conv=notrunc
	dd if=$(SHELL_BIN) of=$(IMG) bs=512 seek=16 conv=notrunc
	dd if=$(NNFS_BIN) of=$(IMG) bs=512 seek=39 conv=notrunc
	dd if=$(BASIC_PROGRAM_BIN) of=$(IMG) bs=512 seek=49 conv=notrunc

	truncate -s 1440k $(IMG)

clean:
	rm -rf $(BUILD_DIR)/*

.PHONY: all clean
