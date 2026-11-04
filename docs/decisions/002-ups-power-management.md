# ADR 002: UPS Power Management and Solar-Scheduled Charging

**Date:** 2026-11-04
**Status:** Accepted (implementation pending)

## Context

The RPi5 running Klipper is protected by a Waveshare UPS HAT (E) (I2C address `0x2d`).
The UPS is always powered from a permanent (non-switched) outlet. The RPi should only
run while printing — it does not need to be always on.

Three problems need solving:

1. **Remote on/off**: The UPS is always powered, so cutting the smart plug does not
   turn off the RPi. Turning the RPi off via OS shutdown is easy, but there is no
   remote wake mechanism without additional hardware.

2. **Energy**: The UPS battery charges whenever input power is available. The house has
   two SolarEdge inverters whose output is tracked in Home Assistant via
   `sensor.solar_excess_power`. Charging should be aligned to solar surplus to avoid
   drawing from the grid.

3. **Print state preservation on power loss**: If mains power is lost mid-print, the RPi
   must not be hard-killed. The UPS provides battery time to cancel the print gracefully
   (park head, turn off heaters), save the print state (file name, progress, layer), and
   shut down cleanly. Without this, a power loss leaves the hotend potentially at
   temperature, the head in an arbitrary position, and the print state unknown on restart.

### UPS HAT (E) Boot-on-Power Mechanism

The UPS has a register-based restart feature:

```bash
i2cset -y 1 0x2d 0x01 0x55
```

After writing `0x55`:
1. UPS disconnects RPi power after 30 seconds (OS must shut down in this window)
2. After 60 seconds, UPS checks the Type-C charging input
3. If input power is present → boots the RPi
4. If input power is absent → stays off

This means whether the RPi restarts after shutdown depends entirely on whether the
Type-C charging input has power at the 60-second mark.

## Decision

Add a **Zigbee smart plug on the UPS Type-C charging input** (`switch.3d_ups_charging`).
This single addition solves both problems:

- **Remote OFF**: send OS shutdown; RPi halts cleanly
- **Remote ON**: turn on `switch.3d_ups_charging`; RPi boots because `0x55` was written
  during the last shutdown
- **Solar charging**: HA automation controls the charging plug based on solar surplus

### Architecture

```
Permanent outlet
  → switch.3d_ups_charging (Zigbee plug)      ← HA-controlled
  → UPS HAT (E) Type-C input (charging)
  → UPS battery
  → UPS output
  → Raspberry Pi 5

switch.3d_printer_power (existing Zigbee plug) ← unchanged, controls printer mains
```

### Shutdown Sequence (updated)

A systemd shutdown service writes `0x55` to the UPS as the final step before OS halt.
This arms the "boot when charging detected" mechanism for the next power-on.

```
/etc/systemd/system/ups-shutdown.service
  Type=oneshot
  ExecStop=i2cset -y 1 0x2d 0x01 0x55
  RemainAfterExit=yes
  DefaultDependencies=no
  Before=shutdown.target
```

### Power ON Sequence

1. HA turns on `switch.3d_ups_charging`
2. UPS detects input power at next 60-second check
3. RPi boots, Klipper/Moonraker start up
4. HA detects `sensor.3d_printer_state` → `ready`

### Power OFF Sequence (manual or end-of-print)

1. HA calls `rest_command.printer_shutdown` (Moonraker API)
2. Wait 30 seconds for OS to halt
3. UPS writes `0x55` via shutdown service → arms boot-on-power
4. HA turns off `switch.3d_printer_power` (printer mains)
5. (Optional) HA turns off `switch.3d_ups_charging` if outside solar hours

### Solar Charging Automation

