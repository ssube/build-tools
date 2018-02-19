# Clusters

This project supports two types of Kubernetes clusters: kops and kubeadm. Roles are available
to fetch context for each and services work on both.

## Kops

Kops clusters can be made automatically by the playbook, using the cluster definition to generate
a Terraform module, then generate Terraforming to instantiate the cluster.

The Terraform module will output a state file to S3, much like the Kops workflow, for later use by
Ansible and other tools.

## Kubeadm

**TODO:** automatically `kubeadm init` with a config file or flags

Kubeadm clusters must be initialized before running the playbook, for now.

After running the playbook to install the Kubernetes tools, shell into the kubeadm host(s) and run
the [kubeadm create cluster instructions](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#instructions).
For small deployments, kubeadm clusters can be used to schedule pods on single standalone nodes. This works well with
dedicated servers from SoYouStart and other hosts that do not provide private networking.