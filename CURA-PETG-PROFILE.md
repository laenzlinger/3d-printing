# Cura PETG Profile for Ender 3 V2 Neo

## Quick Settings

**Material:**
- Material: PETG
- Printing Temperature: 240°C
- Printing Temperature Initial Layer: 245°C
- Build Plate Temperature: 80°C
- Build Plate Temperature Initial Layer: 80°C

**Quality:**
- Layer Height: 0.2mm
- Initial Layer Height: 0.28mm
- Line Width: 0.4mm
- Wall Line Width: 0.4mm
- Initial Layer Line Width: 120% (0.48mm)

**Speed:**
- Print Speed: 50 mm/s
- Infill Speed: 60 mm/s
- Wall Speed: 40 mm/s
- Outer Wall Speed: 30 mm/s
- Initial Layer Speed: 20 mm/s
- Travel Speed: 150 mm/s

**Cooling:**
- Enable Print Cooling: Yes
- Fan Speed: 40%
- Regular Fan Speed at Height: 0.8mm (layer 4)
- Initial Fan Speed: 0%
- Regular Fan Speed at Layer: 4

**Retraction:**
- Enable Retraction: Yes
- Retraction Distance: 1.5mm
- Retraction Speed: 30 mm/s
- Z Hop When Retracted: Yes
- Z Hop Height: 0.3mm

**Build Plate Adhesion:**
- Build Plate Adhesion Type: Brim (recommended for PETG)
- Brim Width: 8mm
- Brim Line Count: 10

**Shell:**
- Wall Thickness: 1.2mm (3 walls)
- Top Layers: 5
- Bottom Layers: 5

**Infill:**
- Infill Density: 20%
- Infill Pattern: Grid or Gyroid

**Special Modes:**
- Print Sequence: All at Once

## Start G-code

```gcode
; Ender 3 V2 Neo PETG Start G-code
M140 S80                    ; Set bed temp
M104 S245                   ; Set hotend temp (first layer +5°C)
M190 S80                    ; Wait for bed temp
M109 S245                   ; Wait for hotend temp
G28                         ; Home all axes
BED_MESH_PROFILE LOAD=default ; Load bed mesh
G92 E0                      ; Reset extruder
G1 Z5 F3000                 ; Lift nozzle
G1 X10 Y10 F5000            ; Move to start position
G1 Z0.3 F3000               ; Lower to purge height
G1 X100 E15 F500            ; Purge line
G92 E0                      ; Reset extruder
G1 Z2 F3000                 ; Lift nozzle
M104 S240                   ; Set normal printing temp
```

## End G-code

```gcode
; Ender 3 V2 Neo PETG End G-code
G91                         ; Relative positioning
G1 E-2 F2700                ; Retract filament
G1 Z5 F3000                 ; Lift nozzle
G90                         ; Absolute positioning
G1 X0 Y220 F3000            ; Present print
M104 S0                     ; Turn off hotend
M140 S0                     ; Turn off bed
M106 S0                     ; Turn off fan
M84                         ; Disable motors
```

## Notes

- **Always use glue stick on the bed** - PETG bonds too strongly to bare surfaces
- Let the bed cool before removing prints (PETG releases easier when cool)
- First layer should be slightly less squished than PLA
- If you see stringing, increase retraction distance by 0.5mm increments
- If layers aren't adhering, increase temperature by 5°C
