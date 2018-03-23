# Gitlab

## Backup/Restore
gitlab-backup: ## create a gitlab backup
	$(PREFIX_CMD) $(ROLE_PATH)/scripts/gitlab-create.sh

gitlab-restore: ## restore a gitlab backup
	$(PREFIX_CMD) $(ROLE_PATH)/scripts/gitlab-restore.sh $(BACKUP_NAME)