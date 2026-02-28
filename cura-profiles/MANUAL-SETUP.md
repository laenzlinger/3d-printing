# Cura PETG Settings - Manual Setup

Copy these settings into Cura manually:

## Material Settings
- **Printing Temperature**: 240°C
- **Build Plate Temperature**: 80°C

## Quality
- **Layer Height**: 0.2mm
- **Initial Layer Height**: 0.28mm
- **Line Width**: 0.4mm
- **Initial Layer Line Width**: 120% (0.48mm)

## Shell
- **Wall Thickness**: 1.2mm (3 walls)
- **Top Layers**: 5
- **Bottom Layers**: 5

## Infill
- **Infill Density**: 20%
- **Infill Pattern**: Grid

## Speed
- **Print Speed**: 50 mm/s
- **Infill Speed**: 60 mm/s
- **Wall Speed**: 40 mm/s
- **Outer Wall Speed**: 30 mm/s
- **Initial Layer Speed**: 20 mm/s
- **Travel Speed**: 150 mm/s

## Cooling
- **Enable Print Cooling**: Yes
- **Fan Speed**: 40%
- **Initial Fan Speed**: 0%
- **Regular Fan Speed at Height**: 0.8mm

## Travel
- **Enable Retraction**: Yes
- **Retraction Distance**: 1.5mm
- **Retraction Speed**: 30 mm/s
- **Z Hop When Retracted**: Yes
- **Z Hop Height**: 0.3mm

## Build Plate Adhesion
- **Build Plate Adhesion Type**: Brim
- **Brim Width**: 8mm

## Start/End G-code

**In Cura: Settings → Printer → Manage Printers → [Your Printer] → Machine Settings**

**Start G-code:**
```
START_PRINT BED_TEMP={material_bed_temperature_layer_0} EXTRUDER_TEMP={material_print_temperature_layer_0}
```

**End G-code:**
```
END_PRINT
```

## Quick Setup
1. Select your Ender 3 printer in Cura
2. Create a new profile: **Preferences → Profiles → Create**
3. Name it "PETG"
4. Apply all the settings above
5. Update the start/end G-code in Machine Settings
