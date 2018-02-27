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
