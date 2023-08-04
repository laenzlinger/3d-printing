
.PHONY: backup

backup:
	rm -rf backup
	ssh octo@octo '/home/octo/oprint/bin/octoprint plugins backup:backup --path /tmp/backup.zip --exclude uploads --exclude timelapse'
	scp octo@octo:/tmp/backup.zip ./backup.zip
	unzip backup.zip -d backup
	rm backup.zip

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
