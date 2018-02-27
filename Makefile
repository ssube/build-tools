###
# Makefile
#
# Description
###

# Variables
## Arguments
BACKUP_NAME 	?= none
DEPLOY_ENV  	?= test
PREFIX_CMD		?=

## Paths
# resolve the makefile's path and directory, from https://stackoverflow.com/a/18137056
export ROOT_PATH := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
export ROLE_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
export SCRIPT_PATH := ${ROLE_PATH}/scripts

## Git
export GIT_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
export GIT_COMMIT = $(shell git rev-parse HEAD)
export GIT_REMOTES = $(shell git remote -v | awk '{ print $1; }' | sort | uniq)

## CI
export CI_COMMIT_REF_SLUG ?= $(GIT_BRANCH)
export CI_ENVIRONMENT_SLUG ?= local
export CI_RUNNER_DESCRIPTION ?= $(shell hostname)

## Project
export PROJECT_VARS := $(ROOT_PATH)/secrets/$(DEPLOY_ENV)/vars.yml
export PROJECT_NAME := $(shell $(SCRIPT_PATH)/read-secret.sh $(PROJECT_VARS) .secrets.tags.project 'example-net')
export PROJECT_DOMAIN := $(shell $(SCRIPT_PATH)/read-secret.sh $(PROJECT_VARS) .secrets.dns.base 'example.com')

# Includes
include $(ROLE_PATH)/scripts/*.mk

# Entry
all: help

# Stages
## Server (stage 2)
server-create:
	$(PREFIX_CMD) ansible-playbook --tags server-create $(ANS_DEFAULTS) $(ANS_SITE)

server-delete:
	$(PREFIX_CMD) ansible-playbook --tags server-delete $(ANS_DEFAULTS) $(ANS_SITE)

server-ready:
	$(PREFIX_CMD) ansible-playbook --tags server-ready $(ANS_DEFAULTS) $(ANS_SITE)

server-update:
	$(PREFIX_CMD) ansible-playbook --tags server-update $(ANS_DEFAULTS) $(ANS_SITE)

## Cluster (stage 1)
cluster-create: ## TODO
	$(PREFIX_CMD) ansible-playbook --tags cluster-create $(ANS_DEFAULTS) $(ANS_SITE)

cluster-delete: ## delete a k8s cluster
	$(PREFIX_CMD) ansible-playbook --tags cluster-delete $(ANS_DEFAULTS) $()

cluster-ready: ## TODO
	$(PREFIX_CMD) ansible-playbook --tags cluster-ready $(ANS_DEFAULTS) $(ANS_SITE)

cluster-update: ## TODO
	$(PREFIX_CMD) ansible-playbook --tags cluster-update $(ANS_DEFAULTS) $(ANS_SITE)

## Dependencies (stage 0)
dependencies-create: ## install local dependencies (still requires ansible and blackbox)
	$(PREFIX_CMD) $(SCRIPT_PATH)/bootstrap.sh
	$(PREFIX_CMD) ansible-playbook --tags dependencies-update $(ANS_DEFAULTS) $(ANS_SITE)

dependencies-delete: ## delete local installed dependencies
	@echo "this makes no sense"

dependencies-ready: ## check that dependencies are installed
	@$(PREFIX_CMD) which ansible-playbook
	@$(PREFIX_CMD) which blackbox_decrypt_all_files
	@$(PREFIX_CMD) which blackbox_shred_all_files
	@$(PREFIX_CMD) which git
	@$(PREFIX_CMD) which jq
	@$(PREFIX_CMD) which kops
	@$(PREFIX_CMD) which kubectl
	@$(PREFIX_CMD) which yq
	@echo "all dependencies appear to be installed"

dependencies-update: dependencies-create ## install local dependencies (still requires ansible and blackbox)

## Service (stage 3)
service-create: ## apply service configuration within the cluster
	$(PREFIX_CMD) ansible-playbook --tags service-create $(ANS_DEFAULTS) $(ANS_SITE)

service-delete: ## TODO
	$(PREFIX_CMD) ansible-playbook --tags service-delete $(ANS_DEFAULTS) $(ANS_SITE)

service-ready: ## render service configuration for the cluster without applying
	$(PREFIX_CMD) ansible-playbook --tags service-ready $(ANS_DEFAULTS) $(ANS_SITE)

service-update: ## TODO
	$(PREFIX_CMD) ansible-playbook --tags service-update $(ANS_DEFAULTS) $(ANS_SITE)

# Services
## Gitlab
gitlab-backup: ## create a gitlab backup
	$(PREFIX_CMD) $(ROLE_PATH)/scripts/gitlab-create.sh

gitlab-restore: ## restore a gitlab backup
	$(PREFIX_CMD) $(ROLE_PATH)/scripts/gitlab-restore.sh $(BACKUP_NAME)

# Meta
## Misc
# from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## print this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
		| sed 's/^.*\/\(.*\)/\1/' \
		| awk 'BEGIN {FS = ":[^:]*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

todo: ## list remaining todo tasks in the code
	@echo "Remaining tasks:"
	@echo ""
	@grep -i "todo" -I -r .

## Git
git-push: ## push to both gitlab and github
	$(PREFIX_CMD) git push github
	$(PREFIX_CMD) git push gitlab

## Secrets
secrets-unlock: ## unlock secrets before editing
	$(PREFIX_CMD) blackbox_decrypt_all_files

secrets-discard: ## discard secrets without saving
	$(PREFIX_CMD) blackbox_shred_all_files
