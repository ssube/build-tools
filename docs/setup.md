# Setup

This guide covers setup of the cluster.

- [For cluster maintenance, refer to the maintenance guide.](maintenance.md)
- [For developing the cluster, refer to the development guide.](development.md)

## Workflow

This playbook uses a few different tools and runs in stages:

1. Cluster
1. Cloud
1. Service

You can safely stop between stages and take a break, look at what the next stage will run, or even reboot your machine.
Intermediate files for future tasks are saved in S3 and can be encrypted.

Each stage has a `-create` target to set up the resources, an `-update` target to make regular changes, and a `-delete`
target to tear it all down. To run without making changes, include `ANS_CHECK=--check` before or after the `make`
target.

Many of the tasks run locally, using kubernetes context and terraform state fetched from remote sources. This should
work with HTTP proxies, but you can run the playbook from a bastion host in your environment, add
[bastion settings to the inventory](https://docs.ansible.com/ansible/latest/faq.html#how-do-i-configure-a-jump-host-to-access-servers-that-i-have-no-direct-access-to), or set up [proxy commands in your SSH config](https://linux.die.net/man/5/ssh_config#ProxyCommand).

Generally speaking, if you can run all of the tools and SSH into each of the boxes, this playbook should work.

## Prerequisites

### Local

This project has a few local dependencies, including:

1. ansible
1. kops
1. kubectl
1. make
1. terraform
1. an ssh key

Most of them can be installed by the playbook, if you are willing to let it modify your local host; if not, the same
containers used in the CI build can be run locally. You can define a prefix command for [the Makefile](../Makefile)
using `PREFIX_CMD`:

```shell
PREFIX_CMD='docker exec -it -v ${HOME}:/root:ro -v $(pwd):$(pwd):rw -w $(pwd) apextoaster/base:latest --'
```

**TODO:** add a prefix function that can run multiple containers

You will also need the public portion of an SSH key. This will be set up for SSH access on the hosts and clusters.
Using a GPG card for this, [like a Yubikey](https://www.yubico.com/), is a very good idea.

### AWS

#### Accounts

The playbook and Terraform resources assume you have an AWS organization with at least 3 accounts:

1. root
1. test
1. prod

**TODO:** make/make sure it's possible to run with a single AWS account

You should have credentials set up for each account with a named profile, prefixed with the project name
(`project-name-prod`). The playbook will create STS sessions as needed and does not copy your credentials to other hosts.

#### DNS

The Terraform stage will create a DNS zone for the cluster. You do not need to register a domain with AWS, but you do
need a public zone.

A delegation record will be created in the root zone, along with records for major services (like Gitlab). The root
user needs the following policy for the root zone:

```json
{
  "Sid": "update-project-dns",
  "Effect": "Allow",
  "Action": [
    "route53:GetHostedZone",
    "route53:ListResourceRecordSets",
    "route53:ChangeResourceRecordSets"
  ],
  "Resource": [
    "zone-id"
  ]
}
```

### Other Hosts

The playbook is able to provision remote hosts, with or without Kubernetes. These should be running a recent version
of Ubuntu and have SSH access set up from the host you'll be using.

If these hosts will be used as standalone Kubernetes clusters, they should be initialized with `kubeadm` before running
the playbook. Those clusters should use CNI, but do not need to have a network installed, and [the master's taint
should be removed](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#master-isolation):

```shell
$ kubectl taint nodes --all node-role.kubernetes.io/master-

node "iron-1" untainted
```

The Kubernetes networking layer can be sensitive to ISP network configuration, so be careful setting up clusters on
dedicated servers. Weave networking seems work in some situations where Calico does not, such as SoYouStart hosts.
There is a role to install Weave located in [roles/kubectl/weave](roles/kubectl/weave).
 **Do not** run this role on Kops AWS clusters.

## Config

Make a copy of [the vars file](vars/everything.yml) and replace with your own environment variables.

## Cluster

This stage creates a cluster from [the template](roles/kops/templates/cluster.yml):

```shell
$ make cluster-create

**TODO:** output
```

### Cluster Tools

This stage runs the ansible playbook with `--tags cluster-create`. That renders the template and runs kops to create
the cluster state and render Terraform source.

### Cluster Resources

This stage creates S3 objects to store the Kops state and Terraform source, but does not create any EC2 instances
or make other large changes.

## Cloud

This stage runs Terraform to create the cloud resources, DNS, roles, and other necessities:

```shell
$ make cloud-create

Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:
...
Plan: 5 to add, 0 to change, 4 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

If this looks right, enter `yes` and wait for Terraform to make it storm.

Continue when the cluster validates (this may take a few minutes):

```shell
$ make kops-validate

**TODO:** output
```

### Cloud Tools

This stage runs the ansible playbook with `--tags cloud-create`. That renders the backend and providers for Terraform,
before `apply`ing the packaged TF and the kops cluster module.

### Cloud Resources

This step creates EC2 instances, DNS records, IAM roles, and myriad other resources. These are tracked by Terraform
and tagged (where possible) to help track costs.

## Service

This stage renders kubernetes resources from the templates and applies them to the selected clusters:

```shell
$ make service-create

**TODO:** output
```

Which services are applied to a cluster can be customized in the inventory's `group_vars`:

```yaml
TODO: example
```

### Service Tools

This stage runs the ansible playbook with `--tags service-create`. That renders the kubernetes resources to YML, then
runs `kubectl` to apply them.

### Service Resources

This stage may create DNS records and Elastic Load Balancers, depending on your configuration. Each `LoadBalancer`
service requires an ELB. Services on dedicated servers will bind a port on the host.

**TODO:** auto-provision nginx or traefik for service ports

## Validate

Once DNS has propagated, you should be able to log into Gitlab at `https://git.example.com`.