```yaml
# home-assistant-config/automations.yaml additions:

- id: 3d_ups_charge_solar_on
  alias: "3D UPS: start charging on solar surplus"
  trigger:
    - platform: numeric_state
      entity_id: sensor.solar_excess_power
      above: 100  # tune after observing typical idle draw
  condition:
    - condition: state
      entity_id: switch.3d_ups_charging
      state: "off"
  action:
    - action: switch.turn_on
      target:
        entity_id: switch.3d_ups_charging

- id: 3d_ups_charge_solar_off
  alias: "3D UPS: stop charging when solar drops"
  trigger:
    - platform: numeric_state
      entity_id: sensor.solar_excess_power
      below: 50
      for: "00:05:00"  # debounce — avoid toggling on passing clouds
  condition:
    - condition: state
      entity_id: switch.3d_ups_charging
      state: "on"
    - condition: numeric_state    # don't cut charging if battery is low
      entity_id: sensor.3d_ups_battery_level
      above: 20
  action:
    - action: switch.turn_off
      target:
        entity_id: switch.3d_ups_charging

- id: 3d_ups_charge_emergency
  alias: "3D UPS: emergency charge when battery low"
  trigger:
    - platform: numeric_state
      entity_id: sensor.3d_ups_battery_level
      below: 20
  action:
    - action: switch.turn_on
      target:
        entity_id: switch.3d_ups_charging
```

### Power Loss Response Sequence

When the UPS daemon detects input power is lost (Type-C charging gone, battery discharging):

1. Call Moonraker API: `POST /printer/gcode/script` with gcode `CANCEL_PRINT`
   - Klipper executes the `CANCEL_PRINT` macro: parks head, turns off heaters and fans
2. Call Moonraker API: `GET /printer/objects/query?print_stats&virtual_sdcard` and
   save response to `/var/lib/ups-monitor/last_print_state.json`
   - Captures: filename, progress %, current layer, total layers, print duration
3. Publish `binary_sensor.3d_ups_on_battery: ON` to MQTT → HA notifies via mobile push
4. After 20 seconds (allowing CANCEL_PRINT to complete): `sudo systemctl poweroff`

On next boot, Moonraker's job history already records the interrupted print. The saved
`last_print_state.json` provides additional context (e.g. layer number) for deciding
whether to restart the print from scratch.

**Note:** Klipper does not currently support mid-print resume after power loss — the
print must be restarted from the beginning. The goal is a clean cancellation, not resume.
If Klipper adds power loss recovery in the future, the saved `last_print_state.json`
(position, layer, file) would provide the inputs needed to implement resume support.

