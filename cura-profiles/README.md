# Cura Profile Management

## Profile Structure

Cura 5.x uses two files per profile:
1. `creality_ender3_[NAME].inst.cfg` - Printer-level settings (bed temp, etc.)
2. `creality_base_extruder_0_[NAME].inst.cfg` - Extruder settings (temps, speeds, etc.)

## Installing Profiles

### Method 1: Copy to Cura config (Recommended)
```bash
cp cura-profiles/*.inst.cfg ~/.local/share/cura/5.11/quality_changes/
```

Then restart Cura and the profile will appear in your profiles list.

### Method 2: Import via Cura UI
Cura 5.x doesn't support importing `.inst.cfg` files directly through the UI.
Use Method 1 instead.

## Available Profiles

### PETG Profile
- **Files**: 
  - `creality_ender3_PETG.inst.cfg`
  - `creality_base_extruder_0_PETG.inst.cfg`
- **Settings**: Optimized for PETG at 240°C/80°C
- **Features**: Brim, Z-hop, proper cooling for PETG

### Modcase Profile (Your Current)
- **Files**:
  - `creality_ender3_modcase.inst.cfg`
  - `creality_base_extruder_0_%232_modcase.inst.cfg`
- **Settings**: 245°C, 100% infill, 5 walls

## Exporting Your Profiles

To backup your current profiles:
```bash
cp ~/.local/share/cura/5.11/quality_changes/*.inst.cfg ~/dev/gh/laenzlinger/3d-printing/cura-profiles/
```

## Start/End G-code

Update in: **Settings → Printer → Manage Printers → [Your Printer] → Machine Settings**

**Start G-code:**
```
START_PRINT BED_TEMP={material_bed_temperature_layer_0} EXTRUDER_TEMP={material_print_temperature_layer_0}
```

**End G-code:**
```
END_PRINT
```
