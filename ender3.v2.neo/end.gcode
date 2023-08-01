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
