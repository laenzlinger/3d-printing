# PETG Printing Guide - Ender 3 V2 Neo

## PETG Characteristics

PETG is more challenging than PLA but offers better strength, flexibility, and temperature resistance.

**Key differences from PLA:**
- More stringing (needs retraction tuning)
- Sticks aggressively to bed (can damage surface)
- More sensitive to speed and temperature
- Requires more cooling control
- Hygroscopic (absorbs moisture)

## Recommended Settings

### Temperatures
- **Nozzle**: 230-250°C (start at 240°C)
- **Bed**: 70-85°C (start at 80°C)
- **First layer nozzle**: +5°C (245°C if printing at 240°C)

### Speeds
- **Print speed**: 40-60 mm/s (start at 50 mm/s)
- **First layer**: 20-30 mm/s
- **Outer walls**: 30-40 mm/s
- **Infill**: 50-60 mm/s
- **Travel speed**: 150 mm/s

### Cooling
- **First layer**: 0% fan
- **Layers 2-3**: 0-20% fan
- **Layer 4+**: 30-50% fan (PETG needs less cooling than PLA)

### Retraction (Direct Drive)
- **Distance**: 1-2mm (start at 1.5mm)
- **Speed**: 25-35 mm/s (start at 30 mm/s)
- **Z-hop**: 0.2-0.4mm (helps with stringing)

### First Layer
- **Height**: 0.2-0.28mm (thicker is better for PETG)
- **Line width**: 120% of nozzle (0.48mm for 0.4mm nozzle)
- **Speed**: 20 mm/s
- **Bed temp**: 80-85°C

### Other Settings
- **Layer height**: 0.12-0.28mm (0.2mm is good balance)
- **Line width**: 0.4-0.48mm
- **Flow rate**: 95-100% (start at 100%, reduce if over-extruding)

## Bed Adhesion

**Critical for PETG:**
1. Clean bed with IPA (isopropyl alcohol)
2. Use glue stick or painter's tape (prevents PETG bonding too strongly)
3. Let bed cool before removing print (PETG releases easier when cool)
4. Never use bare glass - PETG can fuse to it permanently

## Pre-Print Checklist

### 1. Dry Your Filament
PETG absorbs moisture quickly. Signs of wet filament:
- Popping/hissing sounds during printing
- Excessive stringing
- Rough surface finish
- Weak layer adhesion

**Drying**: 65°C for 4-6 hours in food dehydrator or filament dryer

### 2. Calibrate for PETG

Run these calibrations in order:

#### A. PID Tuning (Essential)
```gcode
# Hotend PID tune at 240°C
PID_CALIBRATE HEATER=extruder TARGET=240

# Bed PID tune at 80°C  
PID_CALIBRATE HEATER=heater_bed TARGET=80

# Save results
SAVE_CONFIG
```

#### B. First Layer Calibration
```gcode
# Heat up
M104 S240  ; Set hotend temp
M140 S80   ; Set bed temp
M109 S240  ; Wait for hotend
M190 S80   ; Wait for bed

# Run bed mesh
G28        ; Home
BED_MESH_CALIBRATE

# Print first layer test
# Adjust Z offset until first layer is slightly squished but not too flat
```

#### C. Temperature Tower
Print a temperature tower (230-250°C) to find optimal temperature:
- Look for best layer adhesion
- Minimal stringing
- Clean overhangs
- Smooth surface

#### D. Retraction Test
Print retraction test to tune:
- Retraction distance (1-2mm)
- Retraction speed (25-35 mm/s)
- Z-hop (0.2-0.4mm)

#### E. Flow Rate Calibration
Print single-wall cube and measure wall thickness:
- Target: 0.4mm for 0.4mm nozzle
- Adjust flow rate: `new_flow = (target_width / measured_width) * current_flow`

## Klipper Configuration Additions

Add these to your printer.cfg for PETG printing:

