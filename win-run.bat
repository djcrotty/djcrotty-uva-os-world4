@echo on
REM cf for rpi3 qemu: 
REM  https://github.com/RT-Thread/rt-thread/blob/master/bsp/raspberry-pi/raspi3-64/qemu-64.sh
REM  -sd sd.bin

REM hw devices implemented
REM https://www.qemu.org/docs/master/system/arm/raspi.html

set QEMU6="C:\Program Files\qemu\qemu-system-aarch64.exe"

set QEMU=%QEMU6%

set KERNEL=kernel8-rpi3qemu.img

:QEMU_FULL
%QEMU% -M raspi3b ^
-kernel %KERNEL% -serial null -serial mon:stdio ^
-usb -device usb-kbd
REM -drive file=smallfat.bin,if=sd,format=raw    REM SD 
goto :EOF

:QEMU_MON
REM %QEMU% -M raspi3b ^
REM -kernel %KERNEL% -serial null -serial mon:stdio -nographic ^
REM -d int -D qemu.log 

REM qemuv8 monitor
%QEMU% -M raspi3b ^
-kernel %KERNEL% -monitor stdio -serial null ^
-d int -D qemu.log ^
-nographic ^
-usb -device usb-kbd
goto :EOF

:QEMU_MIN
%QEMU% -M raspi3b ^
-kernel %KERNEL% -serial null -serial mon:stdio -nographic ^
-d int -D qemu.log
goto :EOF

:QEMU_SMALL
%QEMU% -M raspi3b ^
-kernel %KERNEL% -serial null -serial mon:stdio ^
-smp 4 ^
-nographic ^
-drive file=smallfat.bin,if=sd,format=raw
goto :EOF

:QEMU_FULL
%QEMU% -M raspi3b ^
-kernel %KERNEL% -serial null -serial mon:stdio ^
-usb -device usb-kbd
REM -drive file=smallfat.bin,if=sd,format=raw    REM SD 
goto :EOF

REM -nographic ^

REM qemu v8, no gfx, no kb, virtual fat
REM cannot make it work as sd driver expects certain
REM disk size. cannot fig out how to specify 
REM %QEMU8% -M raspi3b ^
REM -kernel ./kernel8-rpi3qemu.img -serial null -serial mon:stdio ^
REM -d int -D qemu.log ^
REM -nographic ^
REM -drive file=fat:rw:/tmp/testdir,if=sd,format=raw

if "%1" == "min" (
    call :QEMU_MIN
) else if "%1" == "full" (
    call :QEMU_FULL
) else if "%1" == "mon" (
    call :QEMU_MON
) else (
    REM default ...
    REM call :QEMU_SMALL
    call :QEMU_FULL
)
