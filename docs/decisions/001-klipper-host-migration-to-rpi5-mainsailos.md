# ADR 001: Migrate Klipper Host to RPi5 with MainsailOS

**Date:** 2026-11-04
**Status:** Accepted

## Context

The Klipper/Moonraker/Fluidd stack runs on an older Raspberry Pi with Arch Linux ARM,
installed manually via KIAUH. Arch's rolling release model creates ongoing maintenance
burden: Python virtual environments break on major updates, systemd unit configurations
drift, and Klipper's toolchain is tightly coupled to specific library versions that
conflict with bleeding-edge Arch packages.

A Raspberry Pi 5 with a 931 GB NVMe drive is available and intended as the new host.
KIAUH was attempted on Arch ARM on the RPi5 but failed due to Debian-specific assumptions
in the installer (package names, service configuration, paths).

## Decision

Replace the Arch Linux ARM installation on the RPi5 with **MainsailOS** (Debian Trixie,
arm64), then migrate the existing Klipper configuration from the GitHub backup.

The RPi5 boots from the NVMe drive for reliability (SD cards are prone to corruption on
unclean power loss, which is common in 3D printing environments).

### Architecture

```
Creality Ender 3 V2 Neo (USB)
  → Klipper (RPi5, MainsailOS on NVMe)
  → Moonraker API (:7125)
  → Mainsail web interface (:80)
  → https://3d.laenzlinger.net (via NAS Traefik, see ADR 015 in nas-infra)
```

### Migration Approach

1. Flash MainsailOS arm64 image to a microSD card from the ThinkPad
2. Boot RPi5 from SD (default EEPROM boot order tries SD before NVMe)
3. From the SD-booted system, write the MainsailOS image to the NVMe
4. Remove SD card — RPi5 falls through to NVMe boot
5. Restore Klipper config from `github.com/laenzlinger/klipper-backup`
6. Decommission old Raspberry Pi

### Image

`2026-05-06-MainsailOS-raspberry_pi-arm64-trixie-3.0.0.img.xz`

## Rationale

**Why MainsailOS over Arch + KIAUH:**
- Pre-configured, tested stack (Klipper + Moonraker + Mainsail in one image)
- Debian Trixie — stable, long support, no rolling breakage
- Updates managed via Mainsail's built-in update manager (web UI, one click)
- KIAUH works correctly on Debian; it has Debian-specific assumptions that break on Arch

**Why RPi5 over the existing Pi:**
- Existing Pi is underpowered for the full stack under load
- RPi5 has sufficient headroom (8 GB RAM, faster CPU)

**Why NVMe over SD card:**
- SD cards degrade and corrupt under frequent power cycling (printers are often cut by
  switching off the mains)
- NVMe is more reliable and faster
- The RPi5 NVMe HAT is already installed and working

**Why keep Mainsail (not reinstall Fluidd):**
- Mainsail and Fluidd are functionally equivalent frontends over the same Moonraker API
- Mainsail is the default in MainsailOS and actively maintained by the same team
- Switching frontends is trivial via KIAUH if needed

## Consequences

**Positive:**
- No more manual dependency management or broken venvs after Arch updates
- One-click updates for Klipper, Moonraker, and Mainsail via the web UI
- NVMe boot eliminates SD card corruption risk
- Config remains version-controlled via klipper-backup (unchanged workflow)

**Negative:**
- Mainsail replaces Fluidd as the default frontend (minor UX difference)
- Old Raspberry Pi must be kept running until migration is verified

## References

- [MainsailOS releases](https://github.com/mainsail-crew/MainsailOS/releases)
- [klipper-backup](https://github.com/laenzlinger/klipper-backup)
- [nas-infra ADR 015: 3D Printer Access via NAS Gateway](https://github.com/laenzlinger/nas-infra/blob/main/docs/decisions/015-3d-printer-gateway.md)
- [docs/maintenance.md](../maintenance.md)
