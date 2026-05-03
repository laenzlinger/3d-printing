.PHONY: help all clean

.DEFAULT_GOAL := help

# Parts generation
DISPLAY_WRAPPER ?=
GEN := ./generated
SRC := ./parts
SRCS := $(wildcard $(SRC)/*.scad)
STLS := $(patsubst $(SRC)/%.scad,$(GEN)/%.stl,$(SRCS))
PNGS := $(patsubst $(SRC)/%.scad,$(GEN)/%.png,$(SRCS))

# Printer management
PRINTER := 192.168.1.142
BACKUP_REPO := ../klipper-backup
CONFIG_DIR := printer_data/config
SOURCE_CONFIG := printer_data/config

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Parts targets
all: $(STLS) $(PNGS) ## Generate all STL and PNG files from SCAD sources

OPENSCAD_FLAGS := --enable textmetrics

$(GEN)/%.stl: $(SRC)/%.scad | $(GEN)
	openscad $(OPENSCAD_FLAGS) -o $@ $<

$(GEN)/%.png: $(SRC)/%.scad | $(GEN)
	$(DISPLAY_WRAPPER) openscad $(OPENSCAD_FLAGS) -o $@ --autocenter --viewall --colorscheme=Nature --imgsize=1200,800 $<

$(GEN):
	mkdir -p $(GEN)

clean: ## Remove generated files
	rm -f $(STLS) $(PNGS)

# Printer management targets
verify: ## Compare source with live printer config
	@echo "Comparing source config with live config..."
	@ssh $(PRINTER) "cat ~/$(CONFIG_DIR)/printer.cfg" > /tmp/live-printer.cfg
	@if diff -q $(SOURCE_CONFIG)/printer.cfg /tmp/live-printer.cfg > /dev/null; then \
		echo "✓ Source is in sync with live config"; \
	else \
		echo "✗ Source differs from live config:"; \
		diff -u $(SOURCE_CONFIG)/printer.cfg /tmp/live-printer.cfg; \
		exit 1; \
	fi

deploy: check-calibration ## Deploy configuration to printer
	@echo "Deploying configuration to printer..."
	rsync -av --exclude='*.bak' --exclude='*.bkp' $(SOURCE_CONFIG)/ $(PRINTER):~/$(CONFIG_DIR)/
	@echo "Restarting Klipper..."
	ssh $(PRINTER) "sudo systemctl restart klipper"
	@sleep 3
	@echo "Checking status..."
	@ssh $(PRINTER) "systemctl status klipper --no-pager -l 0"
	@echo "✓ Deployment complete!"

check-calibration: ## Check if deploy would overwrite newer calibration data
	@echo "Checking for calibration data changes..."
	@ssh $(PRINTER) "cat ~/$(CONFIG_DIR)/printer.cfg" > /tmp/live-printer.cfg
	@live_cal=$$(sed -n '/^#\*#/,$$p' /tmp/live-printer.cfg); \
	local_cal=$$(sed -n '/^#\*#/,$$p' $(SOURCE_CONFIG)/printer.cfg); \
	if [ "$$live_cal" != "$$local_cal" ]; then \
		echo "⚠ WARNING: Printer has different calibration data (PID/z_offset/bed mesh):"; \
		diff -u <(echo "$$local_cal") <(echo "$$live_cal") || true; \
		echo ""; \
		read -p "Overwrite printer calibration? [y/N/m=merge] " confirm; \
		if [ "$$confirm" = "m" ] || [ "$$confirm" = "M" ]; then \
			echo "Merging: local config + printer calibration data..."; \
			sed '/^#\*#/,$$d' $(SOURCE_CONFIG)/printer.cfg > /tmp/deploy-merged.cfg; \
			echo "" >> /tmp/deploy-merged.cfg; \
			sed -n '/^#\*#/,$$p' /tmp/live-printer.cfg >> /tmp/deploy-merged.cfg; \
			rsync -av /tmp/deploy-merged.cfg $(PRINTER):~/$(CONFIG_DIR)/printer.cfg; \
			cp /tmp/deploy-merged.cfg $(SOURCE_CONFIG)/printer.cfg; \
			ssh $(PRINTER) "sudo systemctl restart klipper"; \
			sleep 3; \
			ssh $(PRINTER) "systemctl status klipper --no-pager -l 0"; \
			echo "✓ Merged and deployed"; \
			exit 0; \
		elif [ "$$confirm" != "y" ] && [ "$$confirm" != "Y" ]; then \
			echo "✗ Deploy aborted. Run 'make sync-from-live' to pull latest calibration first."; \
			exit 1; \
		fi; \
	else \
		echo "✓ Calibration data in sync"; \
	fi

status: ## Check printer system status
	@ssh $(PRINTER) "systemctl status klipper moonraker crowsnest --no-pager -l 0"

logs: ## View Klipper logs (last 50 lines)
	@ssh $(PRINTER) "tail -50 ~/printer_data/logs/klippy.log"

logs-follow: ## Follow Klipper logs in real-time
	@ssh $(PRINTER) "tail -f ~/printer_data/logs/klippy.log"

restart: ## Restart Klipper service
	@echo "Restarting Klipper..."
	@ssh $(PRINTER) "sudo systemctl restart klipper"
	@sleep 2
	@$(MAKE) status

pull-backup: ## Pull latest backup from GitHub
	@cd $(BACKUP_REPO) && git pull --rebase

sync-from-backup: pull-backup ## Sync config from backup repo to source
	@echo "Syncing from backup to source..."
	@cp $(BACKUP_REPO)/$(CONFIG_DIR)/printer.cfg $(SOURCE_CONFIG)/
	@echo "✓ Synced from backup"

sync-from-live: ## Pull config directly from live printer to source
	@echo "Syncing from live printer to source..."
	@ssh $(PRINTER) "cat ~/$(CONFIG_DIR)/printer.cfg" > $(SOURCE_CONFIG)/printer.cfg
	@echo "✓ Synced from live printer"

ssh: ## SSH into printer
	@ssh $(PRINTER)

monitor: ## Monitor current print progress
	@./scripts/monitor-print.py

slice: ## Slice STL: make slice STL=file.stl [MATERIAL=name] [PROCESS=name] [BRIM=1]
	@./scripts/slice.sh $(if $(BRIM),--brim) $(if $(MATERIAL),-m "$(MATERIAL)") $(if $(PROCESS),-p "$(PROCESS)") "$(STL)"

slice-upload: ## Slice and upload: make slice-upload STL=file.stl [BRIM=1]
	@./scripts/slice.sh -u $(if $(BRIM),--brim) $(if $(MATERIAL),-m "$(MATERIAL)") $(if $(PROCESS),-p "$(PROCESS)") "$(STL)"

slice-print: ## Slice, upload and start: make slice-print STL=file.stl [BRIM=1]
	@./scripts/slice.sh -s $(if $(BRIM),--brim) $(if $(MATERIAL),-m "$(MATERIAL)") $(if $(PROCESS),-p "$(PROCESS)") "$(STL)"

first-layer-test: ## Print first layer test patches across the bed
	@./scripts/slice.sh -s calibration/first_layer_patches.stl

z-calibrate: ## Run Z-offset calibration (8 segments with labels)
	@./scripts/z-calibrate.sh

profiles: ## List available slicer profiles
	@./scripts/slice.sh --list

monitor-simple: ## Monitor print (simple text output)
	@watch -n 10 'ssh $(PRINTER) "curl -s \"http://localhost:7125/printer/objects/query?print_stats&extruder&heater_bed&display_status\" | python3 -c \"import sys,json; d=json.load(sys.stdin)[\"result\"][\"status\"]; ps=d[\"print_stats\"]; e=d[\"extruder\"]; b=d[\"heater_bed\"]; ds=d.get(\"display_status\",{}); print(f\\\"State: {ps[\\\"state\\\"]} | Progress: {ds.get(\\\"progress\\\",0)*100:.1f}%\\\"); print(f\\\"File: {ps.get(\\\"filename\\\",\\\"N/A\\\")}\\\"); print(f\\\"Hotend: {e[\\\"temperature\\\"]:.1f}°C/{e[\\\"target\\\"]:.0f}°C | Bed: {b[\\\"temperature\\\"]:.1f}°C/{b[\\\"target\\\"]:.0f}°C\\\")\""'



# Calibration targets
petg-preheat: ## Preheat bed and nozzle for PETG (240/80°C)
	@echo "Preheating for PETG (240°C / 80°C)..."
	@ssh $(PRINTER) 'curl -s -X POST http://localhost:7125/printer/gcode/script -H "Content-Type: application/json" -d "{\"script\":\"M140 S80\nM104 S240\nM190 S80\nM109 S240\"}"'
	@echo "✓ Preheat started"

pla-preheat: ## Preheat bed and nozzle for PLA (210/60°C)
	@echo "Preheating for PLA (210°C / 60°C)..."
	@ssh $(PRINTER) 'curl -s -X POST http://localhost:7125/printer/gcode/script -H "Content-Type: application/json" -d "{\"script\":\"M140 S60\nM104 S210\nM190 S60\nM109 S210\"}"'
	@echo "✓ Preheat started"

petg-bed-mesh: ## Bed mesh calibration at PETG temps (80°C), saves as 'petg' profile
	@echo "Running bed mesh calibration at PETG bed temp (80°C)..."
	@ssh $(PRINTER) 'curl -s -X POST http://localhost:7125/printer/gcode/script -H "Content-Type: application/json" -d "{\"script\":\"M140 S80\nM190 S80\nG28\nBED_MESH_CALIBRATE PROFILE=petg\nSAVE_CONFIG\"}"'
	@echo "✓ Bed mesh 'petg' saved. Load with: BED_MESH_PROFILE LOAD=petg"

pla-bed-mesh: ## Bed mesh calibration at PLA temps (60°C), saves as 'pla' profile
	@echo "Running bed mesh calibration at PLA bed temp (60°C)..."
	@ssh $(PRINTER) 'curl -s -X POST http://localhost:7125/printer/gcode/script -H "Content-Type: application/json" -d "{\"script\":\"M140 S60\nM190 S60\nG28\nBED_MESH_CALIBRATE PROFILE=pla\nSAVE_CONFIG\"}"'
	@echo "✓ Bed mesh 'pla' saved. Load with: BED_MESH_PROFILE LOAD=pla"
