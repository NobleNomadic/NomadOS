ASM = nasm

SRC_DIR = src
BUILD_DIR = build
BOOT_DIR = boot

BOOT_SRC = $(SRC_DIR)/$(BOOT_DIR)/boot.asm
BOOT_BIN = $(BUILD_DIR)/$(BOOT_DIR)/boot.bin

BOOT_MANAGE_SRC = $(SRC_DIR)/$(BOOT_DIR)/bootmanage.asm
BOOT_MANAGE_BIN = $(BUILD_DIR)/$(BOOT_DIR)/bootmanage.bin

IMG = $(BUILD_DIR)/os.img

# Default target
all: $(IMG)

# Assemble the bootloader to exactly 512 bytes
$(BOOT_BIN): $(BOOT_SRC)
	mkdir -p $(BUILD_DIR)/$(BOOT_DIR)
	$(ASM) -f bin $< -o $@
	@ actual_size=$$(stat -c%s $@); \
	   if [ $$actual_size -ne 512 ]; then \
	       echo "Error: Boot sector must be exactly 512 bytes (was $$actual_size)"; \
	       exit 1; \
	   fi

# Assemble boot manager
$(BOOT_MANAGE_BIN): $(BOOT_MANAGE_SRC)
	mkdir -p $(BUILD_DIR)/$(BOOT_DIR)
	$(ASM) -f bin $< -o $@


# Create floppy disk image
$(IMG): $(BOOT_BIN) $(BOOT_MANAGE_BIN)
	mkdir -p $(BUILD_DIR)
	cp $(BOOT_BIN) $(IMG)
	dd if=$(BOOT_MANAGE_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc
	truncate -s 1440k $(IMG)

# Clean build directory
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
