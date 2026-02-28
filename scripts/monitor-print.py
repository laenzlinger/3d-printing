#!/usr/bin/env python3
"""Monitor 3D printer progress with live terminal UI"""

import sys
import time
import json
import subprocess
import signal
import os
from datetime import timedelta

PRINTER = "3d.laenzlinger.net"
INTERVAL = 10  # seconds

# Detect if we're in a proper terminal
SIMPLE_MODE = not sys.stdout.isatty() or os.getenv('TERM') == 'dumb'

def signal_handler(sig, frame):
    """Clean exit on Ctrl+C"""
    print("\033[?25h")  # Show cursor
    print("\n\nMonitoring stopped.")
    sys.exit(0)

def clear_screen():
    """Clear terminal screen"""
    print("\033[2J\033[H", end="")

def hide_cursor():
    """Hide terminal cursor"""
    print("\033[?25l", end="")

def show_cursor():
    """Show terminal cursor"""
    print("\033[?25h", end="")

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

def progress_bar(percent, width=50):
    """Create a progress bar"""
    filled = int(width * percent / 100)
    return '█' * filled + '░' * (width - filled)

def temp_bar(current, target, width=10):
    """Create a temperature indicator bar"""
    if target == 0:
        return ''
    percent = min(current / target, 1.0)
    filled = int(width * percent)
    return '█' * filled

def get_state_indicator(state):
    """Get emoji indicator for print state"""
    indicators = {
        'printing': '🟢',
        'paused': '🟡',
        'complete': '✅',
        'error': '🔴',
        'cancelled': '⚠️',
        'standby': '⚪'
    }
    return indicators.get(state, '⚪')

def display_status(status):
    """Display printer status in terminal"""
    if not status:
        print("❌ Error: Cannot connect to printer")
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
    
    # Clear and redraw
    clear_screen()
    
    print("╔════════════════════════════════════════════════════════════════════════════╗")
    print("║                         3D Printer Monitor                                 ║")
    print("╚════════════════════════════════════════════════════════════════════════════╝")
    print()
    print(f"Status:   {get_state_indicator(state)} {state.upper()}")
    print(f"File:     {filename[:60]}")
    print(f"Duration: {format_duration(duration)}")
    print()
    print(f"Progress: [{progress_bar(progress)}] {progress:5.1f}%")
    print()
    print(f"🌡️  Hotend: {e['temperature']:6.1f}°C / {e['target']:3.0f}°C  [{temp_bar(e['temperature'], e['target'])}]")
    print(f"🛏️  Bed:    {b['temperature']:6.1f}°C / {b['target']:3.0f}°C  [{temp_bar(b['temperature'], b['target'])}]")
    print()
    print(f"Position: X:{position[0]:7.2f}  Y:{position[1]:7.2f}  Z:{position[2]:7.2f}")
    print()
    print(f"Last update: {time.strftime('%H:%M:%S')}")
    print()
    print("Press Ctrl+C to exit")
    
    # Check for completion
    if state == 'complete':
        print()
        print("╔════════════════════════════════════════════════════════════════════════════╗")
        print("║                          ✅ PRINT COMPLETE! ✅                              ║")
        print("╚════════════════════════════════════════════════════════════════════════════╝")
        return True
    elif state == 'error':
        print()
        print("╔════════════════════════════════════════════════════════════════════════════╗")
        print("║                            🔴 PRINT ERROR! 🔴                              ║")
        print("╚════════════════════════════════════════════════════════════════════════════╝")
        return True
    elif state == 'cancelled':
        print()
        print("╔════════════════════════════════════════════════════════════════════════════╗")
        print("║                          ⚠️  PRINT CANCELLED! ⚠️                            ║")
        print("╚════════════════════════════════════════════════════════════════════════════╝")
        return True
    
    return False

def main():
    """Main monitoring loop"""
    signal.signal(signal.SIGINT, signal_handler)
    
    hide_cursor()
    
    try:
        while True:
            status = get_printer_status()
            done = display_status(status)
            
            if done:
                break
            
            time.sleep(INTERVAL)
    finally:
        show_cursor()

if __name__ == "__main__":
    main()
