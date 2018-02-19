# Developing

When working on the playbook itself, testing the cluster definitions and Terraform config locally is helpful.

The [Makefile](../Makefile) contains stage targets. Individual tool makefiles (like
[tool-kops.mk](../scripts/tool-kops.mk)) for each tool have specific targets.

The stage targets run ansible with a set of `--tag`s, ansible handles state and templates, then runs some of the tool
targets.

## Ansible

The repository has some Ansible with roles. It needs to be installed in a playbook before being used. To avoid
constantly updating during development, you can symlink `roles/build-tools` in the playbook directory to the root of
this repo.

Roles are organized by tool, with some overlap between the kubectl roles and other cluster roles.

## Kops

Kops is used to turn the cluster definition (rendered from
[the template](../roles/kops/cluster/templates/definition.yml)) into a
[Terraform module](https://www.terraform.io/docs/modules/usage.html). The template contains the logic to turn
variables into instance groups and so on.

## Terraform

Terraform handles most of the cloud resource changes. It attempts to diff the current state and desired resources,
a process which can become confused. Be especially careful renaming or moving modules.

The Terraform resources are centered largely around [the network and cluster](../terraform/main.tf), with modules
for each repeatable set of resources (like a pair of replicated S3 bucket and their replication policy). The modules
are organized by provider.
