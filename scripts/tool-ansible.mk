# Ansible

## Variables
ANS_PROCS ?= $(SYSTEM_CORES)
ANS_ROOT ?= $(ROOT_PATH)
ANS_TAGS ?= ""
ANS_VARS ?= --extra-vars 'bucket_name=$(PROJECT_NAME)-$(DEPLOY_ENV)-primary deploy_env=$(DEPLOY_ENV) deploy_project=$(PROJECT_NAME)'

ansible-update: ## TODO
	ansible-playbook $(if $(DEBUG), --check) --diff $(ANS_VARS) -f $(ANS_PROCS) -i $(ANS_ROOT)/inventory --tags $(ANS_TAGS) $(ANS_ROOT)/site.yml

galaxy-install: ## install galaxy roles
	ansible-galaxy install -r requirements.yml

galaxy-update: ## update galaxy roles
	ansible-galaxy install -r requirements.yml --force