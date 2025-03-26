The "simple" userspace contains a minimalist "libc".

DESIGNS

    - Support filesystem (xv6).
    - Programs will be built & linked as *.elf binaries, and packed into a filesystem image (mkfs.c)
      which is then packed into kernel8.img as a ramdisk. 

LIBRARY

    libc-simple/
        A minimalist "libc" that provides basic C functions and syscall stubs.

PROGRAMS

    LiteNES/
        The NES emulator that now can load ROMs (e.g., Kung Fu, md5sum: 27e5c62c6c)
        from the filesystem (e.g., ramdisk). Executable "nes".

    sysmon/
        System resource monitor.

    buzz.c
        Plays raw waveform included in the C header; cannot load encoded files.

    sh.c
        Shell.

    slider.c
        Slide (static images) player.

    (other *.c)
        Command-line utilities.

HOST TOOL
    mkfs.c: x86 program for packing all userspace into a filesystem image, which
    goes to the ramdisk image included in kernel8.img.
