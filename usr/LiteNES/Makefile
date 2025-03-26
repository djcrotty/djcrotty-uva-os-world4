# a "lean" user program. minimum dependency: 
# ulib; no dependency on libc 

include $(abspath ../../config.mk)

CFLAGS  := -MMD -Wall -Werror -nostdlib -g -fno-omit-frame-pointer
CFLAGS  += -nostartfiles -ffreestanding -mgeneral-regs-only
CFLAGS  += -O2  # Os to shrink binary size, e..g to fit xv6 fs limit

CFLAGS += -DNES_PROFILE  # print fps to stdout

# Temporarily allow unused variables to avoid compiler complaints.
# This should be commented out after completing all quests.
CFLAGS += -Wno-unused-variable -Wno-unused-but-set-variable -Wno-unused-function # STUDENT_TODO: replace this


LDFLAGS := 

CFILES  := common.c  cpu-addressing.c  cpu.c  fce.c memory.c  mmc.c  ppu.c  psg.c
CFILES  += hal.c main.c 
OBJS    := $(CFILES:%.c=%.o)
LIB     := ../build-lib/libc-simple.a

%.o: %.c
	$(VB) echo + CC $< "->" $@
	$(VB) $(CC) $(CFLAGS) -c -o $@ $<
 
nes: $(OBJS) $(LIB)
	$(VB) echo + LD "->" $@
	$(VB) aarch64-linux-gnu-ld $(LDFLAGS) -T nes.ld -o $@ $^

-include $(patsubst %.o, %.d, $(OBJS))

.PHONY: clean

clean:
	rm -rf nes *.o *.d
