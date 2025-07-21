ASM = nasm

SRC_DIR = src
BUILD_DIR = build
BOOT_DIR = boot

BOOT_SRC = $(SRC_DIR)/$(BOOT_DIR)/boot.asm
BOOT_BIN = $(BUILD_DIR)/$(BOOT_DIR)/boot.bin
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

# Create floppy disk image with bootloader
$(IMG): $(BOOT_BIN)
	mkdir -p $(BUILD_DIR)
	cp $(BOOT_BIN) $(IMG)
	truncate -s 1440k $(IMG)

# Clean build directory
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
