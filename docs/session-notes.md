# Session Notes - PETG Calibration & MASS Project Setup

**Date:** 2026-02-28

## System Overview

**Printer:** Creality Ender 3 V2 Neo
- Klipper firmware via KIAUH
- Moonraker API on port 7125
- Fluidd web interface at https://3d.laenzlinger.net
- Crowsnest webcam configured
- BLTouch for bed leveling
- SSH access: `ssh 3d.laenzlinger.net`

**Repository Structure:**
- `/home/laenzi/dev/gh/laenzlinger/3d-printing/` - Main repo (source of truth)
- `/home/laenzi/dev/gh/laenzlinger/mass-premium/` - NAS case project
- `/home/laenzi/dev/gh/laenzlinger/klipper-backup/` - Auto-backup (passive)

## Current Status

### PETG Calibration - COMPLETE ✅
- **Temperatures:** 240°C hotend / 80°C bed
- **Retraction:** 1.5mm @ 30mm/s with 0.3mm Z-hop
- **Cooling:** 40% fan (0% first layer)
- **Z-offset:** 1.985mm (adjusted -0.05mm from baseline 1.935mm)
- **Test cube:** 20mm cube printed successfully

### Bed Mesh Issues ⚠️
- **Problem:** Magnetic bed is warped with 0.24mm variation
- **Worst area:** Right edge (0.275mm spike at position [6,3])
- **Good area:** Left/center of bed (0.03-0.14mm range)
- **Solution needed:** Order new magnetic PEI bed (235x235mm)
- **Workaround:** Position parts on left/center, avoid right edge

### Cura Profiles Created

**1. PETG (Basic)**
- 2 walls (0.8mm)
- 20% infill
- 0.2mm layers
- Use for: Test prints, small non-structural parts

**2. PETG Strong (Recommended for MASS project)**
- 3 walls (1.2mm)
- 25% gyroid infill
- 0.2mm layers
- 140% first layer line width (0.56mm)
- 8mm brim
- Use for: Structural parts, bay components

**3. PETG MASS (Alternative)**
- Similar to PETG Strong
- Had extrusion issues with 4 walls (too many retractions)
- Not recommended currently

### Key Settings That Work
- **Bed temp:** 80°C (NOT 70°C - this caused adhesion failures)
- **First layer line width:** 140% (critical for adhesion)
- **Retraction speed:** 30mm/s (quieter, prevents grinding)
- **Brim:** 8mm for large parts, optional for small parts
- **Speed:** 50mm/s print, 30mm/s outer wall, 60mm/s infill

### Issues Encountered & Solutions

**Problem:** Clips not sticking to bed
- **Cause:** Bed temp was 70°C instead of 80°C
- **Solution:** Fixed profile to use 80°C

**Problem:** Underextrusion with MASS profile
- **Cause:** 4 walls = too many retractions, filament grinding
- **Solution:** Reduced to 3 walls in PETG Strong profile

**Problem:** Retraction noise
- **Cause:** Retraction speed was 45mm/s
- **Solution:** Reduced to 30mm/s (matches test cube)

**Problem:** Second layer failures
- **Cause:** Warped bed creating uneven first layer
- **Solution:** Need new bed; workaround is positioning parts carefully

## MASS Premium NAS Case Project

**Goal:** 3D print case for 4x 3.5" HDDs

**Status:** Ready to print once new bed arrives

**Priority Parts (Bay Components):**
1. Clip x12 (test print) - 2-3 hours
2. BAYS_F (front bay) - ~37 hours with strong settings
3. BAYS_R (rear bay) - ~37 hours
4. HDD Slider x4 - ~2.5 hours each (can print 2 at once)
5. HDD Retainer x4 - ~2 hours each (can print all 4 at once)

**Files Location:**
- Original 3MF: `/home/laenzi/dev/gh/laenzlinger/mass-premium/*.3mf`
- Converted STL: `/home/laenzi/dev/gh/laenzlinger/mass-premium/stl/`
- Documentation: `BAY-PRIORITY-CHECKLIST.md`, `CURA-SETUP.md`

**Material Requirements:**
- BLACK PETG: ~1-1.5kg (structure, bays, small parts)
- GRAY PETG: ~1.5-2kg (exterior panels)
- TPU: ~50g (feet)

**Print Strategy:**
- Use PETG Strong profile
- Position parts on left/center of bed (avoid right edge)
- Start with small parts to verify settings
- Large parts (BAYS) take 30+ hours each

