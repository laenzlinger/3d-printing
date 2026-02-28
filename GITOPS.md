# GitOps Workflow for Printer Configuration

## Overview

Configuration is managed through Git with automatic backups and manual deployments for safety.

**Repositories:**
- **Source of Truth**: https://github.com/laenzlinger/klipper-backup
- **Documentation**: https://github.com/laenzlinger/3d-printing

## Current Setup

### Automatic Backup (Pi → GitHub)

Klipper-Backup runs on the Pi and automatically commits/pushes changes to GitHub when:
- Configuration files are modified via Fluidd/Moonraker
- Manual trigger via Fluidd interface (Machine → Update Manager → klipper-backup)

**Backed up files:**
- `~/printer_data/config/*` (all config files)

**Excluded files:**
- Temporary files (*.swp, *.tmp, *.bak)
- Backup snapshots (printer-*.cfg)
- Data files (*.csv, *.zip)

**Configuration:** `~/klipper-backup/.env` on the Pi

### Manual Deployment (GitHub → Pi)

Changes made locally should be deployed manually to ensure safety.

## Workflow

### 1. Making Configuration Changes

#### Option A: Via Web Interface (Recommended for testing)
1. Edit config in Fluidd: https://3d.laenzlinger.net
2. Save and restart services
3. Test the changes
4. Backup is automatically pushed to GitHub
5. Pull changes locally: `cd ~/dev/gh/laenzlinger/klipper-backup && git pull`

#### Option B: Via Git (Recommended for planned changes)
1. Pull latest: `cd ~/dev/gh/laenzlinger/klipper-backup && git pull`
2. Edit config files locally
3. Commit and push to GitHub
4. Deploy to printer (see below)

### 2. Deploying Changes to Printer

```bash
# From your local machine
cd ~/dev/gh/laenzlinger/klipper-backup

# Review changes before deploying
git diff origin/main printer_data/config/printer.cfg

# Deploy to printer
scp printer_data/config/printer.cfg 3d.laenzlinger.net:~/printer_data/config/

# Restart Klipper to apply changes
ssh 3d.laenzlinger.net "sudo systemctl restart klipper"

# Or use Fluidd web interface: Firmware Restart
```

### 3. Verify Deployment

```bash
# Check service status
ssh 3d.laenzlinger.net "systemctl status klipper"

# Check logs for errors
ssh 3d.laenzlinger.net "tail -50 ~/printer_data/logs/klippy.log"
```

## Safety Practices

1. **Always test changes with a small test print first**
2. **Keep backup of working config before major changes**
3. **Review diffs before deploying**
4. **Monitor logs after deployment**
5. **Document significant changes in commit messages**

## Automation Scripts

### Deploy Script

Create `~/dev/gh/laenzlinger/klipper-backup/deploy.sh`:

```bash
#!/bin/bash
set -e

PRINTER="3d.laenzlinger.net"
CONFIG_DIR="printer_data/config"

echo "Deploying configuration to printer..."

# Deploy all config files
rsync -av --exclude='*.bak' --exclude='*.bkp' \
  ${CONFIG_DIR}/ ${PRINTER}:~/${CONFIG_DIR}/

echo "Restarting Klipper..."
ssh ${PRINTER} "sudo systemctl restart klipper"

echo "Waiting for Klipper to start..."
sleep 3

echo "Checking status..."
ssh ${PRINTER} "systemctl status klipper --no-pager -l 0"

echo "Deployment complete!"
```

Make it executable:
```bash
chmod +x ~/dev/gh/laenzlinger/klipper-backup/deploy.sh
```

### Backup Verification Script

Create `~/dev/gh/laenzlinger/klipper-backup/verify-backup.sh`:

```bash
#!/bin/bash
set -e

PRINTER="3d.laenzlinger.net"
CONFIG_DIR="printer_data/config"

echo "Comparing local backup with live config..."

# Fetch live config
ssh ${PRINTER} "cat ~/${CONFIG_DIR}/printer.cfg" > /tmp/live-printer.cfg

# Compare
if diff -q ${CONFIG_DIR}/printer.cfg /tmp/live-printer.cfg > /dev/null; then
  echo "✓ Backup is in sync with live config"
  exit 0
else
  echo "✗ Backup differs from live config:"
  diff -u ${CONFIG_DIR}/printer.cfg /tmp/live-printer.cfg
  exit 1
fi
```

Make it executable:
```bash
chmod +x ~/dev/gh/laenzlinger/klipper-backup/verify-backup.sh
```

## Troubleshooting

### Backup not pushing to GitHub

Check Moonraker logs:
```bash
ssh 3d.laenzlinger.net "tail -100 ~/printer_data/logs/moonraker.log | grep -i backup"
```

Manually trigger backup:
```bash
ssh 3d.laenzlinger.net "cd ~/klipper-backup && ./script.sh"
```

### Config changes not taking effect

1. Check for syntax errors in logs
2. Ensure Klipper restarted successfully
3. Try "Firmware Restart" in Fluidd (not just service restart)

### Merge conflicts

If both local and remote have changes:
```bash
cd ~/dev/gh/laenzlinger/klipper-backup
git fetch origin
git diff main origin/main  # Review differences
git pull --rebase  # Or manually merge
```

## Future Enhancements

Potential improvements to consider:

1. **Pre-deployment validation**: Syntax check before deploying
2. **Automated testing**: Test config in simulation before deploying
3. **Rollback mechanism**: Quick revert to last known good config
4. **Change notifications**: Alert on config changes
5. **CI/CD pipeline**: GitHub Actions for validation and deployment
