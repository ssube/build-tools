# Kops

## Exports
export KOPS_STATE_STORE := s3://$(PROJECT_NAME)-$(DEPLOY_ENV)-primary

## Locals
KOPS_BUCKET   := $(KOPS_STATE_STORE)
KOPS_CLUSTER  := --name $(PROJECT_NAME).$(PROJECT_DOMAIN)
KOPS_DEFAULTS := $(KOPS_CLUSTER) --state $(KOPS_BUCKET)
KOPS_MODULE   ?= $(ROOT_PATH)/terraform/modules/k8s/aws
KOPS_ROLL     ?= --master-interval 15m --node-interval 15m

## CRUD
kops-create: ## create a k8s cluster and public key from the cluster definition
	$(PREFIX_CMD) kops create $(KOPS_DEFAULTS) -f $(KOPS_DEFINITION)
	$(PREFIX_CMD) kops create secret $(KOPS_CLUSTER) sshpublickey admin -i ~/.ssh/yubi.pub

kops-delete: ## delete a k8s cluster
	$(PREFIX_CMD) kops delete cluster $(KOPS_DEFAULTS) $(if $(APPROVE), --yes)

kops-ready: kops-validate ## ensure a k8s cluster is ready

kops-update: kops-replace kops-update-tf ## update the cluster module from the rendered definition (does not update remote resources)

## Extras
kops-context: ## export a k8s cluster context
	$(PREFIX_CMD) kops export kubecfg $(KOPS_DEFAULTS)

kops-replace: ## replace the kops state with new resources generated from the yaml
	$(PREFIX_CMD) kops replace $(KOPS_DEFAULTS) -f $(KOPS_DEFINITION) -v 0

kops-update-roll: ## perform a rolling update of the cluster
	$(PREFIX_CMD) kops rolling-update cluster $(KOPS_DEFAULTS) --interactive $(if $(APPROVE), --yes)

kops-update-s3: ## update a cluster from stored tf state
	$(PREFIX_CMD) kops update cluster $(KOPS_DEFAULTS) $(if $(APPROVE), --yes)

kops-update-tf: ## render a terraform module from the kops state
	$(PREFIX_CMD) kops update cluster $(KOPS_DEFAULTS) --target=terraform --out $(KOPS_MODULE) $(if $(APPROVE), --yes)

kops-validate: ## validate the cluster health
	$(PREFIX_CMD) kops validate cluster $(KOPS_DEFAULTS)
