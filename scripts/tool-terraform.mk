# Terraform

## Locals
TF_APPROVE		?= -approve
TF_PATH				?= $(ROLE_PATH)/terraform
TF_STATE 			?= $(ROOT_PATH)/secrets/$(DEPLOY_ENV)/state.tfvars
TF_VARS				?= $(ROOT_PATH)/secrets/$(DEPLOY_ENV)/env.tfvars

## CRUD
terraform-create: ## initialize the terraform backend
	$(PREFIX_CMD) terraform init -backend -backend-config=$(TF_STATE) -get=true $(TF_PATH)

terraform-delete: ## delete the terraform infrastructure
	$(PREFIX_CMD) terraform delete -var-file=$(TF_VARS) $(TF_PATH)

terraform-ready: ## plan terraform resource changes
	$(PREFIX_CMD) terraform plan -var-file=$(TF_VARS) $(TF_PATH)

terraform-update: ## apply terraform resource changes (including the cluster module)
	$(PREFIX_CMD) terraform apply $(TF_APPROVE) -var-file=$(TF_VARS) $(TF_PATH)
