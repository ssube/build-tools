# Setup

This guide covers setup of the cluster.

- [For cluster maintenance, refer to the maintenance guide.](maintenance.md)
- [For developing the cluster, refer to the development guide.](development.md)

## Workflow

This playbook uses a few different tools and runs in stages:

1. Cluster
1. Server
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

## Dependencies

### Tools

This project has a few dependencies, including:

1. ansible
1. blackbox
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

The playbook and Terraform resources assume you have AWS profiles set up. These may point at the same account or not,
tasks that need access to AWS use an STS session created at the beginning of the playbook.

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

The roles are able to provision remote hosts, with or without Kubernetes. These should be running a recent version
of Ubuntu and have SSH access set up from the host you'll be using.

If these hosts will be used as standalone Kubernetes clusters, they should be initialized with `kubeadm` before running
the playbook. Those clusters should use CNI, but do not need to have a network installed, and [the master's taint
should be removed](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#master-isolation):

```shell
$ kubectl taint nodes --all node-role.kubernetes.io/master-

node "master-1" untainted
```

#### Network

The Kubernetes networking layer can be sensitive to ISP network configuration, so be careful setting up clusters on
dedicated servers. Weave networking seems work in some situations where Calico does not, like on my
[So you Start](https://www.soyoustart.com/us/) host.

There is a role to install Weave located in [roles/kubectl/weave](roles/kubectl/weave). **Do not** run this role on
a kops AWS clusters, it **will break your network**.

## Config

This project provides Ansible roles, but does not provide a playbook or [inventory](http://docs.ansible.com/ansible/latest/intro_inventory.html) to run them. Both of these are specific to your
environment, so detailed docs are provided in [the `config` docs](config.md).

Before continuing, be sure to set up:

1. [inventory](config.md#inventory)
1. [secrets](config.md#secrets)
1. [requirements](config.md#requirements)

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

## Server

This stage creates Terraform to create the cloud resources:

```shell
$ make server-create

TASK [build-tools/roles/terraform/update : print tf env] ******
ok: [local] => {
    "msg": "TF_ENV=\"/tmp/example-net/tf-root/env.sh\""
}
```

While Terraform's diff logic is usually good, the configuration is better generated than written and the tool is not
easily scripted. Applying changes usually takes some time and seeing the plan before running is important, so this part
breaks with tradition to run Terraform without Ansible.

Include the `env.sh` from before to set the `TF_*` variables, pointing `make` at the generated files:

```shell
$ source /tmp/example-net/tf-root/env.sh

$ make terraform-create

terraform init -backend -get=true /tmp/apex-net/tf-root
Initializing modules...
...
Initializing the backend...

Initializing provider plugins...
...
Terraform has been successfully initialized!
...

$ make terraform-ready

terraform plan /tmp/apex-net/tf-root
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.
...
------------------------------------------------------------------------

No changes. Infrastructure is up-to-date.
```

If this looks right, `make terraform-update` and wait for Terraform to make it storm.

Continue when the cluster validates (this may take a few minutes):

```shell
$ make kops-validate

kops validate cluster --name example-net.example.com --state s3://example-net-prod-primary
Validating cluster example-net.example.com

INSTANCE GROUPS
NAME                    ROLE    MACHINETYPE     MIN     MAX     SUBNETS
runner-nodes            Node    c4.xlarge       0       3       us-east-1a
server-nodes            Node    t2.medium       1       2       us-east-1a
us-east-1a-masters      Master  t2.small        1       1       us-east-1a
us-east-1b-masters      Master  t2.small        1       1       us-east-1b
us-east-1c-masters      Master  t2.small        1       1       us-east-1c

NODE STATUS
NAME                                            ROLE    READY
ip-xx-yy-zz-ww.us-east-1.compute.internal       node    True
ip-xx-yy-zz-ww.us-east-1.compute.internal       master  True
ip-xx-yy-zz-ww.us-east-1.compute.internal       master  True
ip-xx-yy-zz-ww.us-east-1.compute.internal       master  True

Your cluster example-net.example.com is ready
```

### Server Tools

This stage runs the ansible playbook with `--tags server-create`. That renders the backend and providers for Terraform,
before `apply`ing the packaged TF and the kops cluster module.

### Server Resources

This step creates EC2 instances, DNS records, IAM roles, and myriad other resources. These are tracked by Terraform
and tagged (where possible) to help track costs.

## Service

This stage renders kubernetes resources from the templates and applies them to the selected clusters:

```shell
$ make service-create

ansible-playbook --tags service-create  --diff -f 8 -i /home/ssube/code/apex-net//inventory/everything.yml --extra-vars 'bucket_name=apex-net-prod-primary deploy_env=prod deploy_project=apex-net' /home/ssube/code/apex-net//site.yml

TASK [build-tools/roles/kubectl/cluster : apply services] *****************
changed: [local] => (item={u'name': u'log'})
changed: [local] => (item={u'name': u'dns'})
changed: [iron-1] => (item={u'name': u'log'})
changed: [local] => (item={u'name': u'gitlab'})
changed: [local] => (item={u'name': u'backup'})
changed: [iron-1] => (item={u'name': u'runner'})
changed: [local] => (item={u'name': u'scaler'})
changed: [local] => (item={u'name': u'runner'})

PLAY RECAP ****************************************************************
iron-1                     : ok=35   changed=9    unreachable=0    failed=0
local                      : ok=38   changed=7    unreachable=0    failed=0
```

The services that are applied to each cluster can be customized in the inventory's `group_vars`. To set up a cluster
with only the log service and a gitlab runner:

```yaml
all:
  hosts:
  # ...
  children:
    some-cluster:
      hosts:
        a:
      vars:
        cluster_services:
          - name: log
          - name: runner
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
