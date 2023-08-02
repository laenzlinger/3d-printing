; Ender 3 Custom Start G-code
G92 E0 ; Reset Extruder
M190 S{material_bed_temperature_layer_0} ; Set Heat Bed temperature
M104 S{material_print_temperature_layer_0} ; Set Extruder temperature
G28 ; Home all axes
@BEDLEVELVISUALIZER	; tell the bed visualizer plugin to watch for reported mesh
G29 ; Auto bed-level (BL-Touch)
M500 ; Used to store G29 results in memory
G92 E0 ; Reset Extruder
G1 Z3.0 F3000 ; move z up little to prevent scratching of surface
M109 S{material_print_temperature_layer_0} ; Wait for Extruder temperature
M190 S{material_bed_temperature_layer_0} ; Wait for Heat Bed temperature
G1 X0.1 Y0.1 Z0.3 F5000.0 ; move to start-line position
G1 X200.1 Y0.1 Z0.3 F1500.0 E15 ; draw 1st line
G92 E0 ; reset extruder
G1 Z1.0 F3000 ; move z up little to prevent scratching of surface
