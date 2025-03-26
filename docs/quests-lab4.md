# Quests of Kernel Lab4 "Simple User"

Total estimated time: 20 hours

**NOTE** In all coding quests, see the comments in the code for hints and instructions.

**NOTE** For picture/video deliverables, follow the [requirements](./submission.md).

**NOTE** In this lab, you will work with both the kernel (`kernel/`) and user (`usr/`) codebases, switching between them as needed. The instructions below specify which codebase to work on by using "usr" for user code and "kernel" for kernel code.

![alt text](Slide8.PNG)

| Quest      | Description                                                                                  | Credits |
|------------|----------------------------------------------------------------------------------------------|---------|
| [Quest01: shell](#quest01-shell)    | Implement basic shell functionality (`sh`, `ls`, `cat`).                                | 25      |
| [Quest02: kungfu](#quest02-kungfu)   | Bring up NES game in userspace. Handle framebuffer and display-related filesystems.     | 25      |
| [Quest03: initrc](#quest03-side-initrc)   | Auto-execute commands at boot using `read_init_cmd` in `sh`.                            | 5      |
| [Quest04: mario with inputs](#quest04-mario-with-inputs) | Integrate keyboard controls into NES. Play the game with keyboard inputs.      | 25      |
| [Quest05: mario on rpi3](#quest05-side-mario-on-rpi3) | Reproduce NES game with keyboard control on Raspberry Pi 3.                        | 25      |
| [Quest06: slider](#quest06-slider)   | Develop a slider app to display BMP images controlled by keyboard inputs.               | 20      |
| [Quest07: large files](#quest07-large-files) | Extend filesystem by modifying inode structure and mkfs tool. | 20      |
| [Quest08: sound](#quest08-sound)    | Implement sound functionality on Raspberry Pi 3, including driver and user-space app.   | 40      |

#### Credits exceeding 100 will be considered as bonus.

![alt text](quests.png)

## Debugging tips

### 1. Debugging tool improvement (3/8/2025) 
Simply run `./dbg-rpi3qemu.sh`
which will launch both QEMU and GDB, in their respective windows; you no longer have to manually run `gdb-multiarch` in a separate window as in previous labs. 

### 2. Emulator options for debugging

By default, `./dbg-rpi3qemu.sh` will launch QEMU without USB emulation (for speed & simplicity).
You can change it in `./dbg-rpi3qemu.sh`, by setting `qemu_full` as the default configuration. 

### 3. Source-level debugging of user code 

From prior labs we know GDB can set breakpoints at given user VAs. 
After such a breakpoint is hit, you can force loading the user elf from GDB. 

In the example below, I want to break at `main()` of `sh`. 

First, I launch GDB as usual. After GDB stops at the 0x0, I reload the `sh` elf:

```
>>> file usr/build/sh 
A program is being debugged already.
Are you sure you want to change the file? (y or n) y
Load new symbol table from "usr/build/sh"? (y or n) y
Reading symbols from usr/build/sh...
```

Then I can use the symbols from the `sh` elf for breakpoint: 

```
>>> b main
Breakpoint 1 at 0x7bc: file sh.c, line 276.
>>> c
```

Continue. When the breakpoint is hit, you can see the source of `sh`: 

![alt text](image-2.png)


**Caveats**: 

1. Spurious breakpoint hits:
If the kernel or other user programs execute the same address (0x7bc in the example above), they will also hit the breakpoint. GDB will display their actual instructions but with the source code of `sh`, which can be misleading and confusing.

2. After loading symbols from `sh`, the kernel symbols are unloaded so GDB only 
shows kernel instructions but not the source code. 
Reload the kernel symbols if needed
(from GDB, `file ./kernel/build-rpi3qemu/kernel8.elf`).

## Quest01: shell
#### OVERVIEW

The given kernel can already boot to launch the kernel process 
("Kernel process started..."). We will bring up the shell `sh` as a user process. 

#### STEPS

- [kernel] Understand kuser.c, complete user_process() so that it launches the user program "sh". 
- [usr] Grasp the idea of `usr/sh.c`; complete the code. 
    - create device and procfs files under /dev and /proc
- [usr] Grasp the idea of `usr/ls.c`; complete the code.
 Make the output format as close to the reference output (see below) as possible.
- [usr] Complete `usr/cat.c`. 

#### CHECKPOINT

Run `sh` in user mode and type `ls` on the console to list the files, including ones under /dev and /proc. 
Check the reference output [here](./sh-output-example.md).
Run `cat logo.txt` which shows our OS logo. 

#### DELIVERABLE

take a video of the shell running `ls` and `cat logo.txt`.

## Quest02: kungfu

#### OVERVIEW

We will bring up nes again -- except this time in the "simple" userspace that builds on file abstractions. 
With filesystem, nes can load a ROM (kungfu.nes) from a file in addition to the hardcoded ROM (mario) we dealt with before. 
With file abstractions, nes will need to read display configuration from /proc and render to /dev/fb. 
Therefore, we will bring up the display-related procfs and framebuffer device files.

> The two sub-quests below can be done in parallel.

> Use "./cleanall.sh && ./makeall.sh" to ensure all files are re-compiled.

#### SUB-QUEST 1. bring up display-related procfs: 

- [kernel] Understand how is procfs_parse_fbctl() invoked when user writes to /proc/fbctl, 
and how is procfs_gen_content() invoked when user reads from /proc/dispinfo. 
Complete `procfs_parse_fbctl()` and `procfs_gen_content()`. 

CHECKPOINT: in shell, try `cat /proc/dispinfo` to see the display configuration, 
and `echo 128 128 128 128 > /proc/fbctl` to change the display dimension.
Check the reference output [here](./sh-output-example.md).

To debug, add printf() to the aforementioned kernel functions to print the actual values read/written.

- [usr] In usr/libc-simple/uio.c, understand the purpose of this file.
    Complete the functions that operate on procfs (display related):
    - `config_fbctl()` to change the display dimension by writing to /proc/fbctl.
    - `read_dispinfo()` to read display configuration from /proc/dispinfo.

You may write a simple user program to test these functions.

#### SUB-QUEST 2. bring up framebuffer device /dev/fb:

- [kernel] Understand how writes to /dev/fb are handled by the kernel and how `devfb_write()` gets invoked.

- [kernel] Complete `devfb_write()`. Finish `filelseek()` so nes can rewind to the start of the framebuffer periodically. 

- [usr] In usr/LiteNES/hal.c `nes_hal_init()`, operate on framebuffer device /dev/fb:
    - add a function call to open the device file
    - complete `nes_flip_display()`, so that it writes pixels to the device file.

#### CHECKPOINT

Run `nes` from shell to see mario (as in the previous lab).

FINALLY: 

- [usr] In usr/LiteNES/main.c, complete main() so it loads a ROM from a file, for which the filename is passed as an argument.

Download `kungfu.nes` from [UVA-OS](https://virginia.app.box.com/folder/303726824749) and put it in `/usr/build/`.

run `nes kungfu.nes` to see kungfu (1985).

#### DELIVERABLE

Take a video showing that you can display the game (not necessarily playing it).

![kungfu](./kungfu.gif)

## Quest03: initrc

- [usr] Complete `read_init_cmd` in usr/sh.c to read and execute a list of commands from a text file. 

This feature is useful for testing a list of commands repeatedly (e.g. launching multiple nes instances at the same time). 

#### DELIVERABLE

take a video that when the system boots, it automatically launches the nes (mario or kungfu) game, without user typing any command.

## Quest04: mario with inputs

#### OVERVIEW

We will bring up the keyboard driver and its device file, so that nes can receive inputs and we can control the game.

> The two sub-quests below can be done in parallel.

#### SUB-QUEST 1: bring up the keyboard driver.

- [kernel] Grasp the idea of `kb.c`. Complete the event queue management with synchronization: `kb_intr` for enqueueing and `kb_read` for dequeuing. Finally `usbkb_init()` for registering the kb read function with the device file.

**CHECKPOINT**: from shell, launch `cat /dev/events`; click to focus on the qemu window, and type keys. You should see the stream of key events. 
"kd 0xXX" and "ku 0xXX" mean a key down and a key up event, respectively.

**DELIVERABLE**: take a short video showing that you can type and see the key events.

![alt text](cat-dev-events.gif)

#### SUB-QUEST 2: [usr] add keyboard inputs to nes. 

- In usr/libc-simple/uio.c, finish `read_kb_event()` to read and parse key events from /dev/events.

In usr/LiteNES/hal.c: 

- understand how pipe() can be used to communicate between tasks.
cf. usertests.c pipe1() and pipe3(). nes has a similar architecture. 

- complete `nes_hal_init()` so that the keyboard task opens the keyboard device file and repeatedly reads key events and sends them via a pipe to the main task.

- complete `wait_for_frame()` so that the main task reads key events from the pipe and updates the keyboard (i.e. controller) state, every frame.

- complete `nes_key_state()` so that the main task can query the controller state.

Reference console output [here](./sh-output-example.md).

**CHECKPOINT**: run `nes` from shell to see mario. Use keyboard to control mario. Have fun!

**DELIVERABLE**: take a short video showing that you can use keyboard to control the game
(must capture both the screen and the keyboard).

* 10/23/24: an occasional bug (both qemu and rpi3). it should not impact the assignment. (+10 points if students can propose a valid fix)
```
irq.c:180 Unhandled EL0 sync exception, cpu0, esr: 0x0000000002000000, elr: 0xffff0000007e2878, far: 0x0000000007ffffa0
irq.c:182 online esr decoder: https://esr.arm64.dev/#0x0000000002000000
```

## Quest05: mario on rpi3

Reproduce the above quest on rpi3. Plug in a USB keyboard to the rpi3 and play the game.

#### Reference on rpi3 (FPS around 38)
<!-- * WSL QEMU: the FPS is around 34 (per the emulated timer; the actual FPS may be lower). Playable. 

![mario-win-qemu-37fps](mario-win-qemu-37fps.gif) -->

![mario-rpi3](mario-rpi3.gif)

* 10/23/24: an occasional bug (both qemu and rpi3). it should not impact the assignment. 
```
irq.c:180 Unhandled EL0 sync exception, cpu0, esr: 0x0000000002000000, elr: 0xffff0000007e2878, far: 0x0000000007ffffa0
irq.c:182 online esr decoder: https://esr.arm64.dev/#0x0000000002000000
```

**DELIVERABLE**: take a video showing that you can play the game. 


## Quest06: slider

#### OVERVIEW

Bring up the slider app which will display a series of slides (as bmp files) loaded from the filesystem; 
switch among slides is controlled by keyboard inputs.

- [usr] In usr/slider.c, complete the slider app: 
    - the loader function which read pixels from a BMP file to memory
    - the function that clears the screen 
    - the render() function which writes pixels to /dev/fb
    - the event loop in main() that reads kb events and changes the current slide number. 

- [usr] Copy your bmp files to usr/build/ and name them as Slide1.BMP, Slide2.bmp, etc. These file names are hardcoded in slider.c and can be verified and changed. 
    - We also provide sample bmp files (usr/slides/, each 320x240, 226KB) for you to test.

    - NOTE: because of the filesystem limitation, you can only have lowres bmps. Each bmp file cannot be larger than 270 KBs; and the total size of all bmp files should not exceed a few MBs.

**DELIVERABLE**: run `slider` from shell to see the slides. Use keyboard to switch among slides.

![slider](./slider.gif)

## Quest07: large files 

#### OVERVIEW

We extend the xv6 filesystem. Right now it limits our apps in two ways: 

1. a single file size is capped at 270KB, because as an inode lacks doubly indirect pointers. 
2. the total blocks per filesystem are too few, as its on-disk bitmap cannot span more than 1 block (512 bytes).

#### STEPS

- [kernel] Extend the inode structure to support doubly indirect pointers. Complete `bmap()` in fs.c. 

- [tool] Extend usr/mkfs.c, which creates a filesystem image. 

> It's a host tool, meaning it runs on your build machine, e.g. WSL2, NOT as inside the qemu or as part of your OS. 
Debugging mkfs.c is much easier than debugging the OS kernel. 
e.g. just do ``gdb mkfs fs.img (files)`` from the WSL2 command line. 

- Grasp the design of mkfs.c. 
- Extend `balloc()` to support allocating more blocks per filesystem 
    (by operating on additional bits in the bitmap).
- Extend `iappend()` to support more blocks per file via doubly indirect pointers. 

#### CHECKPOINT

- load highres & tens of bmp files to usr/build/ and name them as slides. 
    - We also provide large bmp files (usr/slides/large/, each 960x720 and 2MB) for you to test.
    ```
    cp usr/slides/large/Slide3.BMP usr/build/
    ./cleanall.sh && ./makeall.sh
    (in OS shell) 
    slider
    (the forward to slide 3 which is the large bmp)
    ```
    Reference output [here](./sh-output-example.md).

- run `slider` to play the slides.

#### DELIVERABLE

Take a video showing that you can play multiple highres slides.

## Quest08: sound 

THIS CAN ONLY BE DONE WITH RPI3 HARDWARE; QEMU lacks sound hardware emulation. 

- To complete this quest, you will need to plug an earphone, headset, or speaker into the RPI3's 3.5mm audio jack. Ensure it is a 3.5mm jack, not USB or Bluetooth.

- We recommend starting with any inexpensive earphone you can find. Be cautious and place them close to, but not inside, your ears until you are sure there is no loud noise.

- If you cannot find any 3.5mm earphones, a limited number of speakers are available for loan.


#### OVERVIEW

Bring up the sound driver and its device file (/dev/sb), so that we can play simple sound from user space.

- The sound write path: sound.c
    - Understand /dev/sb: complete `devsb_write()`
    - Complete `sound_write()` and `GetNextChunk()`

- The irq path:
    - Complete `handle_irq()` (irq.c) to add DMA irq handling, and maintain DMA hardware 
    status by completing `DoDMAIRQ()`. 

#### CHECKPOINT

From kernel_main(), call `test_sound()` to play sound from the kernel space. 

- Understand /proc/sbctl: sound.c
    - read `procfs_sbctl_gen()`
    - complete `procfs_parse_sbctl()` for key commands

- The user space sound app: usr/buzz.c
    - complete its main logic for opening device files, load sound samples to 
    /dev/sb, and send command to /proc/sbctl for playback. 

#### CHECKPOINT

run `buzz` from shell to play sound.

#### DELIVERABLE

take a video showing that you can play sound.

Reference: 

https://github.com/user-attachments/assets/104c970d-fa47-4225-8ef6-645284de29f5
