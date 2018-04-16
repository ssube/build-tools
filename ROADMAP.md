# Roadmap

This roadmap is a list of high-level project goals in approximate order of priority.

## Stable

Before the first stable release, the following need to be implemented:

- [ ] kubeadm join for nodes without kubelet
- [ ] document secrets
- [ ] AWS account setup script & docs

## Potential

Valuable features that need more planning:

- [ ] kubernetes the hard way setup (raw node, complete setup)
  - removes dependency on kops
  - support mixed-cloud clusters
  - use the `githubixx.kubernetes-*` roles?
- [ ] terraform rename helper
  - renaming terraform resource is painful, but necessary
  - write a helper script to delete the resource from state and import it under a new name

## Complete

These features have been implemented:

- [x] kube2iam roles for kops cluster
