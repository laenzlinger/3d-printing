
.PHONY: backup

.DEFAULT_GOAL := help

SSH_USER := laenzi
SSH_HOST := 3d
SSH := $(SSH_USER)@$(SSH_HOST)

PRINTER_CFG_SRC := ~/printer_data/config/printer.cfg
PRINTER_CFG_DST := ../ender3.v2.neo/printer.cfg

backup: ## backup octoprint and printer configuration
	rm -rf backup
	ssh $(SSH) '~/oprint/bin/octoprint plugins backup:backup --path /tmp/backup.zip --exclude uploads --exclude timelapse'
	scp $(SSH):/tmp/backup.zip ./backup.zip
	unzip backup.zip -d backup
	rm backup.zip
	scp $(SSH):$(PRINTER_CFG_SRC) $(PRINTER_CFG_DST)

restore: ## printer configuration
	scp $(PRINTER_CFG_DST) $(SSH):$(PRINTER_CFG_SRC)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
