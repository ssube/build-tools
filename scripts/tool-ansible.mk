# Ansible

## Variables
ANS_VARS := --extra-vars 'bucket_name=$(PROJECT_NAME)-$(DEPLOY_ENV)-primary deploy_env=$(DEPLOY_ENV) deploy_project=$(PROJECT_NAME)'

ifdef DEBUG
  ANS_ARGS := --check --diff -f 8 -i $(ROOT_PATH)/inventory/everything.yml $(ANS_VARS)
else
  ANS_ARGS := --diff -f 8 -i $(ROOT_PATH)/inventory/everything.yml $(ANS_VARS)
endif

ANS_SITE := $(ROOT_PATH)/site.yml