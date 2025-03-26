/* Linker script for Raspberry Pi 3 emulated by QEMU

	Note: As of 10/2024, the rpi3qemu and rpi3 linker scripts are functionally
	identical. They are kept separate because they refer to objects in their
	respective build subdirectories.
*/

SECTIONS
{
	. = 0xffff000000080000;  
	.text.boot : { *(.text.boot) }

	. = ALIGN(0x00001000);
	user_begin = .;
	.text.user : { build-rpi3qemu/kuser* (.text) }
	.rodata.user : { build-rpi3qemu/kuser* (.rodata) }
	.data.user : { build-rpi3qemu/kuser* (.data) }
	.bss.user : { build-rpi3qemu/kuser* (.bss) }
	user_end = .;

	. = ALIGN(512);		/*sector aligned*/
	ramdisk_start = .;
	.ramdisk : {build-rpi3qemu/ramdisk* (.data)}		/* must come before generic *(.data) */
	. = ALIGN(512);		/*sector aligned*/	
	ramdisk_end = .;

	.text :  { *(.text) }
	.rodata : { *(.rodata) }
	.data : { *(.data) }

	. = ALIGN(0x8);	 /* bss begin/end must be aligned: cleared with memzero_aligned*/
	bss_begin = .;
	.bss : { *(.bss*) } 
	bss_end = .;
	. = ALIGN(0x00001000);
	idmap_dir = .;
	.data.idmapd : {. += (3* (1 << 12));}
	. = ALIGN(0x00001000);
	pg_dir = .;
	.data.pgd : { . += (4 * (1 << 12)); }	/* PG_DIR_SIZE */
	kernel_end = .; 
}