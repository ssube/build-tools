# Terraform

## Locals
TF_APPROVE		?= -auto-approve
TF_PATH				?= $(ROLE_PATH)/terraform

## CRUD
terraform-create: ## initialize the terraform backend
	$(PREFIX_CMD) terraform init -backend -get=true $(TF_PATH)

terraform-delete: ## delete the terraform infrastructure
	$(PREFIX_CMD) terraform delete $(TF_PATH)

terraform-ready: ## plan terraform resource changes
	$(PREFIX_CMD) terraform plan $(TF_PATH)

terraform-update: ## apply terraform resource changes (including the cluster module)
	$(PREFIX_CMD) terraform apply $(TF_APPROVE) -input=false $(TF_PATH)

## Others
terraform-import: ## import TF_IMPORT_SRC as TF_IMPORT_DEST
	$(PREFIX_CMD) terraform import -config=$(TF_PATH) module.$(TF_IMPORT_DEST) $(TF_IMPORT_SRC)

terraform-refresh: ## refresh state for TF_REFRESH_RES
	$(PREFIX_CMD) terraform refresh -target=module.$(TF_REFRESH_RES) $(TF_PATH)