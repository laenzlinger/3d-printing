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
PRINTER := 3d.laenzlinger.net
BACKUP_REPO := ../klipper-backup
CONFIG_DIR := printer_data/config
SOURCE_CONFIG := printer_data/config

# Include PETG targets
include Makefile.petg

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Parts targets
all: $(STLS) $(PNGS) ## Generate all STL and PNG files from SCAD sources

$(GEN)/%.stl: $(SRC)/%.scad | $(GEN)
	openscad -o $@ $<

$(GEN)/%.png: $(SRC)/%.scad | $(GEN)
	$(DISPLAY_WRAPPER) openscad -o $@ --autocenter --viewall --colorscheme=Nature --imgsize=1200,800 $<

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

deploy: ## Deploy configuration to printer
	@echo "Deploying configuration to printer..."
	rsync -av --exclude='*.bak' --exclude='*.bkp' $(SOURCE_CONFIG)/ $(PRINTER):~/$(CONFIG_DIR)/
	@echo "Restarting Klipper..."
	ssh $(PRINTER) "sudo systemctl restart klipper"
	@sleep 3
	@echo "Checking status..."
	@ssh $(PRINTER) "systemctl status klipper --no-pager -l 0"
	@echo "✓ Deployment complete!"

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

monitor-simple: ## Monitor print (simple text output)
	@watch -n 10 'ssh $(PRINTER) "curl -s \"http://localhost:7125/printer/objects/query?print_stats&extruder&heater_bed&display_status\" | python3 -c \"import sys,json; d=json.load(sys.stdin)[\"result\"][\"status\"]; ps=d[\"print_stats\"]; e=d[\"extruder\"]; b=d[\"heater_bed\"]; ds=d.get(\"display_status\",{}); print(f\\\"State: {ps[\\\"state\\\"]} | Progress: {ds.get(\\\"progress\\\",0)*100:.1f}%\\\"); print(f\\\"File: {ps.get(\\\"filename\\\",\\\"N/A\\\")}\\\"); print(f\\\"Hotend: {e[\\\"temperature\\\"]:.1f}°C/{e[\\\"target\\\"]:.0f}°C | Bed: {b[\\\"temperature\\\"]:.1f}°C/{b[\\\"target\\\"]:.0f}°C\\\")\""'

