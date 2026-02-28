#!/usr/bin/env python3
"""Simple print monitor - outputs status updates without terminal control"""

import sys
import time
import json
import subprocess
from datetime import timedelta

PRINTER = "3d.laenzlinger.net"
INTERVAL = 10

def get_printer_status():
    """Fetch printer status from Moonraker API"""
    cmd = [
        "ssh", PRINTER,
        'curl -s "http://localhost:7125/printer/objects/query?print_stats&extruder&heater_bed&display_status&toolhead"'
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        data = json.loads(result.stdout)
        return data['result']['status']
    except Exception as e:
        return None

def format_duration(seconds):
    """Format seconds as HH:MM:SS"""
    return str(timedelta(seconds=int(seconds))).zfill(8)

def display_status(status):
    """Display printer status"""
    if not status:
        print("ERROR: Cannot connect to printer")
        return False
    
    ps = status['print_stats']
    e = status['extruder']
    b = status['heater_bed']
    ds = status.get('display_status', {})
    th = status.get('toolhead', {})
    
    state = ps['state']
    filename = ps.get('filename', 'N/A')
    progress = ds.get('progress', 0) * 100
    duration = ps.get('print_duration', 0)
    position = th.get('position', [0, 0, 0, 0])
    
    print(f"\n{'='*80}")
    print(f"Time: {time.strftime('%H:%M:%S')} | State: {state.upper()} | Progress: {progress:.1f}%")
    print(f"File: {filename}")
    print(f"Duration: {format_duration(duration)}")
    print(f"Hotend: {e['temperature']:.1f}°C / {e['target']:.0f}°C | Bed: {b['temperature']:.1f}°C / {b['target']:.0f}°C")
    print(f"Position: X:{position[0]:.2f} Y:{position[1]:.2f} Z:{position[2]:.2f}")
    print(f"{'='*80}")
    
    # Check for completion
    if state == 'complete':
        print("\n*** PRINT COMPLETE! ***\n")
        return True
    elif state == 'error':
        print("\n*** PRINT ERROR! ***\n")
        return True
    elif state == 'cancelled':
        print("\n*** PRINT CANCELLED! ***\n")
        return True
    
    return False

def main():
    """Main monitoring loop"""
    print("Monitoring print progress (Ctrl+C to stop)...\n")
    
    try:
        while True:
            status = get_printer_status()
            done = display_status(status)
            
            if done:
                break
            
            time.sleep(INTERVAL)
    except KeyboardInterrupt:
        print("\n\nMonitoring stopped.")
        sys.exit(0)

if __name__ == "__main__":
    main()
