#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PROFILE_DIR="$REPO_DIR/orca-profiles"
PRINTER="192.168.1.142"
OUTPUT_DIR="$REPO_DIR/generated"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <file.stl>

Slice an STL file with OrcaSlicer and optionally upload to printer.

Options:
  -m, --material NAME   Filament profile (default: Creality PLA Matte)
  -p, --process NAME    Process profile (default: PLA Tuned)
  -u, --upload          Upload gcode to printer via Moonraker
  -s, --start           Upload and start printing
  -l, --list            List available profiles
  -h, --help            Show this help

Materials: $(ls "$PROFILE_DIR/filament/" | sed 's/ @Ender3V2Neo.json//;s/^/  /')
Processes: $(ls "$PROFILE_DIR/process/" | sed 's/ @Ender3V2Neo.json//;s/^/  /')
EOF
    exit 0
}

list_profiles() {
    echo "Filaments:"
    ls "$PROFILE_DIR/filament/" | sed 's/ @Ender3V2Neo.json//'
    echo ""
    echo "Processes:"
    ls "$PROFILE_DIR/process/" | sed 's/ @Ender3V2Neo.json//'
    exit 0
}

MATERIAL="Creality PLA Matte"
PROCESS="PLA Tuned"
UPLOAD=false
START=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--material) MATERIAL="$2"; shift 2 ;;
        -p|--process) PROCESS="$2"; shift 2 ;;
        -u|--upload) UPLOAD=true; shift ;;
        -s|--start) UPLOAD=true; START=true; shift ;;
        -l|--list) list_profiles ;;
        -h|--help) usage ;;
        *) STL="$1"; shift ;;
    esac
done

if [[ -z "${STL:-}" ]]; then
    echo "Error: No STL file specified" >&2
    usage
fi

if [[ ! -f "$STL" ]]; then
    echo "Error: File not found: $STL" >&2
    exit 1
fi

FILAMENT="$PROFILE_DIR/filament/${MATERIAL} @Ender3V2Neo.json"
PROCESS_FILE="$PROFILE_DIR/process/${PROCESS} @Ender3V2Neo.json"
MACHINE="$PROFILE_DIR/machine/Ender 3 V2 Neo (Klipper) 0.4 nozzle.json"

for f in "$FILAMENT" "$PROCESS_FILE" "$MACHINE"; do
    if [[ ! -f "$f" ]]; then
        echo "Error: Profile not found: $f" >&2
        echo "Run: $(basename "$0") --list" >&2
        exit 1
    fi
done

BASENAME="$(basename "${STL%.stl}")"
OUTPUT_3MF="$OUTPUT_DIR/${BASENAME}.3mf"
mkdir -p "$OUTPUT_DIR"

echo "Slicing: $STL"
echo "  Material: $MATERIAL"
echo "  Process:  $PROCESS"

orca-slicer \
    --load-settings "$MACHINE;$PROCESS_FILE" \
    --load-filaments "$FILAMENT" \
    --slice 0 \
    --export-3mf "$OUTPUT_3MF" \
    "$STL" 2>&1 | grep -v "thumbnail\|glew\|DRI_PRIME\|opengl" || true

if [[ ! -f "$OUTPUT_3MF" ]]; then
    echo "Error: Slicing failed" >&2
    exit 1
fi

# Extract gcode from 3mf
GCODE="$OUTPUT_DIR/${BASENAME}.gcode"
python3 -c "
import zipfile, sys
with zipfile.ZipFile('$OUTPUT_3MF') as z:
    for name in z.namelist():
        if name.endswith('.gcode'):
            with open('$GCODE', 'wb') as f:
                f.write(z.read(name))
            break
"

if [[ ! -f "$GCODE" ]]; then
    echo "Error: No gcode found in output" >&2
    exit 1
fi

# Print summary
TIME=$(grep "^M73 P0 R" "$GCODE" | head -1 | sed 's/.*R//')
LAYERS=$(grep "^; total layer number:" "$GCODE" | awk '{print $NF}')
echo ""
echo "✓ Sliced: $GCODE"
echo "  Est. time: ~${TIME:-?} min"
echo "  Layers:    ${LAYERS:-?}"

if $UPLOAD; then
    GCODE_NAME="CE3E3V2_${BASENAME}.gcode"
    echo ""
    echo "Uploading to printer..."
    curl -s -F "file=@${GCODE};filename=${GCODE_NAME}" \
        "http://${PRINTER}:7125/server/files/upload" > /dev/null
    echo "✓ Uploaded: $GCODE_NAME"

    if $START; then
        echo "Starting print..."
        curl -s -X POST "http://${PRINTER}:7125/printer/print/start" \
            -H "Content-Type: application/json" \
            -d "{\"filename\": \"${GCODE_NAME}\"}" > /dev/null
        echo "✓ Print started!"
    fi
fi
