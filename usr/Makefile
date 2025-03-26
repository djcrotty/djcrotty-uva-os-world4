# "simple userspace" Makefile
# 	only dep on libc-simple, no libc, etc

# Apr 2024 mandates using gcc-9 (not gcc 11 which is default in Ubuntu 22.04)
include $(abspath ../config.mk)

# cmdline programs (from xv6)
UPROGS = \
	build/echo \
	build/ls \
	build/mkdir \
	build/forktest \
	build/usertests \
	build/sh	\
	build/cat	\
	build/grep	\
	build/kill	\
	build/ln	\
	build/rm	\
	build/wc

# apps 
UPROGS += build/slider
UPROGS += build/buzz
UPROGS += build/nes

COPS = -MMD -Wall -Werror -nostdlib -g -fno-omit-frame-pointer
COPS += -nostartfiles -ffreestanding -mgeneral-regs-only
COPS += -O0

# Temporarily allow unused variables to avoid compiler complaints.
# This should be commented out after completing all quests.
COPS += -Wno-unused-variable -Wno-unused-but-set-variable -Wno-unused-function # STUDENT_TODO: replace this

ASMOPS = -g

all: ramdisk.bin

ramdisk.bin: $(UPROGS) mkfs
	$(VB) rm -f ramdisk.bin
	$(VB) cp logo-uva.txt build/logo.txt
	$(VB) cd build && ../mkfs ../ramdisk.bin `ls` || (echo "ramdisk.bin FAILED"; rm -f ../ramdisk.bin; exit 1)

# Temporarily allow unused variables to avoid compiler complaints.
# This should be commented out after completing all quests.
mkfs: mkfs.c
	$(VB) gcc -Werror -Wall -g -Wno-unused-variable -Wno-unused-but-set-variable -Wno-unused-function -I. -o $@ $^ # STUDENT_TODO: replace this

%.o: %.c
	$(VB) echo  USER CC $< "->" $@
	$(VB) $(CC) $(COPS) -MMD -c $< -o $@

%_s.o: %.S
	$(VB) echo  USER AS $< "->" $@
	$(VB) $(CC) $(ASMOPS) -MMD -c $< -o $@

build/nes: build-lib/libc-simple.a
	cd LiteNES && $(MAKE)
	cp LiteNES/nes build/
	$(ARMGNU)-strip build/nes

# build/nes1: build-lib/libvos.a build-lib/libminisdl.a
# 	cd LiteNES && $(MAKE) -f Makefile.sdl
# 	cp LiteNES/nes1 build/
# 	$(ARMGNU)-strip build/nes1

# to prevent makefile from its implicit rule which is shorter & preferred
# https://www.gnu.org/software/make/manual/html_node/Canceling-Rules.html
% : %.c

##################
# user libs 
build-lib/libc-simple.a:
	cd libc-simple && $(MAKE) install

######################
#  "lean" user apps, simple rule for building
build/%: %.o build-lib/libc-simple.a
	$(VB) echo  USER LD $< "->" $@
	$(VB) mkdir -p build
	$(VB) $(ARMGNU)-ld $(LDFLAGS) -T user.ld -o $@ $^
	$(VB) $(ARMGNU)-objdump -S $@ > $*.asm
	$(VB) $(ARMGNU)-objdump -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $*.sym

clean: 
	cd LiteNES && $(MAKE) clean
	rm -f *.o $(UPROGS) build-lib/*.a build-lib/*.o mkfs *.d *.sym *.asm ramdisk.bin