## Makefile Commands

```bash
make status          # Quick printer status
make monitor-simple  # Monitor print progress
make deploy          # Deploy config to printer
make sync-from-live  # Pull live config to source
make verify          # Compare source with live
make petg-bed-mesh   # Run bed mesh calibration at PETG temps
make petg-preheat    # Preheat for PETG
```

## Monitoring & Control

**Web Interface:** https://3d.laenzlinger.net
- Live webcam feed
- Temperature graphs
- Print progress
- G-code preview

**API Access:**
```bash
# Check status
ssh 3d.laenzlinger.net 'curl -s "http://localhost:7125/printer/objects/query?print_stats"'

# Cancel print
ssh 3d.laenzlinger.net 'curl -s -X POST http://localhost:7125/printer/print/cancel'

# Raise head
ssh 3d.laenzlinger.net 'curl -s -X POST http://localhost:7125/printer/gcode/script -d "{\"script\":\"G91\\nG1 Z20 F600\\nG90\"}"'
```

## Next Steps (When New Bed Arrives)

1. **Install new magnetic PEI bed**
2. **Run fresh bed mesh calibration:**
   ```bash
   make petg-bed-mesh
   ```
3. **Verify Z-offset with paper test**
4. **Test print:** Clip x12 with PETG Strong profile
5. **If successful:** Start bay components for MASS project

## Shopping List

**Critical:**
- [ ] Magnetic PEI bed (235x235mm, textured or smooth)
  - Brands: Creality official, Energetic, HICTOP
  - Price: ~$25-35

**Optional:**
- [ ] Spare 0.4mm brass nozzles (pack of 5) - ~$10
- [ ] Digital calipers for measuring prints - ~$15-20
- [ ] BLACK PETG filament (1-2kg)
- [ ] GRAY PETG filament (1-2kg)

## Important Notes

- **Never use glue stick** - User preference, avoid in solutions
- **Bed mesh has 0.24mm variation** - This is significant, new bed is essential
- **Test cube worked perfectly** - Calibration is solid, bed is the issue
- **PETG Strong profile is proven** - Use this for all structural parts
- **Position parts carefully** - Avoid right edge of bed until new bed arrives
- **80°C bed temp is critical** - 70°C causes adhesion failures
- **3 walls is optimal** - 4 walls causes extrusion issues

## Files to Reference

- `PETG-GUIDE.md` - Complete PETG printing guide
- `CURA-SETUP.md` - Cura profile setup for MASS project
- `BAY-PRIORITY-CHECKLIST.md` - Print order for bay components
- `MAINTENANCE.md` - System maintenance guide
- `GITOPS.md` - Configuration management workflow

## Printer Configuration Files

- Source: `printer_data/config/printer.cfg`
- Live: `ssh 3d.laenzlinger.net:~/printer_data/config/printer.cfg`
- Backup: `../klipper-backup/printer_data/config/printer.cfg`

## Lessons Learned

1. **Bed quality matters more than settings** - Can't compensate for 0.24mm warp
2. **First layer line width is critical** - 140% made huge difference
3. **Bed temperature must be correct** - 70°C vs 80°C = failure vs success
4. **Too many walls causes problems** - 4 walls = grinding, 3 walls = perfect
5. **Test small before large** - Clips revealed issues before committing to 37hr prints
6. **Position matters** - Using good area of bed is essential with warped bed
7. **Retraction speed affects noise** - 30mm/s is quieter than 45mm/s
8. **PETG needs higher temps than PLA** - 80°C bed minimum, not 70°C

## Success Criteria Met

✅ PETG temperatures calibrated (240°C/80°C)
✅ Retraction settings optimized (1.5mm @ 30mm/s)
✅ Test cube printed successfully
✅ Cura profiles created and tested
✅ MASS project files converted to STL
✅ Documentation complete
✅ Monitoring tools working
✅ GitOps workflow established

## Blockers

❌ Warped bed preventing reliable large prints
- **Impact:** Cannot complete MASS project bay components
- **Solution:** Order new magnetic PEI bed
- **Timeline:** 3-5 days delivery
- **Workaround:** Can print small parts in good area of bed

## When Resuming

1. Check if new bed has arrived
2. If yes: Install and calibrate
3. If no: Can print small parts (Clips, Retainers) in center of bed
4. Review `BAY-PRIORITY-CHECKLIST.md` for print order
5. Use PETG Strong profile for all structural parts
6. Monitor first layer closely on every print
