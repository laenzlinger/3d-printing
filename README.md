# 3d printing

Documentation for maintaining a Creality Ender 3 V2 Neo with Klipper firmware.

**Documentation:**
- [docs/maintenance.md](docs/maintenance.md) - System information and AI-assisted maintenance guide
- [docs/gitops.md](docs/gitops.md) - GitOps workflow for configuration management
- [docs/petg-guide.md](docs/petg-guide.md) - PETG printing guide and troubleshooting
- [docs/cura-petg-profile.md](docs/cura-petg-profile.md) - Cura profile setup for PETG
- [docs/session-notes.md](docs/session-notes.md) - Print session notes and tuning history

**Quick Commands:**
```bash
make              # Show all available commands
make status       # Check printer status
make sync         # Pull backup and verify
make deploy       # Deploy config to printer
make logs         # View Klipper logs
```

## Git Hooks

Run once after cloning:
```bash
./scripts/setup-git-hooks.sh
```

Pre-commit hooks check:
- Printer config syntax
- Cura profile structure
- No temp files committed

## TODO

- [ ] Extend start gcode purge line (current line is too short for consistent priming)
- [ ] Tune PETG retraction and feed settings (stringing/blob issues)
- [x] ~~Test PLA bed temp 65°C for better adhesion on textured PEI (ESP case warped at 60°C)~~
  - 65°C caused elephant foot, no warping improvement
  - Reducing PLA max fan to 40% fixed warping → applied to all PLA profiles

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