**Third-party PLR plugins already exist** and can be integrated independently of this ADR:
- [klipper-plr](https://github.com/ankurv2k6/klipper-plr) — automated state saving and recovery
- [Yumi_PLR](https://github.com/Yumi-Lab/YUMI_PLR) — saves per-layer, adds `RESUME_INTERRUPTED` button in Mainsail
- [plr-klipper](https://github.com/The--Captain/plr-klipper) — slicer inserts `LOG_Z` macro at each layer change

All require the slicer to insert a state-save macro at each layer change (OrcaSlicer
supports this via "Layer change G-code"). The UPS + clean shutdown implemented here is
a prerequisite for PLR to work reliably — without a UPS, the MCU hard-kills too fast
to save state.

### UPS Monitoring Daemon

A Python systemd service on the RPi5 publishes UPS state to MQTT every 60 seconds
for Home Assistant auto-discovery, and reacts to power loss:

| HA Entity | MQTT Topic | Description |
|---|---|---|
| `sensor.3d_ups_battery_level` | `homeassistant/sensor/3d_ups/battery_level` | Battery % |
| `sensor.3d_ups_battery_voltage` | `homeassistant/sensor/3d_ups/battery_voltage` | Battery V |
| `sensor.3d_ups_input_power` | `homeassistant/sensor/3d_ups/input_power` | Charging W |
| `binary_sensor.3d_ups_charging` | `homeassistant/binary_sensor/3d_ups/charging` | Is charging |
| `binary_sensor.3d_ups_on_battery` | `homeassistant/binary_sensor/3d_ups/on_battery` | On battery (power lost) |

MQTT broker: `192.168.1.224:1883` (existing Mosquitto instance)

#### HA automation for power loss notification

```yaml
- id: 3d_ups_power_loss
  alias: "3D UPS: notify on power loss"
  trigger:
    - platform: state
      entity_id: binary_sensor.3d_ups_on_battery
      to: "on"
  action:
    - action: notify.mobile_app_laenzis
      data:
        title: "3D Drucker: Stromausfall"
        message: >
          Stromausfall erkannt. Druck wird abgebrochen und RPi fährt herunter.
          {% if states('sensor.3d_current_print_state') == 'printing' %}
          Datei: {{ states('sensor.3d_print_filename') }}
          {% endif %}
```

## Rationale

**Why cancel the print on power loss (not pause):**
- Klipper does not support mid-print resume after power loss — the exact head position,
  extruder state, and bed mesh calibration cannot be reliably restored
- A clean cancel (park + cool) is safer than leaving the head at temperature
- The print file is preserved in Moonraker history for easy restart

**Why a smart plug on the charging input (not the UPS output):**
- UPS output stays always powered → no risk of hard-killing the RPi
- Charging input controls only whether the battery charges
- As a side effect, it enables remote wake (0x55 mechanism checks charging input)

**Why `0x55` via systemd shutdown service (not via Moonraker):**
- Moonraker is stopped before OS halt; a systemd `Before=shutdown.target` service
  runs later and is more reliable for the final I2C write
- Decouples UPS behaviour from Moonraker; works even for manual `sudo shutdown`

**Why `sensor.solar_excess_power` (not raw SolarEdge sensor):**
- Already computed in HA as `max(solaredge_i1_m1_ac_power, 0)` — already accounts
  for negative values (grid draw) and two-inverter setup
- Consistent with how the dryer solar scheduling works

**Why 5-minute debounce on solar-off trigger:**
- Passing clouds cause short dips — avoid toggling the plug repeatedly
- UPS battery provides buffer during short interruptions

## Implementation Steps

1. [ ] Pair Zigbee plug, rename entity to `switch.3d_ups_charging`
2. [ ] Install UPS monitoring daemon (`/opt/ups-monitor/ups_monitor.py`) as systemd service
       - Publishes MQTT sensors every 60s
       - Detects power loss → cancel print → save state → shutdown
3. [ ] Install UPS shutdown service (`/etc/systemd/system/ups-shutdown.service`)
4. [ ] Add `CANCEL_PRINT` macro to `printer.cfg` if not already present (park head, cool)
5. [ ] Verify `0x55` mechanism: shutdown RPi, confirm UPS boots it when charging is restored
6. [ ] Add HA automations (solar charging + emergency charge + power loss notification)
7. [ ] Update `script.printer_safe_shutdown` to turn off `switch.3d_ups_charging` after shutdown
8. [ ] Add `script.printer_start` to HA: turn on charging plug + wait for Moonraker ready

## Consequences

**Positive:**
- UPS battery charges for free using solar surplus
- Remote on/off without additional microcontroller hardware
- UPS state visible in HA dashboard
- Graceful print cancellation on unexpected power loss (park head, cool, save state)
- Mobile notification on power loss with print context
- Print state saved to disk for reference on restart; provides inputs for future resume
  support if Klipper adds power loss recovery
- Third-party PLR plugins (Yumi_PLR, klipper-plr) can be added on top of this setup
  to enable actual print resume — the UPS is a prerequisite for reliable PLR

**Negative:**
- RPi does not boot immediately on power-on — 60-second delay from UPS check cycle
- `0x55` mechanism requires the previous shutdown to have completed cleanly
  (if RPi is hard-killed, `0x55` was not written and remote wake won't work
  until next clean shutdown)
- Battery level sensor required for emergency charge automation; if daemon is not
  running, the guard condition is unavailable

## References

- [Waveshare UPS HAT (E) documentation](https://www.waveshare.com/wiki/UPS_HAT_(E))
- [Waveshare UPS HAT (E) register manual](https://www.waveshare.com/wiki/UPS_HAT_(E)_Register)
- [ADR 001: RPi5 MainsailOS migration](001-klipper-host-migration-to-rpi5-mainsailos.md)
- [home-assistant-config automations.yaml](https://github.com/laenzlinger/home-assistant-config/blob/main/automations.yaml)
