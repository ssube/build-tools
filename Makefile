###
# Makefile
#
# Description
###

# Variables
## Arguments
BACKUP_NAME ?= none
DEPLOY_ENV ?= test
PREFIX_CMD ?=

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

## System
# from https://stackoverflow.com/a/23569003/129032
export SYSTEM_CORES ?= $(shell getconf _NPROCESSORS_ONLN)
# from https://stackoverflow.com/a/2441064/129032
export SYSTEM_MEM_KB ?= $(shell grep MemTotal /proc/meminfo | awk '{print $$2}' )
export SYSTEM_MEM_GB ?= $(shell echo $$(( $(SYSTEM_MEM_KB) / 1024 / 1024 )) )

# Includes
include $(ROLE_PATH)/scripts/*.mk

# Entry
all: help

# Stages
## Dependencies (stage 0)
dependencies-create: ## install local dependencies (still requires ansible and blackbox)
	$(PREFIX_CMD) $(SCRIPT_PATH)/bootstrap.sh
	$(PREFIX_CMD) ansible-playbook --tags dependencies-update $(ANS_ARGS) $(ANS_SITE)

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

## Cluster (stage 1)
cluster-create: ## TODO
	ANS_TAGS="$@" $(MAKE) ansible-update

cluster-delete: ## delete a k8s cluster
	ANS_TAGS="$@" $(MAKE) ansible-update

cluster-ready: ## TODO
	ANS_TAGS="$@" $(MAKE) ansible-update

cluster-update: ## TODO
	ANS_TAGS="$@" $(MAKE) ansible-update

## Server (stage 2)
server-create: ## create the terraform definitions
	ANS_TAGS="$@" $(MAKE) ansible-update

server-delete: ## noop
	ANS_TAGS="$@" $(MAKE) ansible-update

server-ready: ## ensure terraform state matches the remote state
	ANS_TAGS="$@" $(MAKE) ansible-update

server-update: ## update the terraform definitions
	ANS_TAGS="$@" $(MAKE) ansible-update

## Service (stage 3)
service-create: ## apply service configuration within the cluster
	ANS_TAGS="$@" $(MAKE) ansible-update

service-delete: ## TODO
	ANS_TAGS="$@" $(MAKE) ansible-update

service-ready: ## render service configuration for the cluster without applying
	ANS_TAGS="$@" $(MAKE) ansible-update

service-update: ## TODO
	ANS_TAGS="$@" $(MAKE) ansible-update

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

## Secrets
secrets-unlock: ## unlock secrets before editing
	$(PREFIX_CMD) blackbox_decrypt_all_files

secrets-discard: ## discard secrets without saving
	$(PREFIX_CMD) blackbox_shred_all_files
