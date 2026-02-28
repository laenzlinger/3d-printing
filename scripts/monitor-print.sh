#!/bin/bash
# Monitor print progress with nice terminal UI

PRINTER="3d.laenzlinger.net"
INTERVAL=${1:-10}  # Default 10 seconds

# Clear screen and hide cursor
clear
tput civis
trap 'tput cnorm; exit' INT TERM EXIT

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                         3D Printer Monitor                                 ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

while true; do
    # Move cursor to line 5
    tput cup 4 0
    
    ssh $PRINTER 'curl -s "http://localhost:7125/printer/objects/query?print_stats&extruder&heater_bed&display_status&toolhead"' | python3 -c "
import sys, json, time
try:
    d = json.load(sys.stdin)['result']['status']
    ps = d['print_stats']
    e = d['extruder']
    b = d['heater_bed']
    ds = d.get('display_status', {})
    th = d.get('toolhead', {})
    
    progress = ds.get('progress', 0) * 100
    state = ps['state']
    filename = ps.get('filename', 'N/A')
    print_duration = ps.get('print_duration', 0)
    
    # Format time
    hours = int(print_duration // 3600)
    minutes = int((print_duration % 3600) // 60)
    seconds = int(print_duration % 60)
    
    # Progress bar
    bar_width = 50
    filled = int(bar_width * progress / 100)
    bar = '█' * filled + '░' * (bar_width - filled)
    
    # State with color indicator
    state_indicator = {
        'printing': '🟢',
        'paused': '🟡',
        'complete': '✅',
        'error': '🔴',
        'cancelled': '⚠️',
        'standby': '⚪'
    }.get(state, '⚪')
    
    print(f'Status: {state_indicator} {state.upper():12}')
    print(f'File:   {filename[:60]}')
    print(f'Time:   {hours:02d}:{minutes:02d}:{seconds:02d}')
    print()
    print(f'Progress: [{bar}] {progress:5.1f}%')
    print()
    print(f'🌡️  Hotend: {e[\"temperature\"]:6.1f}°C / {e[\"target\"]:3.0f}°C  [{\"█\" * int(e[\"temperature\"]/e[\"target\"]*10) if e[\"target\"] > 0 else \"\"}]')
    print(f'🛏️  Bed:    {b[\"temperature\"]:6.1f}°C / {b[\"target\"]:3.0f}°C  [{\"█\" * int(b[\"temperature\"]/b[\"target\"]*10) if b[\"target\"] > 0 else \"\"}]')
    print()
    print(f'Position: X:{th.get(\"position\", [0,0,0,0])[0]:6.2f} Y:{th.get(\"position\", [0,0,0,0])[1]:6.2f} Z:{th.get(\"position\", [0,0,0,0])[2]:6.2f}')
    print()
    print(f'Last update: {time.strftime(\"%H:%M:%S\")}')
    print()
    print('Press Ctrl+C to exit')
    
    if state == 'complete':
        print()
        print('╔════════════════════════════════════════════════════════════════════════════╗')
        print('║                          ✅ PRINT COMPLETE! ✅                              ║')
        print('╚════════════════════════════════════════════════════════════════════════════╝')
        exit(1)
    elif state == 'error':
        print()
        print('╔════════════════════════════════════════════════════════════════════════════╗')
        print('║                            🔴 PRINT ERROR! 🔴                              ║')
        print('╚════════════════════════════════════════════════════════════════════════════╝')
        exit(1)
    elif state == 'cancelled':
        print()
        print('╔════════════════════════════════════════════════════════════════════════════╗')
        print('║                          ⚠️  PRINT CANCELLED! ⚠️                            ║')
        print('╚════════════════════════════════════════════════════════════════════════════╝')
        exit(1)
except Exception as e:
    print(f'Error connecting to printer: {e}')
" 2>/dev/null || break
    
    sleep $INTERVAL
done

# Restore cursor
tput cnorm
