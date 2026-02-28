# 3d printing

Documentation for maintaining a Creality Ender 3 V2 Neo with Klipper firmware.

**Documentation:**
- [MAINTENANCE.md](MAINTENANCE.md) - System information and AI-assisted maintenance guide
- [GITOPS.md](GITOPS.md) - GitOps workflow for configuration management

**Quick Commands:**
```bash
make              # Show all available commands
make status       # Check printer status
make sync         # Pull backup and verify
make deploy       # Deploy config to printer
make logs         # View Klipper logs
```

## Creality Ender 3 V2 Neo

### System Access

* Web Interface: https://3d.laenzlinger.net
* SSH: `ssh 3d.laenzlinger.net`

### Mods

* [Filament guide](https://www.printables.com/model/93203-filament-guide-for-ender-3-v2)
* [Bed Leveling Wheel Clips](https://www.printables.com/model/115938-ender-3-bed-leveling-wheel-clips/files)
* [Camera Mount](https://www.printables.com/model/440579-ender-3-v2-neo-mount-for-pi-camera-module-v1-v2/files)
* [Light Bar](https://www.printables.com/model/360416-stealth-light-bar-resized-for-ender-3-pro-v2-neo-v)
* [Raspberry Pi Case](https://www.printables.com/model/106225-modular-snap-together-raspberry-pi-2b3b3b4-case-w-)

### Klipper Setup

The printer runs [Klipper](https://www.klipper3d.org/) firmware installed via [KIAUH](https://github.com/dw-0/kiauh).

Configuration backup is maintained at: https://github.com/laenzlinger/klipper-backup

Hardware:
* Creality 4.2.2 Mainboard
* TJC display

### Legacy Firmware (Pre-Klipper)

Previously used [Professional Firmware](https://github.com/mriscoc/Ender3V2S1) with [custom build for TJC display](https://github.com/mriscoc/Special_Configurations/releases/tag/tjc).

SD card formatting for firmware flashing (4096 byte sector size):

```sh
# Find the SD card
diskutil list

# Format as FAT32 with 4096 byte sector size (e.g., disk4s1)
sudo newfs_msdos -F 32 -b 4096 disk4s1
```
