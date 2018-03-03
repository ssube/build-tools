# Kubectl

## Exports
### None

## Locals
KUBECTL_CONTEXT	?= ${KUBECONFIG}

## CRUD
### None

## Extras
kubectl-secret: ## create a kubernetes secret from file
	$(PREFIX_CMD) kubectl --kubeconfig ${KUBECTL_CONTEXT} create secret \
		generic $(KUBECTL_SECRET_NAME) --from-file $(KUBECTL_SECRET_FILE)

kubectl-apply: ## apply a kubernetes resource file
	$(PREFIX_CMD) kubectl --kubeconfig ${KUBECTL_CONTEXT} apply -f $(KUBECTL_RESOURCE_FILE)

kubectl-proxy: kops-context ## proxy to the cluster (may not work with a container prefix_cmd)
	$(PREFIX_CMD) kubectl $(KUBE_DEFAULTS) proxy
