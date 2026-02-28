# Maintenance Guide

## System Overview

**Hardware:**
- Creality Ender 3 V2 Neo
- Creality 4.2.2 Mainboard
- TJC display
- Raspberry Pi with camera module

**Software Stack:**
- Klipper firmware (installed via KIAUH)
- Moonraker (API server)
- Fluidd (web interface)
- Crowsnest (camera streaming)

**Access:**
- Web: https://3d.laenzlinger.net
- SSH: `ssh 3d.laenzlinger.net`
- Local IP: 192.168.1.142

## Configuration Locations

### On Raspberry Pi
- Main config: `~/printer_data/config/printer.cfg`
- Moonraker: `~/printer_data/config/moonraker.conf`
- Camera: `~/printer_data/config/crowsnest.conf`
- Fluidd: `~/printer_data/config/fluidd.cfg` (symlink to `~/fluidd-config/fluidd.cfg`)
- Logs: `~/printer_data/logs/`

### Backup Repository
- GitHub: https://github.com/laenzlinger/klipper-backup
- Local clone: `../klipper-backup/printer_data/config/`
- Auto-backup via Klipper-Backup script

## Common Maintenance Tasks

### Check System Status
```bash
ssh 3d.laenzlinger.net "systemctl status klipper moonraker crowsnest"
```

### View Logs
```bash
ssh 3d.laenzlinger.net "tail -f ~/printer_data/logs/klippy.log"
ssh 3d.laenzlinger.net "tail -f ~/printer_data/logs/moonraker.log"
```

### Restart Services
```bash
ssh 3d.laenzlinger.net "sudo systemctl restart klipper"
ssh 3d.laenzlinger.net "sudo systemctl restart moonraker"
ssh 3d.laenzlinger.net "sudo systemctl restart crowsnest"
```

### Update Klipper/Moonraker
Use KIAUH on the Pi:
```bash
ssh 3d.laenzlinger.net
cd ~/kiauh
./kiauh.sh
# Select option 1 (Update)
```

### Backup Configuration
Configuration is automatically backed up to GitHub via the Klipper-Backup script.
Manual backup:
```bash
ssh 3d.laenzlinger.net "cd ~/klipper-backup && git pull && git add . && git commit -m 'Manual backup' && git push"
```

## AI-Assisted Maintenance

### What AI Can Help With

1. **System Health Checks**
   - Ask AI to SSH in and check service status
   - Review logs for errors
   - Monitor disk space and system resources

2. **Configuration Changes**
   - Review and modify printer.cfg
   - Adjust print settings
   - Configure new features

3. **Troubleshooting**
   - Analyze error messages from logs
   - Debug connection issues
   - Investigate print quality problems

4. **Documentation Updates**
   - Keep README and this file current
   - Document new mods or changes
   - Track firmware versions

### Example AI Prompts

- "Check the 3D printer system status via SSH"
- "Review the latest Klipper logs for errors"
- "Compare the current printer.cfg with the backup"
- "Update the README with the new camera settings"
- "Help me troubleshoot why prints are failing at layer 10"

### Important Notes

- Always review AI-suggested configuration changes before applying
- Test configuration changes with a small test print first
- Keep backups before major changes
- The klipper-backup repo is the source of truth for configs

## Known Issues

### OctoApp Subscription Failures
Moonraker logs show repeated "octoapp" subscription failures (HTTP 404). This is non-critical - it's just a notification service that's not configured. Can be ignored or disabled in moonraker.conf if desired.

## Service Ports

- Fluidd web interface: 80/443 (via reverse proxy)
- Moonraker API: 7125
- Camera stream: 8080 (localhost only)

## Useful Commands

### Check camera
```bash
ssh 3d.laenzlinger.net "v4l2-ctl --list-devices"
```

### View system resources
```bash
ssh 3d.laenzlinger.net "htop"
```

### Check network
```bash
ssh 3d.laenzlinger.net "ip addr show"
```