```ini
# PETG Pressure Advance (tune this)
# Start with 0.05, adjust based on corners
[extruder]
pressure_advance: 0.05
pressure_advance_smooth_time: 0.040

# PETG Macros
[gcode_macro PETG_PREHEAT]
gcode:
    M140 S80          ; Set bed temp
    M104 S240         ; Set hotend temp
    M190 S80          ; Wait for bed
    M109 S240         ; Wait for hotend

[gcode_macro PETG_START]
gcode:
    G28                           ; Home
    BED_MESH_CALIBRATE           ; Create bed mesh
    G1 Z5 F3000                  ; Lift nozzle
    M140 S80                     ; Set bed temp
    M104 S245                    ; Set first layer temp (+5°C)
    M190 S80                     ; Wait for bed
    M109 S245                    ; Wait for hotend
    G92 E0                       ; Reset extruder
    G1 Z0.3 F3000                ; Lower nozzle
    G1 X10 Y10 F5000             ; Move to start
    G1 X100 E15 F500             ; Purge line
    G92 E0                       ; Reset extruder
    M104 S240                    ; Set normal temp

[gcode_macro PETG_END]
gcode:
    G91                          ; Relative positioning
    G1 E-2 F2700                 ; Retract
    G1 Z5 F3000                  ; Lift nozzle
    G90                          ; Absolute positioning
    G1 X0 Y220 F3000             ; Present print
    M104 S0                      ; Turn off hotend
    M140 S0                      ; Turn off bed
    M106 S0                      ; Turn off fan
    M84                          ; Disable motors
```

## Troubleshooting

### Stringing
- Increase retraction distance (0.5mm increments)
- Increase retraction speed
- Enable Z-hop (0.2-0.3mm)
- Lower temperature (5°C increments)
- Increase travel speed

### Poor Layer Adhesion
- Increase temperature (5°C increments)
- Reduce cooling fan speed
- Slow down print speed
- Check filament is dry

### Warping
- Increase bed temperature
- Use enclosure or draft shield
- Reduce cooling fan
- Add brim or raft

### Oozing/Blobbing
- Lower temperature
- Increase retraction
- Enable "wipe while retracting"
- Reduce "extra restart distance"

### First Layer Not Sticking
- Increase bed temperature to 85°C
- Lower Z offset (squish more)
- Clean bed thoroughly
- Apply glue stick
- Slow down first layer (15-20 mm/s)

### First Layer Too Sticky (Can't Remove Print)
- Let bed cool completely (below 40°C)
- Use glue stick or painter's tape as release agent
- Reduce bed temperature to 75°C

## Slicer Profile (PrusaSlicer/OrcaSlicer)

```
Filament: PETG
Nozzle: 240°C (first layer 245°C)
Bed: 80°C
Layer height: 0.2mm
First layer height: 0.28mm
Line width: 0.4mm (first layer 0.48mm)

Speeds:
- Perimeters: 40 mm/s
- External perimeters: 30 mm/s
- Infill: 60 mm/s
- First layer: 20 mm/s
- Travel: 150 mm/s

Cooling:
- Min fan speed: 30%
- Max fan speed: 50%
- Disable fan first layer: Yes
- Enable fan if layer time < 15s

Retraction:
- Length: 1.5mm
- Speed: 30 mm/s
- Z-hop: 0.3mm
- Wipe while retracting: Yes

Extrusion:
- Extrusion multiplier: 1.0 (adjust after calibration)
```

## Testing Workflow

1. **Dry filament** (if not fresh from sealed bag)
2. **PID tune** hotend and bed
3. **Bed mesh calibration**
4. **First layer test** - adjust Z offset
5. **Temperature tower** - find optimal temp
6. **Retraction test** - minimize stringing
7. **Small test print** - verify all settings
8. **Large project** - monitor first few layers closely

## Storage

- Store PETG in airtight container with desiccant
- Re-dry before use if stored for >2 weeks
- Keep away from humidity

## Safety Notes

- PETG can emit fumes - ensure good ventilation
- Bed can be very sticky - use tools to remove prints, not fingers
- Let prints cool before removal to avoid warping
