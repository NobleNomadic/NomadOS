ASM = nasm

SRC_DIR = src
BUILD_DIR = build
BOOT_DIR = boot

BOOT_SRC = $(SRC_DIR)/$(BOOT_DIR)/boot.asm
BOOT_BIN = $(BUILD_DIR)/$(BOOT_DIR)/boot.bin

IMG = $(BUILD_DIR)/os.img

all: $(IMG)

# Assemble boot.asm
$(BOOT_BIN): $(BOOT_SRC)
	mkdir -p $(BUILD_DIR)/$(BOOT_DIR)
	$(ASM) -f bin $< -o $@

# Create floppy disk image
$(IMG): $(BOOT_BIN)
	mkdir -p $(BUILD_DIR)
	cp $(BOOT_BIN) $(IMG)
	truncate -s 1440k $(IMG)


# Clean build directory
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
