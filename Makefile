ASM = nasm

SRC_DIR = src
BUILD_DIR = build

BOOT_SRC = $(SRC_DIR)/boot/boot.asm
BMANAGE_SRC = $(SRC_DIR)/boot/bootmanage.asm
BOOT_BIN = $(BUILD_DIR)/boot/boot.bin
BMANAGE_BIN = $(BUILD_DIR)/boot/bootmanage.bin
IMG = $(BUILD_DIR)/os.img

all: $(IMG)

# Rule: assemble boot.asm
$(BOOT_BIN): $(BOOT_SRC)
	mkdir -p $(BUILD_DIR)/boot
	$(ASM) $< -f bin -o $@

# Rule: assemble bootmanage.asm
$(BMANAGE_BIN): $(BMANAGE_SRC)
	mkdir -p $(BUILD_DIR)/boot
	$(ASM) $< -f bin -o $@

# Rule: build floppy image
$(IMG): $(BOOT_BIN) $(BMANAGE_BIN)
	cp $(BOOT_BIN) $(IMG)
	dd if=$(BMANAGE_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc
	truncate -s 1440k $(IMG)

clean:
	rm -rf $(BUILD_DIR)/*

.PHONY: all clean
