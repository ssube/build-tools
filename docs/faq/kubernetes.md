# Kubernetes

## Cluster Size

The default cluster is very small, with a single master and two server nodes. This is smaller than it should be.

To perform a rolling upgrade, at least three masters are required (kops/k8s does not allow two, as quorum would be
lost).

To increase the size of the cluster, edit any of the `InstanceGroup`s in
[the cluster definition](../roles/kops/cluster/templates/cluster.yml).

```yaml
---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{cluster.name}}
  name: e2a-masters
spec:
  image: {{cluster.image}}
  machineType: t2.small
  maxSize: 1    # <- edit these
  minSize: 1    # <- edit these
```

## Master Not Responding

Restarting or replacing the master, which happens during a rolling upgrade, can break the cluster if a single master is
running. The error looks like:

```none
kops validate cluster --name project-name.example.com --state s3://project-name-prod-primary
Validating cluster project-name.example.com


cannot get nodes for "project-name.example.com": Get https://api.project-name.example.com/api/v1/nodes: dial tcp xxx.yyy.zzz.www:443: i/o timeout
Makefile:124: recipe for target 'kops-validate' failed
make: *** [kops-validate] Error 1
```

The most likely cause is the `api.project.domain` name not being updated to the new master's public IP.

To fix this automatically, run [scripts/update-master-dns.sh](../scripts/update-master-dns.sh) with the cluster
name.

**TODO:** write that script

To fix this by hand, log into the AWS console for the account the cluster is in. Find the master's IP address from
[the EC2 console](https://console.aws.amazon.com/ec2/v2/home#Instances:sort=instanceId) by instance name.

In [the Route53 console](https://console.aws.amazon.com/route53/home#hosted-zones:), find the cluster's zone and click
into the records. Update the `A` record for `api` with the master's IP address. Save the records and wait for DNS to
update.

If validation shows the master as not ready, reboot the instance or scale up the number of masters in the cluster
definition.
