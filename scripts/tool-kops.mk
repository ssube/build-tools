# Kops

## Exports
export KOPS_STATE_STORE := s3://$(PROJECT_NAME)-$(DEPLOY_ENV)-primary

## Locals
KOPS_BUCKET		:= $(KOPS_STATE_STORE)
KOPS_CLUSTER	:= --name $(PROJECT_NAME).$(PROJECT_DOMAIN)
KOPS_DEFAULTS := $(KOPS_CLUSTER) --state $(KOPS_BUCKET)

## CRUD
kops-create: ## create a k8s cluster and public key from the cluster definition
	$(PREFIX_CMD) kops create $(KOPS_DEFAULTS) -f $(KOPS_DEFINITION)
	$(PREFIX_CMD) kops create secret $(KOPS_CLUSTER) sshpublickey admin -i ~/.ssh/yubi.pub

kops-delete: ## delete a k8s cluster
	$(PREFIX_CMD) kops delete cluster $(KOPS_DEFAULTS) --yes

kops-ready: ## TODO
	$(PREFIX_CMD) kops 

kops-update: ## update the cluster module from the rendered definition (does not update remote resources)
	$(PREFIX_CMD) kops replace $(KOPS_DEFAULTS) -f $(KOPS_DEFINITION) -v 0
	$(PREFIX_CMD) kops update cluster $(KOPS_DEFAULTS) --target=terraform --out $(ROOT_PATH)/terraform/modules/k8s/aws/ --yes

## Extras
kops-context: ## export a k8s cluster context
	$(PREFIX_CMD) kops export kubecfg $(KOPS_DEFAULTS)

kops-rolling-update: ## perform a rolling update of the cluster
	$(PREFIX_CMD) kops rolling-update cluster $(KOPS_DEFAULTS) --yes

kops-validate: ## validate the cluster health
	$(PREFIX_CMD) kops validate cluster $(KOPS_DEFAULTS)

kops-proxy: kops-context ## proxy to the cluster (may not work with a container prefix_cmd)
	$(PREFIX_CMD) kubectl $(KUBE_DEFAULTS) proxy
