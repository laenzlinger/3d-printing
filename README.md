# 3d printing

## Creality Ender 3 V2 Neo

### Mods

* [Filament guide](https://www.printables.com/model/93203-filament-guide-for-ender-3-v2)
* [Bed Leveling Wheel Clips](https://www.printables.com/model/115938-ender-3-bed-leveling-wheel-clips/files)
* [Camera Mount](https://www.printables.com/model/440579-ender-3-v2-neo-mount-for-pi-camera-module-v1-v2/files)
* [Light Bar](https://www.printables.com/model/360416-stealth-light-bar-resized-for-ender-3-pro-v2-neo-v)
* [Raspberry Pi Case](https://www.printables.com/model/106225-modular-snap-together-raspberry-pi-2b3b3b4-case-w-)

### Firmware

Make sure you format your SD card with 4096 byte sector size or it may not flash
correctly.

To format a SD card with 4096 byte sector size in macOS:

```sh
# Find the SD card you want to format
diskutil list

# Get the current SD card info, assuming the disk is disk4s1
diskutil info disk4s1

# Format the SD card as FAT32 with a 4096 byte sector size, assuming the disk is disk4s1
sudo newfs_msdos -F 32 -b 4096 disk4s1
```

The [Professional Firmware](https://github.com/mriscoc/Ender3V2S1) is used.

My hardware is still stock:

* Creality 4.2.2 Mainboard
* TJC display

Therefore i had to install a [custom build](https://github.com/mriscoc/Special_Configurations/releases/tag/tjc)
Current version is: Ender3V2-422-BLTUBL-TJC-MPC-20240127.bin
