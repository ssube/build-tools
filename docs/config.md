# Config

This guide covers the config structure and what you need to create before the roles run.

## Config Structure

The playbook directory structure should be set up with:

```none
example-net/
  inventory/
  keyrings/
  roles/
  secrets/
    prod/
    test/
  ansible.cfg
  Makefile
  requirements.yml
  site.yml
```

## Inventory

The `inventory/` directory should contain [your inventory](http://docs.ansible.com/ansible/latest/intro_inventory.html)
with existing hosts and clusters. It must contain a `local` host and `all` group:

```yaml
all:
  hosts:
    local:
      ansible_connection: local
    dedicated-host:
      ansible_host: xx.yy.zz.ww
      ansible_user: not-root
      ansible_becoe: true
      ansible_become_method: sudo
  # groups
  children:
    remote:
      hosts:
        dedicated-host:
    aws-cluster:
      hosts:
        local:
      vars:
        cluster_services:
          - name: log
          - name: gitlab
```

## Keyring

The `keyring/` directory is created and managed by BlackBox. Follow [their instructions](https://github.com/StackExchange/blackbox#enabling-blackbox-for-a-repo)
to set up the repository:

```shell
$ blackbox_initialize

$ blackbox_addadmin ABCDEF1234

$ blackbox_register_new_file inventory/* secrets/{prod,test}/*
```

This keep your connections and secrets encrypted. BlackBox will automatically add files to `.gitignore` when
they are registered.

## Secrets

The `secrets/` directory contains your secrets. All `.yml` files will be loaded.

**TODO:** secrets template

## Ansible Config

The `ansible.cfg` sets options for `ansible-playbook`, especially the local `roles` directory.

```ini
[defaults]

role_path = ./roles
```

## Makefile

The `Makefile` should `include` the role's makefile (gracefully handling a clean checkout) and provide any extra
targets you might need:

```make
include $(shell find ./roles -name Makefile)

galaxy-install: ## install galaxy roles
	ansible-galaxy install -r requirements.yml

galaxy-update: ## update galaxy roles
	ansible-galaxy install -r requirements.yml --force
```

These targets will be included in `make help` with any text in the `## comment`.

## Requirements

The `requirements.yml` includes the project's repository and version. You can pin a version (git tag) or follow the
stable branch:

```yaml
- src: git+https://github.com/ssube/build-tools.git
  version: master
```

## Site

The `site.yml` playbook attaches roles to hosts. The first few stages of this will be consistent, but the latter ones
are specific to your environment. For example:

```yaml
---

# setup (stage -1)

- name: sts session
  hosts:
    - all
  roles:
    - role: build-tools/roles/aws/session

- name: load environment
  hosts:
    - all
  roles:
    - role: build-tools/roles/common/env

- name: create working directory
  hosts:
    - all
  roles:
    - role: build-tools/roles/common/output
  vars_files: &cluster_vars
    - roles/build-tools/vars/cluster.yml
    - roles/build-tools/vars/gitlab.yml

# dependencies (stage 0)

- name: local dependencies
  hosts:
    - all
  roles:
    - role: build-tools/roles/common/local

- name: remote dependencies
  hosts:
    - remote
  roles:
    - role: build-tools/roles/common/remote

# cluster (stage 1)

- name: cluster
  hosts:
    - local
  roles:
    - role: build-tools/roles/kops/cluster
  vars_files: *cluster_vars

# server (stage 2)

- name: server
  hosts:
    - local
  roles:
    - role: build-tools/roles/terraform/update
  vars_files: *cluster_vars

# service (stage 3)

- name: fetch state
  hosts:
    - all
  roles:
    - role: build-tools/roles/aws/state
  vars_files: *cluster_vars

- name: get cluster context
  hosts:
    - aws-cluster
  roles:
    - role: build-tools/roles/kops/context
  vars_files: *cluster_vars

- name: get cluster context
  hosts:
    - sys-cluster
  roles:
    - role: build-tools/roles/kubeadm/context
  vars_files: *cluster_vars

- name: tag cluster nodes
  hosts:
    - sys-cluster
  roles:
    - role: build-tools/roles/kubeadm/tag_node
  vars_files: *cluster_vars

- name: apply cluster services
  hosts:
    - aws-cluster
    - sys-cluster
  roles:
    - role: build-tools/roles/kubectl/cluster
  vars_files: *cluster_vars

# fin
```