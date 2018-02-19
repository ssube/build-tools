# Ansible

## Variables
ANS_CHECK			?= 
ANS_EXTRAS		:= --extra-vars 'bucket_name=$(PROJECT_NAME)-$(DEPLOY_ENV)-primary deploy_env=$(DEPLOY_ENV) deploy_project=$(PROJECT_NAME)'
ANS_DEFAULTS 	:= $(ANS_CHECK) --diff -f 8 -i $(ROOT_PATH)/inventory/everything.yml $(ANS_EXTRAS)
ANS_SITE 			:= $(ROOT_PATH)/site.yml