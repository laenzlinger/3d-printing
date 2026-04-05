#!/bin/bash
set -euo pipefail

# Z-offset calibration: center circle + 8 labeled pie segments
# Center = current Z-offset, segments = -100 to +100 microns adjustment
# Auto-cancels after first layer. Pick the best segment and adjust z_offset.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PRINTER="192.168.1.142"
SEGS="$REPO_DIR/calibration/z_segments"
GCODE="$REPO_DIR/generated/z_offset_calibration.gcode"
THREE_MF="$REPO_DIR/generated/z_offset_calibration.3mf"

echo "Slicing Z-offset calibration (center + 8 segments)..."
orca-slicer \
    --load-settings "$REPO_DIR/orca-profiles/machine/Ender 3 V2 Neo (Klipper) 0.4 nozzle.json;$REPO_DIR/orca-profiles/process/PLA Tuned @Ender3V2Neo.json" \
    --load-filaments "$REPO_DIR/orca-profiles/filament/Creality PLA Matte @Ender3V2Neo.json" \
    --arrange 0 \
    --slice 0 \
    --export-3mf "$THREE_MF" \
    "$REPO_DIR/calibration/z_center.stl" \
    "$SEGS/seg_0.stl" "$SEGS/seg_1.stl" "$SEGS/seg_2.stl" "$SEGS/seg_3.stl" \
    "$SEGS/seg_4.stl" "$SEGS/seg_5.stl" "$SEGS/seg_6.stl" "$SEGS/seg_7.stl" \
    2>&1 | grep -v "thumbnail\|glew\|DRI_PRIME\|opengl" || true

# Extract gcode from 3mf
python3 -c "
import zipfile
with zipfile.ZipFile('$THREE_MF') as z:
    for name in z.namelist():
        if name.endswith('.gcode'):
            with open('$GCODE', 'wb') as f:
                f.write(z.read(name))
            break
"

# Inject Z adjustments between objects and auto-cancel after layer 1
python3 << PYEOF
adjustments = [0.000, -0.100, -0.075, -0.050, -0.025, +0.025, +0.050, +0.075, +0.100]

with open("$GCODE") as f:
    lines = f.readlines()

layer = 0
obj_count = 0
prev_adj = 0
out = []
for line in lines:
    if ';LAYER_CHANGE' in line:
        layer += 1
        if layer == 2:
            out.append(line)
            out.append(f'SET_GCODE_OFFSET Z_ADJUST={-prev_adj:.3f}\n')
            out.append('CANCEL_PRINT\n')
            break
    if layer == 1 and '; printing object' in line and 'stop' not in line:
        if obj_count < len(adjustments):
            adj = adjustments[obj_count]
            delta = adj - prev_adj
            if delta != 0:
                out.append(f'SET_GCODE_OFFSET Z_ADJUST={delta:.3f}\n')
            prev_adj = adj
            obj_count += 1
    out.append(line)

with open("$GCODE", 'w') as f:
    f.writelines(out)
PYEOF

echo ""
echo "Segments (offset in microns, labeled as cutouts):"
echo "  Center:  0 (current z_offset)"
echo "  Around: -100  -75  -50  -25  +25  +50  +75  +100"
echo ""
echo "Uploading and starting..."
curl -s -F "file=@${GCODE};filename=CE3E3V2_z_offset_calibration.gcode" \
    "http://${PRINTER}:7125/server/files/upload" > /dev/null
curl -s -X POST -H "Content-Type: application/json" \
    "http://${PRINTER}:7125/printer/print/start" \
    -d '{"filename":"CE3E3V2_z_offset_calibration.gcode"}' > /dev/null

echo "✓ Calibration print started! Auto-cancels after first layer."
echo ""
echo "After print: pick the best segment, then adjust z_offset:"
echo "  Current z_offset: $(grep 'z_offset' $REPO_DIR/printer_data/config/printer.cfg | tail -1 | awk '{print $NF}')"
echo "  Example: if -25 looks best, subtract 0.025 from current value"
