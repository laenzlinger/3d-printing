; Professional Firmware Configuration File
;=====================================================
C10                    ; Mark as a configuration file
M117 Applying configuration
;-----------------------------------------------------
C100 X-7 Y0            ; Set XY Min position to 0
C101 X231 Y231 Z250    ; Set XYZ Max position
C102 X220 Y220         ; Set a bed size of 220x220
C29 L30.50 R189.50 F30.50 B189.50 N5 T50 ; Set Mesh insets, size of 5x5 and bed at 50°C
C851 S480 M0           ; Probe feedrate and disable multiple probing
C412 M0                ; Filament sensor active mode: LOW
M256 B127              ; Set Brightness 
M413 S0                ; Disable Powerloss recovery
M603 L0.00 U100.00     ; Configure Filament Change
M851 X-41.50 Y-7.00 Z-2.70 ; Z-Probe Offset: (mm)
M500                   ; Save all settings
;-----------------------------------------------------
G4 S1                  ; Wait a second
M300 P200              ; Beep
M117 Configuration Applied
;-----------------------------------------------------

