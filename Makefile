SRC_DIR =			./src/

#ASM_SOURCES = $(wildcard $(./src/)/*)
ASM_SOURCES =		boot.asm		\
					shell.asm		\
					brainfuck.asm	\
					view.asm		\
					save.asm		\
					edit.asm		\
					new.asm			\
					load.asm

DEST_DIR =			./build/
DEST_FILE =			BOSS.img

PROG_RM =			/bin/rm
PROG_MKDIR =		/bin/mkdir
PROG_NASM =			/usr/bin/nasm
PROG_DD =			/bin/dd

# Standard entry points

all: _compile _package

clean:
	$(PROG_RM) -f $(DEST_DIR)$(DEST_FILE)
	$(foreach src,$(ASM_SOURCES),$(PROG_RM) $(DEST_DIR)$(src).bin;)

check: _qemu

# Methods

_compile:
	$(foreach src,$(ASM_SOURCES),$(PROG_NASM) -f bin $(SRC_DIR)$(src) -o $(DEST_DIR)$(src).bin;)

_package:
	$(PROG_RM) -f $(DEST_DIR)$(DEST_FILE)
	$(PROG_MKDIR) -p $(DEST_DIR)
	$(PROG_DD) bs=512 count=2880 if=/dev/zero of=$(DEST_DIR)$(DEST_FILE)
	$(PROG_DD) status=noxfer conv=notrunc if=$(DEST_DIR)boot.asm.bin of=$(DEST_DIR)$(DEST_FILE)
	# TODO make loop for this:
	$(PROG_DD) seek=1 conv=notrunc if=$(SRC_DIR)help.txt of=$(DEST_DIR)$(DEST_FILE)
	$(PROG_DD) seek=2 conv=notrunc if=$(DEST_DIR)shell.asm.bin of=$(DEST_DIR)$(DEST_FILE)
	$(PROG_DD) seek=3 conv=notrunc if=$(DEST_DIR)brainfuck.asm.bin of=$(DEST_DIR)$(DEST_FILE)      # write sector 4
	$(PROG_DD) seek=4 conv=notrunc if=$(DEST_DIR)view.asm.bin of=$(DEST_DIR)$(DEST_FILE)
	$(PROG_DD) seek=5 conv=notrunc if=$(DEST_DIR)save.asm.bin of=$(DEST_DIR)$(DEST_FILE)
	$(PROG_DD) seek=6 conv=notrunc if=$(DEST_DIR)edit.asm.bin of=$(DEST_DIR)$(DEST_FILE)
	$(PROG_DD) seek=7 conv=notrunc if=$(DEST_DIR)new.asm.bin of=$(DEST_DIR)$(DEST_FILE)
	$(PROG_DD) seek=8 conv=notrunc if=$(DEST_DIR)load.asm.bin of=$(DEST_DIR)$(DEST_FILE)
	$(PROG_DD) seek=9 conv=notrunc if=$(SRC_DIR)source.bf of=$(DEST_DIR)$(DEST_FILE)

_qemu:
	qemu-system-i386 -fda $(DEST_DIR)$(DEST_FILE)