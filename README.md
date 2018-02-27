# build-tools

## CRUD for [Gitlab](https://about.gitlab.com/) on [Kubernetes](https://kubernetes.io/) [¹](#documentation)

This repo has [Ansible roles](http://docs.ansible.com/ansible/latest/playbooks_reuse_roles.html) and
[Terraform modules](https://www.terraform.io/docs/modules/usage.html) to set up a Gitlab CI cluster and supporting
services.

Everything is wrapped with `make` targets to `create`, `ready` (validate), `update`, and eventually `delete` the
resources. The cluster is set up in stages: `cluster`, `cloud`, and finally `service`s.

**Alpha:** this project works for me and I'd like to share, but may not work for you. Maybe not at all.
Please open issues if you see anything, or just with questions or suggestions.

To get started, the docs directory has guides for:

- [Setup](docs/setup.md)
- [Maintenance](docs/maintenance.md)
- [Development](docs/development.md)

## What

This playbook sets up a kubernetes cluster in AWS, using kops, to run Gitlab and supporting tools.

Gitlab runners are set up with an autoscaling group of [spot instances](https://aws.amazon.com/ec2/spot/), which
automatically shut down after 10 minutes idle and cost about 25% as much as on-demand instances.

Additional clusters can be included and the playbook is able to load context from kubeadm and kops.

Most of the tasks are system-independent and only require `make` and the tools used by the stage, but the
dependencies stage requires Ubuntu 16.04 or better. The latest Ubuntu LTS AMI is used for the kops nodes.

### Cluster Tools

The following tools will be set up within the cluster:

- [Gitlab](https://about.gitlab.com/) (with runners, both AWS spot and optional dedicated)

With the following SaaS tools in support:

- [Foxpass](https://www.foxpass.com/)
- [Grafana](https://grafana.com/)
- [Keybase](https://keybase.io/)
- [Papertrail](https://papertrailapp.com/)
- [Sentry](https://sentry.io/)
- [UptimeRobot](https://uptimerobot.com/)

## How

make is used as a task runner, orchestrating the ansible playbook runs using tags. In short:

1. terraform runs to set up DNS and VPC
1. kubernetes cluster definition is rendered from the secrets into a terraform module.
1. terraform runs to set up cache, database, and kubernetes nodes.
1. kubernetes service definitions are rendered from the secrets, config, and templates.

### Local Tools

The following tools are used locally to set up the cluster:

- [ansible](https://www.ansible.com/) v2.4
- [aws](https://aws.amazon.com/cli/)
- bash 4+ (only a problem on OS X)
- [blackbox](https://github.com/StackExchange/blackbox)
- [kops](https://github.com/kubernetes/kops) v1.8.2 (git-0ab8b57c2 or later)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [make](https://www.gnu.org/software/make/)
- [terraform](https://www.terraform.io/) v0.11.2

Some of these should be installed before running, some can be installed by the Ansible playbook. Please see
[the setup guide § dependencies](docs/setup.md#dependencies) for details.

The version requirements are noted when a very recent version is needed, usually for a specific fix. Otherwise,
most recent versions should work.

## Where

The resources created by this project will be in [Amazon AWS](https://aws.amazon.com).

You may provide your own kubernetes clusters (provisioned with kops or kubeadm) and allocate some services there,
although the core services (Gitlab, DNS, and autoscaling) are only supported in AWS clusters.

**TODO:** provide a way to disable the kops cluster

## Why

This repo shows a way to automate build infrastructure and projects within it, using common open-source tools. This
setup scales well from small, personal projects to company clusters.

### Documentation

¹: This project is not a replacement for reading the documentation. Kubernetes and Gitlab both offer excellent
documentation. To get comfortable with the concepts used here, check out:

- [Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/autoscaling/plans/userguide/what-is-aws-auto-scaling.html)
- [Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/details/)
- [Gitlab CI Kubernetes Executor](https://docs.gitlab.com/runner/executors/kubernetes.html)
- [Gitlab CI YML](https://docs.gitlab.com/ce/ci/yaml/README.html#gitlab-ci-yml)
- [kubernetes Concepts](https://kubernetes.io/docs/concepts/)
- [kubectl overview](https://kubernetes.io/docs/reference/kubectl/overview/)
- [kops overview](https://github.com/kubernetes/kops/blob/master/docs/cli/kops.md)

## Who

This project is maintained by ssube.