; Ender 3 Custom Start G-code
G92 E0 ; Reset Extruder
M140 S{material_bed_temperature_layer_0} ; Set Heat Bed temperature
M104 S{material_print_temperature_layer_0} ; Set Extruder temperature
G28 ; Home all axes
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

; Ender 3 V2 NEO custom End code:
G91 ;Relative positioning
M140 S0 ;Turn-off bed
M106 S0 ;Turn-off fan
M104 S0 ;Turn-off hotend
G91 ;Relative positioning
G1 E-2 F2700 ;Retract a bit
G1 E-2 Z0.2 F2400 ;Retract and raise Z
G1 X5 Y5 F3000 ;Wipe out
G1 Z10 ;Raise Z more
G90 ;Absolute positioning
M300 S440 P500 ; plays a tone at 440 Hz for 250 ms
G1 X0 Y{machine_depth} ;Present print
M84 X Y E ;Disable all steppers but Z
M109 R50 ;Wait for nozzle temp to be 50.
M300 S440 P400 ; plays a tone at 440 Hz for 200 ms
G4 P800
M300 S440 P400 ; plays a tone at 440 Hz for 200 ms
G4 P800
M300 S440 P400 ; plays a tone at 440 Hz for 200 ms
G4 P800
