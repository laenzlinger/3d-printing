# 3d printing

## Ender 3 V2 NEO

### Mods

* [Filament guide](https://www.printables.com/model/93203-filament-guide-for-ender-3-v2)
* [Camera Mount](https://www.printables.com/model/440579-ender-3-v2-neo-mount-for-pi-camera-module-v1-v2/files)
* [Light Bar](https://www.printables.com/model/360416-stealth-light-bar-resized-for-ender-3-pro-v2-neo-v)
* [Raspberry Pi Case](https://www.printables.com/model/106225-modular-snap-together-raspberry-pi-2b3b3b4-case-w-)

### Firmware

Make sure you format your SD card with 4096 byte sector size or it may not flash correctly.

Format a SDCard with 4096 byte sector size in macOS

```
diskutil list # Find the SDCard you want to format

diskutil info disk4s1 # Get the current SDCard info, assuming the disk is disk4s1
sudo newfs_msdos -F 32 -b 4096 disk4s1 # Format the SDCard as FAT32 with a 4096 byte sector size, assuming the disk is disk4s1
```

https://github.com/mriscoc/Ender3V2S1
https://www.youtube.com/watch?v=GGrDB9gD2Tw
